import 'dart:ffi';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];

  gitData(HalagaModel id) async {
    List<Map> Data = await _sqlDb
        .readData("SELECT * FROM 'Elhalagat' WHERE SchoolID = $id");
    for (var i = 0; i < Data.length; i++) {
      halagaData.add(HalagaModel(
          halagaID: Data[i]['halagaID'] as int?,
          Name: Data[i]['Name'],
          NumberStudent: Data[i]['NumberStudent'],
          AttendanceRate: Data[i]['AttendanceRate'] as Double?));
    }
  }

  addHalaga(HalagaModel halagaData) async {
    await _sqlDb.insertData(
        "INSERT INTO 'Elhalagat' (SchoolID, Name, NumberStudent) VALUES ('${halagaData.SchoolID}', '${halagaData.Name}', '${halagaData.NumberStudent}')");
  }

  updateHalaga() async {}
  deleteHalaga() async {}
}

HalagaController halagaController = HalagaController();
