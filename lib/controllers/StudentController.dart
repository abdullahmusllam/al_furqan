import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/services/firebase_service.dart';

class StudentController {
  List<StudentModel> students = [];
  final SqlDb _sqldb = SqlDb();
  Future<List<StudentModel>> getStudents(int halagaID) async {
    // جلب الطلاب المرتبطين بالحلقة بناءً على halagaID
    List<Map> studentData = await _sqldb
        .readData("SELECT * FROM 'Students' WHERE ElhalagatID = $halagaID");

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

  getSchoolStudents(int id) async {
    // جلب الطلاب المرتبطين بالمدارس
    List<Map> studentData =
        await _sqldb.readData("SELECT * FROM 'Students' WHERE SchoolID = $id");
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
    int add = await _sqldb.insertData(
        "INSERT INTO Students (SchoolID, FirstName, MiddleName, grandfatherName, LastName) VALUES ('${studentData.SchoolId}','${studentData.firstName}', '${studentData.middleName}','${studentData.grandfatherName}','${studentData.lastName}')");
    // firebasehelper.addStudent(add, studentData);
  }

  updateStudent(StudentModel student, int id) async {
    // تعديل بيانات الطالب
    int update = await _sqldb.updateData(
        "UPDATE Students SET ElhalagatID = '${student.elhalaqaID}', FirstName = '${student.firstName}', MiddleName = '${student.middleName}', grandfatherName = '${student.grandfatherName}', LastName = '${student.lastName}', AttendanceDays = '${student.AttendanceDays}', AbsenceDays = '${student.AbsenceDays}', Excuse = '${student.Excuse}', ReasonAbsence = '${student.ReasonAbsence}' WHERE StudentID = ${id}");
    print(update);
  }

  // getAllStudent() async {
  //   List<Map> response = await _sqldb.readData("SELECT * FROM STUDENTS ");
  //   students = response.map((student) {
  //     return StudentModel(
  //       studentID: int.tryParse(student['StudentID'].toString()),
  //       firstName: student['FirstName']?.toString(),
  //       middleName: student['MiddleName']?.toString(),
  //       lastName: student['LastName']?.toString(),
  //     );
  //   }).toList();
  // }
}

StudentController studentController = StudentController();
