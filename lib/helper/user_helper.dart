import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/StudentController.dart';
import '../controllers/TeacherController.dart';

class UserHelper {
  static Future<UserModel?> getDataByPref() async {
    final pref = await SharedPreferences.getInstance();
    String? phoneUser = pref.getString('phoneUser');
    if (phoneUser == null) {
      print("No phone number stored in SharedPreferences");
      return null;
    }

    await userController.getDataUsers();
    print("userList empty: ${userController.users.isEmpty}");

    for (var element in userController.users) {
      // تحويل phone_number إلى سلسلة نصية لتجنب مشاكل المقارنة
      if (phoneUser == element.phone_number?.toString()) {
        print(
            "User found: ${element.first_name} ${element.last_name}, schoolID: ${element.schoolID}");
        return element;
      }
    }
    print("No user found for phone number: $phoneUser");
    return null;
  }
}

mixin UserDataMixin<T extends StatefulWidget> on State<T> {
  UserModel? user;
  bool _isLoading = true;
  int? schoolID; // متغير لتخزين schoolID

  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    print("UserDataMixin: fetchUserData started");
    setState(() => _isLoading = true);
    user = await UserHelper.getDataByPref();

    if (user != null && user!.schoolID != null) {
      schoolID = user!.schoolID!;
      print("UserDataMixin: schoolID set to: $schoolID");
      print("UserDataMixin: elhalagat set to: ${user!.elhalagatID}");

      await _refreshData(); // ← await هنا مهمة
    } else {
      print(
          "UserDataMixin: User or schoolID is null - user: $user, schoolID: ${user?.schoolID}");
    }

    setState(() => _isLoading = false);
    print("UserDataMixin: fetchUserData completed, isLoading set to false");
  }

  Future<void> _refreshData() async {
    print("UserDataMixin: _refreshData started");
    if (user == null || user!.schoolID == null) {
      print("UserDataMixin: User or schoolID is null, cannot refresh data");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: بيانات المستخدم أو المدرسة غير متوفرة')),
      );
      return;
    }

    try {
      print("UserDataMixin: Fetching teachers for schoolID: ${user!.schoolID}");
      await teacherController.getTeachersBySchoolID(user!.schoolID!);
      print(
          "UserDataMixin: Teacher count after refresh: ${teacherController.teachers.length}");
          
      // تحديث بيانات المستخدم الحالي من قائمة المعلمين المحدثة
      if (user!.roleID == 2) { // إذا كان المستخدم معلم
        for (var teacher in teacherController.teachers) {
          if (teacher.user_id == user!.user_id) {
            // تحديث بيانات المستخدم بالبيانات المحدثة من قاعدة البيانات
            user = teacher;
            print("UserDataMixin: Updated user data from teachers list. ElhalagatID: ${user!.elhalagatID}");
            break;
          }
        }
      }

      print("UserDataMixin: Fetching students for schoolID: ${user!.schoolID}");
      await studentController.getSchoolStudents(user!.schoolID!);
      print(
          "UserDataMixin: Student count after refresh: ${studentController.students.length}");

      setState(() {});
      print("UserDataMixin: State updated after data refresh");
    } catch (e) {
      print("UserDataMixin: Error refreshing data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
}
