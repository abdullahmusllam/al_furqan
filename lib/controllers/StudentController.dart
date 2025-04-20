import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/services/firebase_service.dart';

class StudentController {
  List<StudentModel> students = [];
  final SqlDb _sqldb = SqlDb();

  Future<List<StudentModel>> getStudents(int halagaID) async {
    List<Map> studentData = await _sqldb
        .readData("SELECT * FROM Students WHERE ElhalagatID = $halagaID");

    students = studentData.map((student) {
      return StudentModel(
        studentID: student['StudentID'],
        firstName: student['FirstName'],
        middleName: student['MiddleName'],
        grandfatherName: student['grandfatherName'],
        lastName: student['LastName'],
        elhalaqaID: student['ElhalagatID'],
      );
    }).toList();
    print("Fetched students for halaga $halagaID: ${students.length}");
    return students;
  }

  Future<List<StudentModel>> getSchoolStudents(int schoolID) async {
    try {
      // جلب الطلاب المرتبطين بالمدارس
      List<Map<String, dynamic>> studentData = await _sqldb
          .readData("SELECT * FROM Students WHERE SchoolID = '$schoolID'");

      print("الطلاب الذين تم جلبهم من القاعدة المحلية: $studentData");

      if (studentData.isEmpty) {
        print("لا توجد بيانات للطلاب مع SchoolID: $schoolID");
        return []; // إذا كانت البيانات فارغة، نرجع قائمة فارغة.
      }

      // تحويل البيانات المسترجعة إلى قائمة من StudentModel
      List<StudentModel> students = studentData.map((student) {
        return StudentModel(
          studentID: student['StudentID'],
          schoolId: student['SchoolID'],
          firstName: student['FirstName'],
          middleName: student['MiddleName'],
          grandfatherName: student['grandfatherName'],
          lastName: student['LastName'],
        );
      }).toList();

      print("عدد الطلاب الذين تم جلبهم: ${students.length}");

      return students;
    } catch (e) {
      print("حدث خطأ أثناء جلب الطلاب: $e");
      return [];
    }
  }

  addStudentToFirebase(StudentModel student, int schoolID) async {
    print("id id id id id id id ${schoolID}");
    int? schoolIDF = schoolID;
    int add = await _sqldb.insertData(
        "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
        "VALUES ('${student.elhalaqaID}', ${schoolID}, "
        "'${student.firstName}', '${student.middleName}', '${student.grandfatherName}', "
        "'${student.lastName}', '${student.attendanceDays}', '${student.absenceDays}', "
        "'${student.excuse}', '${student.reasonAbsence}')"); // تحويل إلى Map
    firebasehelper.addStudent(add, student, schoolIDF);
  }

  Future<int> getTotalStudents() async {
    try {
      final count =
          await _sqldb.readData("SELECT COUNT(*) as count FROM Students");
      print("Total students: ${count[0]['count']}");
      return count[0]['count'] as int;
    } catch (e) {
      print("Error fetching total students: $e");
      return 0;
    }
  }

  Future<int> addStudent(StudentModel studentData) async {
    try {
      int response = await _sqldb.insertData(
          "INSERT INTO Students (userID ,SchoolID, FirstName, MiddleName, grandfatherName, LastName) VALUES (${studentData.userID},${studentData.schoolId}, '${studentData.firstName}', '${studentData.middleName}', '${studentData.grandfatherName}', '${studentData.lastName}')");
      print(
          "Added student, response: $response, Father ID: ${studentData.userID}, Student ID : ${studentData.studentID}");
      if (response == 0) {
        throw Exception("Failed to add student");
      }
      return response;
    } catch (e) {
      print("Error adding student: $e");
      rethrow;
    }
  }

  Future<void> updateStudent(StudentModel student, int id) async {
    try {
      print("Student in update : ${student.grandfatherName}");
      int update = await _sqldb.updateData(
          "UPDATE Students SET ElhalagatID = ${student.elhalaqaID ?? 'NULL'}, FirstName = '${student.firstName}', MiddleName = '${student.middleName}', grandfatherName = '${student.grandfatherName}', LastName = '${student.lastName}', AttendanceDays = ${student.attendanceDays ?? 'NULL'}, AbsenceDays = ${student.absenceDays ?? 'NULL'}, Excuse = '${student.excuse ?? ''}', ReasonAbsence = '${student.reasonAbsence ?? ''}' WHERE StudentID = $id");
      print("Update response: $update");
      print("USer ID : ${student.userID}");
      await firebasehelper.updateStudentData(student, id);

      if (update == 0) {
        throw Exception("Failed to update student $id");
      }
    } catch (e) {
      print("Error updating student: $e");
      rethrow;
    }
  }

  Future<void> addStudentToLocal(StudentModel student) async {
    int add = await _sqldb.insertData(
        "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) VALUES ('${student.elhalaqaID}', '${student.schoolId}', '${student.firstName}', '${student.middleName}', '${student.grandfatherName}', '${student.lastName}', '${student.attendanceDays}', '${student.absenceDays}', '${student.excuse}', '${student.reasonAbsence}')");

    print("تمت الإضافة بنجاح: $add");
  }

  Future<void> delete(int id) async {
    try {
      int response =
          await _sqldb.deleteData("DELETE FROM Students WHERE StudentID = $id");
      print("Delete response: $response");
      if (response == 0) {
        throw Exception("Failed to delete student $id");
      }
    } catch (e) {
      print("Error deleting student: $e");
      rethrow;
    }
  }

  Future<void> assignStudentToHalqa(int studentId, int halqaID) async {
    try {
      int response = await _sqldb.updateData(
          "UPDATE Students SET ElhalagatID = $halqaID WHERE StudentID = $studentId");
      print(
          "Assigned student $studentId to halqa $halqaID, response: $response");
      if (response == 0) {
        throw Exception(
            "Failed to assign student $studentId to halqa $halqaID");
      }

      final count = await _sqldb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = $halqaID");
      final studentCount = count[0]['count'] as int;
      int halagaResponse = await _sqldb.updateData(
          "UPDATE Elhalagat SET NumberStudent = $studentCount WHERE halagaID = $halqaID");
      print(
          "Updated NumberStudent to $studentCount for halqa $halqaID, response: $halagaResponse");
    } catch (e) {
      print("Error assigning student to halqa: $e");
      rethrow;
    }
  }

  Future<void> removeStudentFromHalqa(int studentId) async {
    try {
      int response = await _sqldb.updateData(
          "UPDATE Students SET ElhalagatID = NULL WHERE StudentID = $studentId");
      print("Removed student $studentId from halqa, response: $response");
      if (response == 0) {
        throw Exception("Failed to remove student $studentId from halqa");
      }
    } catch (e) {
      print("Error removing student from halqa: $e");
      rethrow;
    }
  }

  addStudentToFirebase2(StudentModel student, int schoolID) async {
    print("id id id id id id id ${schoolID}");
    int idStudent = await _sqldb.insertData(
        "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) VALUES ('${student.elhalaqaID}', ${schoolID}, '${student.firstName}', '${student.middleName}', '${student.grandfatherName}', ${student.lastName}', '${student.attendanceDays}', '${student.absenceDays}', '${student.excuse}', '${student.reasonAbsence}')"); // تحويل إلى Map
    await firebasehelper.addStudent(idStudent, student, schoolID);
  }

}

StudentController studentController = StudentController();
