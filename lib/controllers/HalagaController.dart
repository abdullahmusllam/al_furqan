import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];

  Future<List<HalagaModel>> getData(int id) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT E.halagaID, E.Name, E.NumberStudent, E.SchoolID, U.first_name, U.last_name, U.user_id "
        "FROM Elhalagat E "
        "LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 "
        "WHERE E.SchoolID = $id");

    print("--------------------------------------------");
    print("بيانات الحلقات التي تم جلبها من قاعدة البيانات:");
    for (var row in data) {
      print("halagaID: ${row['halagaID']}, Name: ${row['Name']}");
    }
    print("--------------------------------------------");

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
    print("تم جلب بيانات الحلقات: ${data.length}");
    return halagaData;
  }

  Future<List<UserModel>> getTeachers(int schoolID) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT user_id, first_name, last_name, roleID, schoolID FROM Users WHERE schoolID = $schoolID AND roleID = 2");

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
    print("تم جلب بيانات المعلمين: ${teachers.length}");
    return teachers;
  }

  Future<void> addHalaga(HalagaModel halagaData) async {
    try {
      halagaData.halagaID = await someController.newId("Elhalagat", "halagaID");

      // إضافة الحلقة
      int response = await _sqlDb.insertData(
          "INSERT INTO Elhalagat (halagaID, SchoolID, Name, NumberStudent)\n"
          " VALUES\n"
          " (${halagaData.halagaID}, ${halagaData.SchoolID}, '${halagaData.Name}', ${halagaData.NumberStudent})");
      print("تمت إضافة الحلقة، الاستجابة: $response");
      if (response == 0) {
        throw Exception("فشل في إضافة الحلقة");
      }
    } catch (e) {
      print("خطأ في إضافة الحلقة: $e");
      rethrow;
    }
  }

  Future<void> updateHalaga(HalagaModel halaga, int? teacherId) async {
    try {
      // التحقق من صحة معرف الحلقة
      if (halaga.halagaID == null) {
        throw Exception("معرف الحلقة غير متوفر");
      }

      // التحقق من قيمة NumberStudent وتعيين قيمة افتراضية إذا كانت null
      int numberStudent = halaga.NumberStudent ?? 0;

      // تحديث بيانات الحلقة
      int response = await _sqlDb.updateData(
          "UPDATE Elhalagat SET Name = '${halaga.Name}', NumberStudent = $numberStudent WHERE halagaID = ${halaga.halagaID}");
      print("تم تحديث الحلقة ${halaga.halagaID}، الاستجابة: $response");
      if (response == 0) {
        throw Exception("فشل في تحديث الحلقة ${halaga.halagaID}");
      }

      try {
        // إلغاء ارتباط المعلم الحالي (إذا كان موجودًا)
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = ${halaga.halagaID} AND roleID = 2");
      } catch (e) {
        print("خطأ في إلغاء ارتباط المعلم الحالي: $e");
        // لا نرمي استثناء هنا لكي تستمر العملية
      }

      // ربط المعلم الجديد (إذا تم اختياره)
      if (teacherId != null) {
        try {
          int teacherResponse = await _sqlDb.updateData(
              "UPDATE Users SET ElhalagatID = ${halaga.halagaID} WHERE user_id = $teacherId AND roleID = 2");
          print(
              "تم تعيين المعلم $teacherId للحلقة ${halaga.halagaID}، الاستجابة: $teacherResponse");

          // نتحقق من نجاح العملية لكن لا نرمي استثناء هنا
          if (teacherResponse == 0) {
            print(
                "تحذير: تم تحديث الحلقة لكن قد تكون هناك مشكلة في تعيين المعلم");
          }
        } catch (e) {
          print("خطأ في تعيين المعلم الجديد: $e");
          // لا نرمي استثناء هنا لكي تستمر العملية
        }
      }
    } catch (e) {
      print("خطأ في تحديث الحلقة: $e");
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
      int response = await _sqlDb
          .deleteData("DELETE FROM Elhalagat WHERE halagaID = $halagaID");
      print("تم حذف الحلقة $halagaID، الاستجابة: $response");
      if (response == 0) {
        throw Exception("فشل في حذف الحلقة $halagaID");
      }
    } catch (e) {
      print("خطأ في حذف الحلقة: $e");
      rethrow;
    }
  }

  Future<int> getStudentCount(int halagaID) async {
    try {
      final count = await _sqlDb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = $halagaID");
      return count[0]['count'] as int;
    } catch (e) {
      print("خطأ في جلب عدد الطلاب: $e");
      return 0;
    }
  }

  Future<String> getTeacherNameByID(int? teacherID) async {
    if (teacherID == null) {
      return 'لا يوجد معلم للحلقة';
    }

    try {
      var teacherData = await _sqlDb.readData(
          'SELECT first_name, last_name FROM Users WHERE user_id = $teacherID AND roleID = 2');

      if (teacherData.isEmpty) {
        return 'معلم غير موجود';
      }

      return "${teacherData[0]['first_name']} ${teacherData[0]['last_name']}";
    } catch (e) {
      print('خطأ في جلب بيانات المعلم: $e');
      return 'خطأ في جلب بيانات المعلم';
    }
  }

  Future<HalagaModel?> getHalqaDetails(int halagaID) async {
    try {
      var response = await _sqlDb.readData(
          'SELECT E.*, U.first_name, U.last_name, U.user_id as TeacherID '
          'FROM Elhalagat E '
          'LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 '
          'WHERE E.halagaID = $halagaID');

      if (response.isEmpty) {
        print('لا توجد بيانات للحلقة بالمعرف: $halagaID');
        return null;
      }

      var halagaData = response[0];
      String teacherName = 'لا يوجد معلم للحلقة';

      // إذا كان هناك معلم مرتبط بالحلقة
      if (halagaData['first_name'] != null && halagaData['last_name'] != null) {
        teacherName = "${halagaData['first_name']} ${halagaData['last_name']}";
      }

      HalagaModel halaga = HalagaModel(
        halagaID: halagaData['halagaID'],
        Name: halagaData['Name'],
        SchoolID: halagaData['SchoolID'],
        NumberStudent: halagaData['NumberStudent'] != null
            ? int.parse(halagaData['NumberStudent'].toString())
            : 0,
        TeacherName: teacherName,
      );

      print('تم جلب بيانات الحلقة بنجاح: ${halaga.Name}');
      return halaga;
    } catch (e) {
      print('خطأ في جلب بيانات الحلقة: $e');
      return null;
    }
  }

  Future<List<HalagaModel>> getHalagaByHalagaID(int halagaID) async {
    List<Map<String, dynamic>> halagaData = await _sqlDb
        .readData("SELECT * FROM Elhalagat WHERE halagaID = $halagaID");
    return halagaData.map((halaga) => HalagaModel.fromJson(halaga)).toList();
  }
}

HalagaController halagaController = HalagaController();
