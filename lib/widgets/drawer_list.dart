// ignore: file_names

import 'package:flutter/material.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';

class DrawerList extends StatelessWidget {
  const DrawerList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'القائمة الرئيسية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('الصفحة الرئيسية'),
            onTap: () {
              // Navigate to home page
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('المدارس'),
            onTap: () {
              // Navigate to schools page
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('المعلمين'),
            onTap: () {
              // Navigate to teachers page
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('الطلاب'),
            onTap: () {
              // Navigate to students page
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('الإشعارات'),
            onTap: () {
              // Navigate to notifications page
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('المستخدمين'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
