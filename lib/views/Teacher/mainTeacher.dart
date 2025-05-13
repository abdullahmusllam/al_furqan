import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:al_furqan/views/Teacher/DrawerTeacher.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with UserDataMixin, WidgetsBindingObserver {
  int _unreadMessagesCount = 0;
  
  @override
  void initState() {
    super.initState();
    // إضافة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.addObserver(this);
    
    // Initial data loading
    fetchUserData();
    loadMessagesAndStudent();
    halagaController.getHalagatFromFirebase();
  }
  
  @override
  void dispose() {
    // إزالة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // تحديث عدد الإشعارات عند العودة للتطبيق
    if (state == AppLifecycleState.resumed) {
      updateNotificationCount();
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // تحميل الرسائل وبيانات الطلاب
  Future<void> loadMessagesAndStudent() async {
    final prefs = await SharedPreferences.getInstance();
    int? Id = prefs.getInt('user_id');
    print('===== ($Id) =====');
    
    // تحميل الرسائل من فايربيس
    await messageService.loadMessagesFromFirestore(Id!);
    
    // تحديث عدد الإشعارات
    await updateNotificationCount();
    
    // تحميل بيانات الطلاب والمعلمين
    await studentController.addToLocalOfFirebase(schoolID!);
    await halagaController.getTeachers(schoolID!);
    await fathersController.getFathersBySchoolId(schoolID!);
  }
  
  // تحديث عدد الإشعارات
  Future<void> updateNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    int? Id = prefs.getInt('user_id');
    if (Id != null) {
      _unreadMessagesCount = await messageController.getUnreadMessagesCount(Id);
      setState(() {}); // تحديث واجهة المستخدم
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // زر تحديث البيانات
          IconButton(
            onPressed: () {
              updateNotificationCount();
              // استدعاء دالة تحديث البيانات مباشرة (ستقوم بتحديث حالة التحميل داخلياً)
              fetchUserData().then((_) {
                // تحديث عدد الإشعارات عند الضغط على زر التحديث
                updateNotificationCount();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث البيانات بنجاح'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
          ),
          // زر تسجيل الخروج
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
        title: isLoading || user == null
            ? Text("جاري التحميل...")
            : Text('${user!.first_name} ${user!.last_name}'),
      ),
      drawer: user == null ? null : DrawerTeacher(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text("فشل في جلب بيانات المستخدم"))
              : user!.elhalagatID == null || user!.elhalagatID == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 80,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "لا يوجد حلقة مسجلة لك",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "يرجى التواصل مع مدير المدرسة لتسجيلك في حلقة",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // أول صف يحتوي على كاردين
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // كارد 1
                                Expanded(
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Colors.white,
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          'اسم الحلقة',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // كارد 2 - بطاقة الإشعارات
                                Expanded(
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'الإشعارات',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.white,
                                                child: Text(
                                                  '$_unreadMessagesCount',
                                                  style: TextStyle(
                                                    color: Theme.of(context).primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _unreadMessagesCount > 0
                                                ? 'لديك $_unreadMessagesCount رسائل جديدة'
                                                : 'لا توجد رسائل جديدة',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // ثاني صف يحتوي على كاردين
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // كارد 3
                                Expanded(
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Colors.white,
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          'عدد الطلاب',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // كارد 4
                                Expanded(
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Colors.white,
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          'نسبة الحضور',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // خطة التلاوة
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('خطة التلاوة',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(height: 10),
                                    Column(
                                      children: ['من', 'إلى'].map((label) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: label,
                                              prefixIcon:
                                                  Icon(Icons.bookmark_border),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[100],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // خطة العلوم الشرعية
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('خطة العلوم الشرعية',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(height: 10),
                                    Column(
                                      children: [
                                        // المقرر - Dropdown
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child:
                                              DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              labelText: 'المقرر',
                                              prefixIcon:
                                                  Icon(Icons.bookmark_border),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[100],
                                            ),
                                            value:
                                                null, // القيمة الافتراضية (يمكنك تحديد قيمة افتراضية هنا)
                                            onChanged: (String? newValue) {
                                              // فعل شيء عندما يتغير المقرر المحدد
                                            },
                                            items: [
                                              'مقرر 1',
                                              'مقرر 2',
                                              'مقرر 3',
                                              'مقرر 4',
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        // المخطط
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'المخطط',
                                              prefixIcon:
                                                  Icon(Icons.bookmark_border),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[100],
                                            ),
                                          ),
                                        ),
                                        // المنفذ
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'المنفذ',
                                              prefixIcon:
                                                  Icon(Icons.bookmark_border),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[100],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('نسبة التنفيذ: 75%',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12),
                                              ),
                                              child: Text('تعديل',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12),
                                              ),
                                              child: Text('حذف',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // المخطط المتعرج
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                      'مخطط متعرج (هنا يمكن وضع رسم بياني)',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // نسب العلوم الشرعية
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                      'مخطط لنسب العلوم الشرعية (رسم بياني آخر)',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // أبرز الملاحظات والتوصيات
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('أبرز الملاحظات والتوصيات',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(height: 10),
                                    TextField(
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'اكتب الملاحظات هنا',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
