import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/schools_model.dart';

class SchoolController {
  final List<SchoolModel> _schools = [];
  final SqlDb _sqlDb = SqlDb();

  List<SchoolModel> get schools => _schools;

  /// جلب جميع المدارس من قاعدة البيانات
  Future<void> getData() async {
    try {
      final data = await _sqlDb.readData('SELECT * FROM Schools');
      _schools.clear();
      for (var item in data) {
        _schools.add(SchoolModel(
          schoolID: item['SchoolID'] as int?,
          school_name: item['school_name'] as String?,
          school_location: item['school_location'] as String?,
        ));
      }
      print("Fetched ${_schools.length} schools");
    } catch (e) {
      print("Error fetching schools: $e");
      rethrow;
    }
  }

  /// جلب مدرسة بناءً على SchoolID
  Future<SchoolModel?> getSchoolBySchoolID(int schoolID) async {
    try {
      final response = await _sqlDb.readData(
          "SELECT * FROM Schools WHERE SchoolID = $schoolID");
      if (response.isEmpty) {
        print("No school found for SchoolID: $schoolID");
        return null;
      }
      final school = SchoolModel(
        schoolID: response[0]['SchoolID'] as int?,
        school_name: response[0]['school_name'] as String?,
        school_location: response[0]['school_location'] as String?,
      );
      print("Fetched school: ${school.school_name}");
      return school;
    } catch (e) {
      print("Error fetching school by SchoolID $schoolID: $e");
      return null;
    }
  }

  /// إضافة مدرسة جديدة
  Future<void> addSchool(SchoolModel schoolModel) async {
    try {
      int response = await _sqlDb.insertData('''
        INSERT INTO Schools (school_name, school_location)
        VALUES ('${schoolModel.school_name}', '${schoolModel.school_location}')
      ''');
      print("Added school, response: $response");
      if (response == 0) {
        throw Exception("Failed to add school");
      }
    } catch (e) {
      print("Error adding school: $e");
      rethrow;
    }
  }

  /// حذف مدرسة بناءً على SchoolID
  Future<void> deleteSchool(int schoolId) async {
    try {
      int response = await _sqlDb.deleteData(
          "DELETE FROM Schools WHERE SchoolID = $schoolId");
      print("Deleted school $schoolId, response: $response");
      if (response == 0) {
        throw Exception("Failed to delete school $schoolId");
      }
    } catch (e) {
      print("Error deleting school: $e");
      rethrow;
    }
  }
}

SchoolController schoolController = SchoolController();