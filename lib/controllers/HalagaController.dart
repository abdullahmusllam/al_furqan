import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];

  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

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

  Future<void> addHalaga(HalagaModel halagaData, int type) async {
    try {
      final db = await sqlDb.database;
      if (type == 1) {
        halagaData.halagaID =
            await someController.newId("Elhalagat", "halagaID");
        // إضافة الحلقة
        if (await isConnected()) {
          halagaData.isSync = 1;
          await firebasehelper.addHalga(halagaData);
          await db.insert('Elhalagat', halagaData.toMap());
        } else {
          halagaData.isSync = 0;
          await db.insert('Elhalagat', halagaData.toMap());
        }
      } else {
        await db.insert('Elhalagat', halagaData.toMap());
      }
    } catch (e) {
      print("خطأ في إضافة الحلقة: $e");
      rethrow;
    }
  }

  Future<void> updateHalaga(HalagaModel halaga, int type) async {
    final db = await sqlDb.database;
    try {
      // التحقق من صحة معرف الحلقة
      if (halaga.halagaID == null) {
        throw Exception("معرف الحلقة غير متوفر");
      }

      // التحقق من NumberStudent
      halaga.NumberStudent ??= 0;

      if (type == 1) {
        /// سوف تذهبىالبيانات الى الفايربيس
        if (await isConnected()) {
          halaga.isSync = 1;
          await firebasehelper.updateHalaga(halaga);
          // 1. تحديث بيانات الحلقة في SQLite
          await db.update(
            'Elhalagat',
            halaga.toMap(),
            where: 'halagaID = ?',
            whereArgs: [halaga.halagaID],
          );
        } else {
          halaga.isSync = 0;
          // عند عدم وجود اتصال، نخزن البيانات محلياً فقط
          await db.update(
            'Elhalagat',
            halaga.toMap(),
            where: 'halagaID = ?',
            whereArgs: [halaga.halagaID],
          );
        }
      } else {
        await db.update(
          'Elhalagat',
          halaga.toMap(),
          where: 'halagaID = ?',
          whereArgs: [halaga.halagaID],
        );
      }
    } catch (e) {
      print("خطأ في تحديث الحلقة: $e");
      rethrow;
    }
  }

  updateTeacherAssignment(int teacherId, int halagaId) async {
    try {
      if (await isConnected()) {
        ///الغاء ارتباط المعلم
        await firebasehelper.teacherCancel(halagaId);
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL, isSync = 1 WHERE ElhalagatID = $halagaId AND roleID = 2");

        /// تعيين معلم جديد
        await firebasehelper.newTeacher(halagaId, teacherId);
        await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = $halagaId, isSync = 1 WHERE user_id = $teacherId AND roleID = 2",
        );
      } else {
        ///الغاء ارتباط المعلم
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL, isSync = 0 WHERE ElhalagatID = $halagaId AND roleID = 2");

        /// تعيين معلم جديد
        await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = $halagaId, isSync = 0 WHERE user_id = $teacherId AND roleID = 2",
        );
      }
    } catch (e) {
      print('error===$e');
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

  Future<String> getTeacher(int halagaId) async {
    try {
      final db = await sqlDb.database;
      final result = await db.query(
        'Users',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final firstName = result.first['first_name'] ?? '';
        final middleName = result.first['middle_name'] ?? '';
        final lastName = result.first['last_name'] ?? '';

        final fullName = '$firstName $middleName $lastName'.trim();
        return fullName.isEmpty ? 'لا يوجد معلم للحلقة' : fullName;
      } else {
        return 'لا يوجد معلم للحلقة';
      }
    } catch (e) {
      print('خطأ في جلب اسم المعلم: $e');
      return 'لا يوجد معلم للحلقة';
    }
  }

  getHalagatFromFirebase() async {
    try {
      if (await isConnected()) {
        final snapshot =
            await FirebaseFirestore.instance.collection('Elhalaga').get();
        for (var doc in snapshot.docs) {
          HalagaModel halaga = HalagaModel.fromJson(doc.data());
          bool exists = await _sqlDb.checkIfitemExists(
              'Elhalagat', halaga.halagaID!, 'halagaID');
          if (exists) {
            await updateHalaga(halaga, 0);
          } else {
            await addHalaga(halaga, 0);
          }
        }
      }
    } catch (e) {
      print('خطأ في جلب الحلقات من Firebase: $e');
      return [];
    }
  }
}

HalagaController halagaController = HalagaController();
