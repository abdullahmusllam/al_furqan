import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddTeacher.dart';
import 'package:al_furqan/views/SchoolDirector/DrawerSchoolDirector.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolManagerScreen extends StatefulWidget {
  const SchoolManagerScreen({super.key});

  @override
  State<SchoolManagerScreen> createState() => _SchoolManagerScreenState();
}

class _SchoolManagerScreenState extends State<SchoolManagerScreen> {
  final List<Map<String, String>> teachers = [
    {'name': 'أحمد محمد', 'level': 'الصف الأول'},
    {'name': 'منى خالد', 'level': 'الصف الثاني'},
    {'name': 'علي حسن', 'level': 'الصف الثالث'},
  ];

  UserModel? user;

  @override
  void initState() {
    super.initState();
    getDataByPref();
  }

  getDataByPref() async {
    final pref = await SharedPreferences.getInstance();
    String? phoneUser = pref.getString('phoneUser');
    // int? roleId = pref.getInt('role_id');
    // int? isActivate = pref.getInt('isActivate');

    userController.getDataUsers();
    setState(() {});
    userController.users.forEach(
      (element) {
        if (int.tryParse(phoneUser!) == element.phone_number) {
          user = element;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user!.first_name} ${user!.last_name}')),
      drawer: DrawerSchoolDirector(user: user!),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الكروت الرئيسية
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('عدد المعلمين', '15', Colors.blue)),
                SizedBox(width: 10),
                Expanded(
                    child:
                        _buildStatCard('نسبة الانضباط', '90%', Colors.green)),
              ],
            ),

            SizedBox(height: 20),

            // قائمة المعلمين
            Text('قائمة المعلمين',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            Expanded(
              child: ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(teachers[index]['name']!),
                      subtitle: Text('المستوى: ${teachers[index]['level']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blue),
                            onPressed: () {
                              // الانتقال إلى صفحة معلومات المعلم
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
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
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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
