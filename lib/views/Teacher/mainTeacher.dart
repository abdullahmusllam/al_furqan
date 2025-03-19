import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Teacher/DrawerTeacher.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Teacher/preparingStudents.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with UserDataMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: isLoading || user == null
            ? Text("جاري التحميل...")
            : Text('${user!.first_name} ${user!.last_name}'),
      ),
      drawer: user == null ? null : DrawerTeacher(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text("فشل في جلب بيانات المستخدم"))
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
                            // كارد 2
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
                                      'اسم المعلم',
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
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: DropdownButtonFormField<String>(
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
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
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
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                          ),
                                          child: Text('تعديل',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                          ),
                                          child: Text('حذف',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
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
                              child: Text('مخطط متعرج (هنا يمكن وضع رسم بياني)',
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
                                      borderRadius: BorderRadius.circular(10),
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
