import 'dart:ffi';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];

  gitData(int id) async {
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

        // تحقق إذا كانت أسماء المعلم موجودة أو ضع null
        String? teacherName =
            (data[i]['first_name'] != null && data[i]['last_name'] != null)
                ? "${data[i]['first_name']} ${data[i]['last_name']}"
                : 'لا يوجد معلم للحلقة';

        // إنشاء نموذج الحلقة مع اسم المدرس
        halagaData.add(HalagaModel(
          halagaID: halagaID,
          Name: name,
          NumberStudent: numberStudent,
          SchoolID: schoolID,
          TeacherName: teacherName, // إضافة اسم المدرس أو null
        ));
      }
    }
    print(data);
    return halagaData;
  }

  gitTecher(int SchoolID) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT Users.userID, Users.first_name, Users.last_name, Users.roleID, Users.SchoolID FROM Users WHERE Users.SchoolID = ${SchoolID} AND Users.roleID = 2");

    List<UserModel> Techer = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        int? userID = data[i]['userID'] as int?;
        String firstName = data[i]['first_name'] ?? 'اسم غير متوفر';
        String lastName = data[i]['last_name'] ?? 'اسم غير متوفر';
        int? roleID = data[i]['roleID'] as int?;
        int? schoolID = data[i]['SchoolID'] as int?;

        // إنشاء نموذج الحلقة مع اسم المدرس
        Techer.add(UserModel(
          user_id: userID,
          first_name: firstName,
          last_name: lastName,
          roleID: roleID,
          schoolID: schoolID,
        ));
      }
    }
    print(data);
    return Techer;
  }

  addHalaga(HalagaModel halagaData) async {
    int add = await _sqlDb.insertData(
        "INSERT INTO 'Elhalagat' (SchoolID, Name, NumberStudent) VALUES ('${halagaData.SchoolID}', '${halagaData.Name}', 5)");
    // int addTeacher = await _sqlDb.insertData(
    //     "UPDATE Users SET ElhalagatID = '${halagaData.halagaID}' WHERE user_id = '${TeacherID}'");
    print(add);
    // print(addTeacher);
  }

  updateHalaga() async {}
  deleteHalaga() async {}
}

HalagaController halagaController = HalagaController();
