// ignore: file_names

import 'package:al_furqan/views/SchoolDirector/TeachersAttendance.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';

class DrawerTeacher extends StatelessWidget {
  const DrawerTeacher({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // قسم البروفايل
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green.shade700, // لون الخلفية
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 65,
                  height: 65,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/pictures/profile.jpg'), // ضع صورة داخل assets
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'محمد أحمد', // اسم المستخدم
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'مشرف الحلقة', // نوع العمل
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // القوائم
          ListTile(
              leading: Icon(Icons.people),
              title: Text('تحضير الطلاب'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceScreen(),
                  ),
                );
              }),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('إدارة الأنشطة'),
            onTap: () {
              // الانتقال إلى شاشة الأنشطة
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('المناهج'),
            onTap: () {
              // الانتقال إلى شاشة المناهج
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('الإعدادات'),
            onTap: () {
              // الانتقال إلى شاشة الإعدادات
            },
          ),
          Spacer(),
          Divider(),
          // تسجيل الخروج
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('تسجيل الخروج'),
            onTap: () {
              // تنفيذ عملية تسجيل الخروج
            },
          ),
        ],
      ),
    );
  }
}
