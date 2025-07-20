import 'dart:developer';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/controllers/users_controller.dart';

class TeacherController {
  final SqlDb _sqlDb = SqlDb();
  List<UserModel> teachers = [];

  Future<void> getTeachers() async {
    try {
      print("TeacherController: Fetching all teachers...");
      List<Map> response =
          await _sqlDb.readData("SELECT * FROM Users WHERE roleID = 2");
      print(
          "TeacherController: Raw data received - ${response.length} records");

      teachers.clear();
      teachers.addAll(mapResponseToUserModel(response));
      print("Teachers fetched (Local): ${teachers.length} teachers");
      teachers.forEach((e) {
        print(
            "Teacher: ${e.user_id}, RoleID: ${e.roleID}, Name: ${e.first_name}, schoolID: ${e.schoolID}");
      });
    } catch (e) {
      log("Error fetching teachers: $e");
      teachers.clear();
      rethrow;
    }
  }

  Future<void> getTeachersBySchoolID(int schoolID) async {
    try {
      print("TeacherController: Fetching teachers for schoolID $schoolID...");
      List<Map> response = await _sqlDb.readData(
          "SELECT * FROM Users WHERE roleID = 2 AND schoolID = $schoolID");
      print(
          "TeacherController: Raw response for schoolID $schoolID - ${response.length} records");

      teachers.clear();

      teachers.addAll(mapResponseToUserModel(response));
      print(
          "Teachers fetched for schoolID $schoolID: ${teachers.length} teachers");

      if (teachers.isEmpty) {
        log("WARNING: No teachers found for schoolID $schoolID");
      } else {
        teachers.forEach((e) {
          print(
              "Teacher: ${e.user_id}, RoleID: ${e.roleID}, Name: ${e.first_name}, schoolID: ${e.schoolID}, ElhalagatID: ${e.elhalagatID}");
        });
      }
    } catch (e) {
      log("Error fetching teachers for schoolID $schoolID: $e");
      teachers.clear();
      rethrow;
    }
  }

  List<UserModel> mapResponseToUserModel(List<Map> response) {
    print("TeacherController: Mapping ${response.length} records to UserModel");

    if (response.isEmpty) {
      print("TeacherController: Response is empty, returning empty list");
      return [];
    }

    return response.map((data) {
      return UserModel(
        user_id: data['user_id'] as String?,
        first_name: data['first_name']?.toString(),
        middle_name: data['middle_name']?.toString(),
        grandfather_name: data['grandfather_name']?.toString(),
        last_name: data['last_name']?.toString(),
        phone_number: int.tryParse(data['phone_number'].toString()) ?? 0,
        telephone_number:
            int.tryParse(data['telephone_number'].toString()) ?? 0,
        email: data['email']?.toString(),
        password: (data['password']) ?? 0,
        roleID: data['roleID'] as int?,
        schoolID: data['schoolID'] as int?,
        elhalagatID: data['ElhalagatID'] as String?,
        date: data['date']?.toString(),
        isActivate: data['isActivate'] as int?,
      );
    }).toList();
  }

  // Method to add a new teacher
  Future<void> addTeacher(UserModel teacherModel) async {
    // Ensure the role is set to teacher (roleID = 2)
    teacherModel.roleID = 2;

    // Use the userController to add the user with teacher role
    await userController.addUser(teacherModel, 1);

    // Refresh the teachers list after adding
    if (teacherModel.schoolID != null) {
      await getTeachersBySchoolID(teacherModel.schoolID!);
    } else {
      await getTeachers();
    }

    print(
        "Teacher added successfully: ${teacherModel.first_name} ${teacherModel.last_name}");
  }
}

TeacherController teacherController = TeacherController();
