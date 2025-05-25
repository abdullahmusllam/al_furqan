// ignore: file_names

import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Supervisor/show_all_schools.dart';
import 'package:al_furqan/views/Supervisor/show_all_teacher.dart';
import 'package:al_furqan/views/supervisor/verification_requests_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';

class DrawerList extends StatelessWidget {
  UserModel? user;
  DrawerList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              children: [
                CircleAvatar(
                    maxRadius: 40,
                    child: Center(
                      child: Text(
                        user!.first_name!.substring(0, 1),
                        style: TextStyle(fontSize: 45),
                      ),
                    )),
                Text(
                  '${user!.first_name} ${user!.middle_name} ${user!.last_name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          _createDrawerItem(
            icon: Icons.home,
            text: 'الصفحة الرئيسية',
            onTap: () {
              // Navigate to home page
              Navigator.of(context).pop();
            },
          ),
          _createDrawerItem(
            icon: Icons.school,
            text: 'المدارس',
            onTap: () {
              // Navigate to schools page
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => ShowAllSchools()));
            },
          ),
          _createDrawerItem(
            icon: Icons.person,
            text: 'المعلمين',
            onTap: () {
              // Navigate to teachers page
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => ShowAllTeacher()));
            },
          ),
          _createDrawerItem(
            icon: Icons.group,
            text: 'المستخدمين',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => UserManagementPage()),
              );
            },
          ),
          _createDrawerItem(
            icon: Icons.notifications,
            text: 'طلبات التحقق',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => VerificationRequestsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      GestureTapCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
