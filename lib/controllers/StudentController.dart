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

  Future<List<StudentModel>> getSchoolStudents(int id) async {
    List<Map> studentData =
        await _sqldb.readData("SELECT * FROM Students WHERE SchoolID = $id");
    print("Response Get : ${studentData.isEmpty}");
    students = studentData.map((student) {
      return StudentModel(
        studentID: student['StudentID'],
        // elhalaqaID: student['ElhalagatID'], ///
        schoolId: student['SchoolID'],
        firstName: student['FirstName'],
        middleName: student['MiddleName'],
        grandfatherName: student['grandfatherName'],
        lastName: student['LastName'],
      );
    }).toList();
    print("students.length : ${students.length}");
    return students;
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

  Future<void> addStudent(StudentModel studentData, int type) async {
    try {
      if (type == 1) {
        studentData.studentID =
            await someController.newId("Students", "studentID");
        int response = await _sqldb.insertData(
            "INSERT INTO Students (studentID, ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) VALUES (${studentData.studentID}, '${studentData.elhalaqaID}', '${studentData.schoolId}', '${studentData.firstName}', '${studentData.middleName}', '${studentData.grandfatherName}', '${studentData.lastName}', '${studentData.attendanceDays}', '${studentData.absenceDays}', '${studentData.excuse}', '${studentData.reasonAbsence}')");
        print(
            "Added student, response: $response, School ID: ${studentData.schoolId}");
        await firebasehelper.addStudent(
            studentData.studentID!, studentData, studentData.schoolId!);
        if (response == 0) {
          throw Exception("Failed to add student");
        }
      } else {
        int response = await _sqldb.insertData(
            "INSERT INTO Students (studentID, ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) VALUES (${studentData.studentID}, '${studentData.elhalaqaID}', '${studentData.schoolId}', '${studentData.firstName}', '${studentData.middleName}', '${studentData.grandfatherName}', '${studentData.lastName}', '${studentData.attendanceDays}', '${studentData.absenceDays}', '${studentData.excuse}', '${studentData.reasonAbsence}')");
        print(
            "Added student, response: $response, School ID: ${studentData.schoolId}");
        await firebasehelper.addStudent(
            studentData.studentID!, studentData, studentData.schoolId!);
        if (response == 0) {
          throw Exception("Failed to add student");
        }
      }
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
      await firebasehelper.updateStudentData(student, id);

      if (update == 0) {
        throw Exception("Failed to update student $id");
      }
    } catch (e) {
      print("Error updating student: $e");
      rethrow;
    }
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

}

StudentController studentController = StudentController();
