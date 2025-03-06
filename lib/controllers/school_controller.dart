import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';

import '../models/schools_model.dart';

class SchoolController {
  List<SchoolModel> _schools = [];
  SqlDb _sqlDb = SqlDb();

  List<SchoolModel> get schools => _schools;

  Future<void> get_data() async {
    final data = await _sqlDb.readData('SELECT * FROM schools');
    // schools = data.map((item) => SchoolModel.fromMap(item)).toList();
    _schools.clear();
    for (var i = 0; i < data.length; i++) {
      _schools.add(SchoolModel(
        school_id: data[i]['school_id'] as int?,
        school_name: data[i]['school_name'],
        school_location: data[i]['school_location'],
        // user_id: data[i]['user_id'] as int?,
      ));
    }
    print(_schools.isEmpty);
  }

  // method add
  add_School(SchoolModel schoolmodel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO SCHOOLS (school_name, school_location)
    VALUES ('${schoolmodel.school_name}', '${schoolmodel.school_location}');
    ''');

    print(response);
    print(schoolmodel.school_id);
  }

  Future<void> delete_School(int schoolId) async {
    int response = await _sqlDb
        .deleteData("DELETE FROM SCHOOLS WHERE school_id = $schoolId");

    print("Response: $response, school_id : $schoolId");
    print(response);
  }
}

SchoolController schoolController = SchoolController();
