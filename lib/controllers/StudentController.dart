import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';

class StudentController {
  final List<StudentModel> students = [];
  final SqlDb _sqldb = SqlDb();
  gitData() async {
    await _sqldb.readData("sql");
  }

  addStudent(StudentModel studentData) async {
    await _sqldb.insertData(
        "INSERT INTO Students (FirstName, MiddleName, grandfatherName, LastName) VALUES ('${studentData.firstName}', '${studentData.middleName}','${studentData.grandfatherName}','${studentData.lastName}')");
  }
}

StudentController studentController = StudentController();
