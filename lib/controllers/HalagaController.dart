import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];

  Future<List<HalagaModel>> getData(int id) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT Elhalagat.halagaID, Elhalagat.Name, Elhalagat.NumberStudent, Elhalagat.SchoolID, Users.first_name, Users.last_name FROM Elhalagat LEFT JOIN Users ON Users.ElhalagatID = Elhalagat.halagaID WHERE Elhalagat.SchoolID = $id");

    List<HalagaModel> halagaData = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        int? halagaID = data[i]['halagaID'] as int?;
        String name = data[i]['Name'] ?? 'اسم غير متوفر';
        int numberStudent =
            int.tryParse(data[i]['NumberStudent'].toString()) ?? 0;
        int? schoolID = data[i]['SchoolID'] as int?;

        String? teacherName =
            (data[i]['first_name'] != null && data[i]['last_name'] != null)
                ? "${data[i]['first_name']} ${data[i]['last_name']}"
                : 'لا يوجد معلم للحلقة';

        halagaData.add(HalagaModel(
          halagaID: halagaID,
          Name: name,
          NumberStudent: numberStudent,
          SchoolID: schoolID,
          TeacherName: teacherName,
        ));
      }
    }
    print("Fetched halaga data: ${data.length}");
    return halagaData;
  }

  Future<List<UserModel>> getTeachers(int schoolID) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT userID, first_name, last_name, roleID, schoolID FROM Users WHERE schoolID = $schoolID AND roleID = 2");

    List<UserModel> teachers = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        int? userID = data[i]['userID'] as int?;
        String firstName = data[i]['first_name'] ?? 'اسم غير متوفر';
        String lastName = data[i]['last_name'] ?? 'اسم غير متوفر';
        int? roleID = data[i]['roleID'] as int?;
        int? schoolID = data[i]['schoolID'] as int?;

        teachers.add(UserModel(
          user_id: userID,
          first_name: firstName,
          last_name: lastName,
          roleID: roleID,
          schoolID: schoolID,
        ));
      }
    }
    print("Fetched teachers: ${teachers.length}");
    return teachers;
  }

  Future<void> addHalaga(HalagaModel halagaData) async {
    try {
      halagaData.halagaID = await someController.newId("Elhalagat", "halagaID");
      int response = await _sqlDb.insertData(
          "INSERT INTO Elhalagat (halagaID, SchoolID, Name, NumberStudent) VALUES (${halagaData.halagaID}, ${halagaData.SchoolID}, '${halagaData.Name}', 0)");
      print("Added halaga, response: $response");
      if (response == 0) {
        throw Exception("Failed to add halaga");
      }
    } catch (e) {
      print("Error adding halaga: $e");
      rethrow;
    }
  }

  Future<void> updateHalaga(HalagaModel halaga, int? teacherId) async {
    try {
      // تحديث بيانات الحلقة
      int response = await _sqlDb.updateData(
          "UPDATE Elhalagat SET Name = '${halaga.Name}', NumberStudent = ${halaga.NumberStudent} WHERE halagaID = ${halaga.halagaID}");
      print("Updated halaga ${halaga.halagaID}, response: $response");
      if (response == 0) {
        throw Exception("Failed to update halaga ${halaga.halagaID}");
      }

      // إلغاء ارتباط المعلم الحالي (إذا كان موجودًا)
      await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = ${halaga.halagaID} AND roleID = 2");

      // ربط المعلم الجديد (إذا تم اختياره)
      if (teacherId != null) {
        int teacherResponse = await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = ${halaga.halagaID} WHERE userID = $teacherId AND roleID = 2");
        print("Assigned teacher $teacherId to halaga ${halaga.halagaID}, response: $teacherResponse");
        if (teacherResponse == 0) {
          throw Exception("Failed to assign teacher $teacherId to halaga ${halaga.halagaID}");
        }
      }
    } catch (e) {
      print("Error updating halaga: $e");
      rethrow;
    }
  }

  Future<void> deleteHalaga(int halagaID) async {
    try {
      // إلغاء ارتباط الطلاب والمعلمين
      await _sqlDb.updateData(
          "UPDATE Students SET ElhalagatID = NULL WHERE ElhalagatID = $halagaID");
      await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = $halagaID");

      // حذف الحلقة
      int response = await _sqlDb.deleteData(
          "DELETE FROM Elhalagat WHERE halagaID = $halagaID");
      print("Deleted halaga $halagaID, response: $response");
      if (response == 0) {
        throw Exception("Failed to delete halaga $halagaID");
      }
    } catch (e) {
      print("Error deleting halaga: $e");
      rethrow;
    }
  }

  Future<int> getStudentCount(int halagaID) async {
    try {
      final count = await _sqlDb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = $halagaID");
      return count[0]['count'] as int;
    } catch (e) {
      print("Error getting student count: $e");
      return 0;
    }
  }
}

HalagaController halagaController = HalagaController();