// ignore: file_names

import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
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
                  maxRadius: 45,
                  child: Icon(
                    CupertinoIcons.person_alt,
                    color: Colors.white,
                    size: 65,
                  ),
                ),
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
            },
          ),
          _createDrawerItem(
            icon: Icons.school,
            text: 'المدارس',
            onTap: () {
              // Navigate to schools page
            },
          ),
          _createDrawerItem(
            icon: Icons.person,
            text: 'المعلمين',
            onTap: () {
              // Navigate to teachers page
            },
          ),
          _createDrawerItem(
            icon: Icons.people,
            text: 'الطلاب',
            onTap: () {
              // Navigate to students page
              getNameAdmin();
            },
          ),
          _createDrawerItem(
            icon: Icons.group,
            text: 'المستخدمين',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
            },
          ),
          _createDrawerItem(
            icon: Icons.notifications,
            text: 'الإشعارات',
            onTap: () {
              // Navigate to notifications page
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

getNameAdmin() async {
  var admin = userController.users;
  UserModel adimnName;
  print(userController.users.isEmpty);
  if (admin.isNotEmpty) {
    admin.forEach(
      (element) {
        if (element.roleID == 0) {
          adimnName = element;
        }
        // Do nothing
      },
    );
  }
}
