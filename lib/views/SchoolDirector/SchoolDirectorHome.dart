import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddTeacher.dart';
import 'package:al_furqan/views/SchoolDirector/DrawerSchoolDirector.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolManagerScreen extends StatefulWidget {
  const SchoolManagerScreen({super.key});

  @override
  State<SchoolManagerScreen> createState() => _SchoolManagerScreenState();
}

class _SchoolManagerScreenState extends State<SchoolManagerScreen>
    with UserDataMixin {
  final List<Map<String, String>> teachers = [
    {'name': 'أحمد محمد', 'level': 'الصف الأول'},
    {'name': 'منى خالد', 'level': 'الصف الثاني'},
    {'name': 'علي حسن', 'level': 'الصف الثالث'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading || user == null
            ? Text("جاري التحميل...")
            : Text('${user!.first_name} ${user!.last_name}'),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: user == null ? null : DrawerSchoolDirector(user: user),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text("فشل في جلب بيانات المستخدم"))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _buildStatCard(
                                  'عدد المعلمين', '15', Colors.blue)),
                          SizedBox(width: 10),
                          Expanded(
                              child: _buildStatCard(
                                  'نسبة الانضباط', '90%', Colors.green)),
                        ],
                      ),

                      SizedBox(height: 20),

                      // قائمة المعلمين
                      Text('قائمة المعلمين',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),

                      Expanded(
                        child: ListView.builder(
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(teachers[index]['name']!),
                                subtitle: Text(
                                    'المستوى: ${teachers[index]['level']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.info, color: Colors.blue),
                                      onPressed: () {
                                        // الانتقال إلى صفحة معلومات المعلم
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.orange),
                                      onPressed: () {
                                        // تعديل بيانات المعلم
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

      // زر إضافة معلم
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTeacherScreen()));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  // كارد إحصائي
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
