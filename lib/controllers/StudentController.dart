import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';

class StudentController {
  List<StudentModel> students = [];
  final SqlDb _sqldb = SqlDb();
  Future<List<StudentModel>> getStudents(int halagaID) async {
    // جلب الطلاب المرتبطين بالحلقة بناءً على halagaID
    List<Map> studentData = await _sqldb
        .readData("SELECT * FROM 'Students' WHERE halagaID = $halagaID");

    students = studentData.map((student) {
      return StudentModel(
        studentID: student['StudentID'],
        firstName: student['FirstName'],
        middleName: student['MiddleName'],
        lastName: student['LastName'],
      );
    }).toList();

    return students;
  }

  addStudent(StudentModel studentData) async {
    await _sqldb.insertData(
        "INSERT INTO Students (FirstName, MiddleName, grandfatherName, LastName) VALUES ('${studentData.firstName}', '${studentData.middleName}','${studentData.grandfatherName}','${studentData.lastName}')");
  }
}

StudentController studentController = StudentController();
