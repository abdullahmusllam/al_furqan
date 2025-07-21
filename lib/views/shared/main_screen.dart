import 'dart:developer';

import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/shared/Conversation_list.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final UserModel currentUser;

  const MainScreen({super.key, required this.currentUser});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<UserModel> parents = [];
  List<UserModel> teachers = [];
  bool isLoading = true;
  final swTotaol = Stopwatch();
  int _timedaley = 0;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      if (widget.currentUser.roleID == 1) {
        log('تحميل المستخدمين للمدير، schoolID: ${widget.currentUser.schoolID}');
        parents = (await fathersController
                .getFathersBySchoolId(widget.currentUser.schoolID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        log('تم تحميل ${parents.length} من أولياء الأمور : ${parents.map((p) => p.first_name).toList()}\n\n ');
        teachers =
            (await halagaController.getTeachers(widget.currentUser.schoolID!))
                .where((user) => user.user_id != null && user.user_id != 0)
                .toList();
        log('تم تحميل ${teachers.length} من المعلمين: ${teachers.map((t) => t.first_name).toList()}');
      } else if (widget.currentUser.roleID == 2) {
        parents = (await fathersController
                .getFathersByElhalagaId(widget.currentUser.elhalagatID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        debugPrint(
            'تم تحميل ${parents.length} من أولياء الأمور: ${parents.map((p) => p.first_name).toList()}');
      } else {
        debugPrint('دور المستخدم غير مدعوم: ${widget.currentUser.roleID}');
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المستخدمين: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل المستخدمين'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      swTotaol.start();
      return Scaffold(
        appBar: AppBar(
          title: Text('جاري التحميل...',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              SizedBox(height: 16),
              Text(
                'جاري تحميل البيانات...',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      swTotaol.stop();
      _timedaley = swTotaol.elapsedMilliseconds;
      log("The Time To Build Screen is : $_timedaley ms");
      return ConversationsScreen(
        currentUser: widget.currentUser,
        availableParents: parents,
        availableTeachers: teachers,
      );
    }
  }
}
