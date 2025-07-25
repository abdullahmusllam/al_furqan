import 'dart:math';

import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  List<UserModel?> users = [];
  List<UserModel?> teachers = [];

  List<UserModel?> activeTeacher = [];
  List<UserModel?> inactiveTeacher = [];

  int get teacherCount => activeTeacher.length;

  String? phoneN = perf.getString('phone_number');
  int? schoolID = perf.getInt('schoolId');

  UserProvider() {
    loadUserFromLocal();
  }

  Future<void> loadUsersFromFirebase() async {
    await userController.addToLocalOfFirebase();
    await loadUserFromLocal();
    await loadTeachers();
  }

  loadActiveTeacher() {
    activeTeacher.clear();
    List<UserModel> activeUsersList = teachers
        .where((user) => user != null && user.isActivate == 1)
        .cast<UserModel>()
        .toList();
    activeTeacher.addAll(activeUsersList);
  }

  loadInActiveTeacher() {
    inactiveTeacher.clear();
    List<UserModel> inactiveUsersList = teachers
        .where((user) => user != null && user.isActivate == 0)
        .cast<UserModel>()
        .toList();
    inactiveTeacher.addAll(inactiveUsersList);
  }

  Future<void> loadUserFromLocal() async {
    users.clear();
    List<UserModel?> usersList = await userController.loadUserBySchoolId();
    users.addAll(usersList);
    notifyListeners();
  }

  loadTeachers() async {
    teachers.clear();
    final db = await sqlDb.database;
    List<Map<String, dynamic>> request = await db.query('Users',
        where: 'roleID = ? AND schoolID = ?', whereArgs: [2, schoolID]);
    List<UserModel> teachersList =
        request.map((j) => UserModel.fromJson(j)).toList();
    teachers.addAll(teachersList);
    await loadActiveTeacher();
    await loadInActiveTeacher();
    notifyListeners();
  }
}

UserProvider userProvider = UserProvider();
