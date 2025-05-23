import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';

class TeacherController {
  final SqlDb _sqlDb = SqlDb();
  List<UserModel> teachers = [];

  Future<void> getTeachers() async {
    try {
      List<Map> response =
          await _sqlDb.readData("SELECT * FROM Users WHERE roleID = 2");
      teachers.clear();
<<<<<<< HEAD
      teachers.addAll(_mapResponseToUserModel(response));
      print("Teachers fetched (Local): ${teachers.length} teachers");
      teachers.forEach((e) {
        print("Teacher: ${e.user_id}, RoleID: ${e.roleID}, Name: ${e.first_name}, schoolID: ${e.schoolID}");
=======
      teachers.addAll(mapResponseToUserModel(response));
      print("Teachers fetched (Local): ${teachers.length} teachers");
      teachers.forEach((e) {
        print(
            "Teacher: ${e.user_id}, RoleID: ${e.roleID}, Name: ${e.first_name}, schoolID: ${e.schoolID}");
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
      });
    } catch (e) {
      print("Error fetching teachers: $e");
      teachers.clear();
      rethrow;
    }
  }

  Future<void> getTeachersBySchoolID(int schoolID) async {
    try {
      List<Map> response = await _sqlDb.readData(
          "SELECT * FROM Users WHERE roleID = 2 AND schoolID = $schoolID");
      teachers.clear();
<<<<<<< HEAD
      teachers.addAll(_mapResponseToUserModel(response));
      print("Teachers fetched for schoolID $schoolID: ${teachers.length} teachers");
      teachers.forEach((e) {
        print("Teacher: ${e.user_id}, RoleID: ${e.roleID}, Name: ${e.first_name}, schoolID: ${e.schoolID}");
=======
      teachers.addAll(mapResponseToUserModel(response));
      print(
          "Teachers fetched for schoolID $schoolID: ${teachers.length} teachers");
      teachers.forEach((e) {
        print(
            "Teacher: ${e.user_id}, RoleID: ${e.roleID}, Name: ${e.first_name}, schoolID: ${e.schoolID}");
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
      });
    } catch (e) {
      print("Error fetching teachers for schoolID $schoolID: $e");
      teachers.clear();
      rethrow;
    }
  }

<<<<<<< HEAD
  List<UserModel> _mapResponseToUserModel(List<Map> response) {
=======
  List<UserModel> mapResponseToUserModel(List<Map> response) {
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
    return response.map((data) {
      return UserModel(
        user_id: data['user_id'] as int?,
        first_name: data['first_name']?.toString(),
        middle_name: data['middle_name']?.toString(),
        grandfather_name: data['grandfather_name']?.toString(),
        last_name: data['last_name']?.toString(),
        phone_number: int.tryParse(data['phone_number'].toString()) ?? 0,
<<<<<<< HEAD
        telephone_number: int.tryParse(data['telephone_number'].toString()) ?? 0,
=======
        telephone_number:
            int.tryParse(data['telephone_number'].toString()) ?? 0,
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
        email: data['email']?.toString(),
        password: int.tryParse(data['password'].toString()) ?? 0,
        roleID: data['roleID'] as int?,
        schoolID: data['schoolID'] as int?,
        date: data['date']?.toString(),
        isActivate: data['isActivate'] as int?,
      );
    }).toList();
  }
}

<<<<<<< HEAD
TeacherController teacherController = TeacherController();
=======
TeacherController teacherController = TeacherController();
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
