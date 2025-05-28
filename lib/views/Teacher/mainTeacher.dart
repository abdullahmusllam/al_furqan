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
  
  // Helper method to build stat cards in the header
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    int? badgeCount,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build plan fields for Quran plans
  Widget _buildPlanField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Helper method to build info cards
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: title == 'نسبة الحضور' ? 0.85 : 0.75,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
  
  
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
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          // زر تحديث البيانات
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                updateNotificationCount();
                // استدعاء دالة تحديث البيانات مباشرة (ستقوم بتحديث حالة التحميل داخلياً)
                fetchUserData().then((_) {
                  // تحديث عدد الإشعارات عند الضغط على زر التحديث
                  updateNotificationCount();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text('تم تحديث البيانات بنجاح'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                });
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              tooltip: 'تحديث البيانات',
            ),
          ),
          // زر تسجيل الخروج
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('تسجيل الخروج'),
                    content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('تسجيل الخروج'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'تسجيل الخروج',
            ),
          ),
        ],
        title: isLoading || user == null
            ? Row(
                children: [
                  SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text("جاري التحميل..."),
                ],
              )
            : Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Text(
                      '${user!.first_name != null && user!.first_name!.isNotEmpty ? user!.first_name![0] : ''}${user!.last_name != null && user!.last_name!.isNotEmpty ? user!.last_name![0] : ''}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${user!.first_name} ${user!.last_name}',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ],
              ),
      ),
      drawer: user == null ? null : DrawerTeacher(),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("جاري تحميل البيانات...", style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            )
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 70, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        "فشل في جلب بيانات المستخدم",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => fetchUserData(),
                        icon: Icon(Icons.refresh),
                        label: Text("إعادة المحاولة"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                )
              : user!.elhalagatID == null || user!.elhalagatID == 0
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => fetchUserData(),
                              icon: Icon(Icons.refresh),
                              label: Text("تحديث البيانات"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dashboard Header
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'لوحة تحكم المعلم',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'مرحباً بك في نظام إدارة الحلقات',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          title: 'اسم الحلقة',
                                          value: 'حلقة الفرقان',
                                          icon: Icons.class_,
                                          color: Colors.white,
                                          textColor: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          title: 'الإشعارات',
                                          value: '$_unreadMessagesCount رسائل جديدة',
                                          icon: Icons.notifications_active,
                                          color: Colors.white,
                                          textColor: Theme.of(context).primaryColor,
                                          badgeCount: _unreadMessagesCount,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            
                            // أول صف يحتوي على كاردين
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // كارد 1 - عدد الطلاب
                                Expanded(
                                  child: _buildInfoCard(
                                    title: 'عدد الطلاب',
                                    value: '12',
                                    icon: Icons.people,
                                    color: Colors.blue,
                                    context: context,
                                  ),
                                ),
                                SizedBox(width: 16),
                                // كارد 2 - نسبة الحضور
                                Expanded(
                                  child: _buildInfoCard(
                                    title: 'نسبة الحضور',
                                    value: '85%',
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                    context: context,
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.menu_book, color: Colors.green),
                                            ),
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Text('خطة التلاوة',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey[800])),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.trending_up, color: Colors.green, size: 16),
                                              SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  'نسبة التنفيذ: 80%',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('المخطط',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.grey[800])),
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildPlanField(
                                                  label: 'من',
                                                  value: 'سورة البقرة - الآية 1',
                                                  icon: Icons.arrow_right,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: _buildPlanField(
                                                  label: 'إلى',
                                                  value: 'سورة البقرة - الآية 20',
                                                  icon: Icons.arrow_left,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('المنفذ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.grey[800])),
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildPlanField(
                                                  label: 'من',
                                                  value: 'سورة البقرة - الآية 1',
                                                  icon: Icons.arrow_right,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: _buildPlanField(
                                                  label: 'إلى',
                                                  value: 'سورة البقرة - الآية 16',
                                                  icon: Icons.arrow_left,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.edit),
                                          label: Text('تعديل'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                        ),
                                      ],
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.school, color: Colors.purple),
                                            ),
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Text('خطة العلوم الشرعية',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.trending_up, color: Colors.purple, size: 16),
                                              SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  'نسبة التنفيذ: 75%',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // المقرر - Dropdown
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.book, size: 18, color: Colors.purple),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text('المقرر',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.grey[800])),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.purple.withOpacity(0.3)),
                                            ),
                                            child: DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                border: InputBorder.none,
                                                hintText: 'اختر المقرر',
                                              ),
                                              value: 'مقرر 1',
                                              onChanged: (String? newValue) {},
                                              items: [
                                                'مقرر 1',
                                                'مقرر 2',
                                                'مقرر 3',
                                                'مقرر 4',
                                              ].map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              icon: Icon(Icons.arrow_drop_down, color: Colors.purple),
                                              isExpanded: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // المخطط والمنفذ
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.assignment, size: 18, color: Colors.blue),
                                                    SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text('المخطط',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                              color: Colors.grey[800])),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12),
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                                  ),
                                                  child: Text(
                                                    'الفصل الأول - الدرس الثالث',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.check_circle, size: 18, color: Colors.green),
                                                    SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text('المنفذ',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                              color: Colors.grey[800])),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12),
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                                                  ),
                                                  child: Text(
                                                    'الفصل الأول - الدرس الثاني',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // شريط التقدم
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('نسبة التقدم',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700])),
                                            Text('75%',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.purple)),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: 0.75,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // أزرار الإجراءات
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.delete_outline),
                                          label: Text('حذف'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.edit),
                                          label: Text('تعديل'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // أبرز الملاحظات والتوصيات
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.lightbulb, color: Colors.amber),
                                        ),
                                        SizedBox(width: 10),
                                        Text('أبرز الملاحظات والتوصيات',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                      ),
                                      child: TextField(
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          hintText: 'اكتب الملاحظات والتوصيات هنا...',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                          hintStyle: TextStyle(color: Colors.grey[400]),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.save),
                                          label: Text('حفظ الملاحظات'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber,
                                            foregroundColor: Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // الطلاب المتميزون
                            Container(
                              margin: EdgeInsets.only(top: 20, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.star, color: Colors.orange),
                                            ),
                                            SizedBox(width: 10),
                                            Text('الطلاب المتميزون',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                          ],
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.people, size: 16),
                                          label: Text('عرض الكل'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: 100,
                                          margin: EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.orange.withOpacity(0.1),
                                                child: Text(
                                                  'ط${index + 1}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text('الطالب ${index + 1}',
                                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text('95%', style: TextStyle(color: Colors.green, fontSize: 12)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
