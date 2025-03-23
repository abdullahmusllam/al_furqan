import 'dart:ffi';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  // final List<HalagaModel> halagaData = [];

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

  addHalaga(HalagaModel halagaData) async {
    int add = await _sqlDb.insertData(
        "INSERT INTO 'Elhalagat' (SchoolID, Name, NumberStudent) VALUES ('${halagaData.SchoolID}', '${halagaData.Name}', '${halagaData.NumberStudent}')");
    print(add);
  }

  updateHalaga() async {}
  deleteHalaga() async {}
}

HalagaController halagaController = HalagaController();
