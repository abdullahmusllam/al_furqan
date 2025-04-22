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
      // تأكد من أن elhalaqaID هو int أو null
      int? elhalaqaID;
      if (student['ElhalagatID'] != null) {
        try {
          // محاولة تحويل إلى int إذا كان نصاً
          if (student['ElhalagatID'] is String) {
            // التعامل مع سلسلة 'null' الخاصة
            if (student['ElhalagatID'] == 'null') {
              elhalaqaID = null;
              print("وجدت قيمة 'null' كنص: تم تعيين elhalaqaID إلى null");
            } else {
              elhalaqaID = int.tryParse(student['ElhalagatID']);
              print(
                  "تم تحويل معرف الحلقة من نص '${student['ElhalagatID']}' إلى رقم $elhalaqaID");
            }
          } else {
            elhalaqaID = student['ElhalagatID'] as int?;
          }
        } catch (e) {
          print("خطأ في تحويل معرف الحلقة: ${student['ElhalagatID']} - $e");
          elhalaqaID = null;
        }
      }

      return StudentModel(
        studentID: student['StudentID'],
        firstName: student['FirstName'],
        middleName: student['MiddleName'],
        grandfatherName: student['grandfatherName'],
        lastName: student['LastName'],
        elhalaqaID: elhalaqaID,
      );
    }).toList();
    print("Fetched students for halaga $halagaID: ${students.length}");
    return students;
  }

  Future<List<StudentModel>> getSchoolStudents(int schoolID) async {
    try {
      // جلب الطلاب المرتبطين بالمدارس
      List<Map<String, dynamic>> studentData = await _sqldb
          .readData("SELECT * FROM Students WHERE SchoolID = $schoolID");

      print("الطلاب الذين تم جلبهم من القاعدة المحلية: $studentData");

      if (studentData.isEmpty) {
        print("لا توجد بيانات للطلاب مع SchoolID: $schoolID");
        return []; // إذا كانت البيانات فارغة، نرجع قائمة فارغة.
      }

      // تحويل البيانات المسترجعة إلى قائمة من StudentModel
      students = studentData.map((student) {
        // تأكد من أن elhalaqaID هو int أو null
        int? elhalaqaID;
        if (student['ElhalagatID'] != null) {
          try {
            // محاولة تحويل إلى int إذا كان نصاً
            if (student['ElhalagatID'] is String) {
              // التعامل مع سلسلة 'null' الخاصة
              if (student['ElhalagatID'] == 'null') {
                elhalaqaID = null;
                print("وجدت قيمة 'null' كنص: تم تعيين elhalaqaID إلى null");
              } else {
                elhalaqaID = int.tryParse(student['ElhalagatID']);
                print(
                    "تم تحويل معرف الحلقة من نص '${student['ElhalagatID']}' إلى رقم $elhalaqaID");
              }
            } else {
              elhalaqaID = student['ElhalagatID'] as int?;
            }
          } catch (e) {
            print("خطأ في تحويل معرف الحلقة: ${student['ElhalagatID']} - $e");
            elhalaqaID = null;
          }
        }

        return StudentModel(
          studentID: student['StudentID'],
          schoolId: student['SchoolID'],
          firstName: student['FirstName'],
          middleName: student['MiddleName'],
          grandfatherName: student['grandfatherName'],
          lastName: student['LastName'],
          elhalaqaID: elhalaqaID,
          attendanceDays: student['AttendanceDays'],
          absenceDays: student['AbsenceDays'],
          excuse: student['Excuse'],
          reasonAbsence: student['ReasonAbsence'],
        );
      }).toList();

      print("عدد الطلاب الذين تم جلبهم: ${students.length}");

      // طباعة معلومات الحلقات للطلاب للتصحيح
      for (var student in students) {
        print(
            "الطالب: ${student.firstName} ${student.lastName}, معرف الحلقة: ${student.elhalaqaID}, نوع معرف الحلقة: ${student.elhalaqaID?.runtimeType}");
      }

      return students;
    } catch (e) {
      print("حدث خطأ أثناء جلب الطلاب: $e");
      return [];
    }
  }

  addStudentToFirebase(StudentModel student, int schoolID) async {
    print("جاري إضافة الطالب إلى Firebase - معرف المدرسة: ${schoolID}");

    if (student.studentID == null) {
      print("تحذير: معرف الطالب غير موجود (studentID = null)");
    }

    // معالجة معرف الحلقة
    String elhalaqaIDStr;
    if (student.elhalaqaID == null) {
      elhalaqaIDStr = "NULL"; // استخدام NULL في SQL بدلاً من قيمة نصية
    } else {
      elhalaqaIDStr = "${student.elhalaqaID}";
    }

    int? schoolIDF = schoolID;
    int add = await _sqldb.insertData(
        "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
        "VALUES ($elhalaqaIDStr, ${schoolID}, "
        "'${student.firstName}', '${student.middleName}', '${student.grandfatherName}', "
        "'${student.lastName}', ${student.attendanceDays ?? 'NULL'}, ${student.absenceDays ?? 'NULL'}, "
        "'${student.excuse ?? ''}', '${student.reasonAbsence ?? ''}')");

    print("تم إضافة الطالب محلياً بمعرف: $add");

    // تحديث معرف الطالب إذا لم يكن موجودًا
    if (student.studentID == null) {
      student.studentID = add;
    }

    // إرسال البيانات إلى Firebase
    await firebasehelper.addStudent(add, student, schoolIDF);
    print("تم إرسال بيانات الطالب إلى Firebase");
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
      // إذا كان schoolId غير موجود، استخدم قيمة افتراضية
      int schoolId = studentData.schoolId ?? 0;
      // إذا كان userID غير موجود، استخدم NULL
      String userIdStr =
          studentData.userID != null ? "${studentData.userID}" : "NULL";

      int response = await _sqldb.insertData(
          "INSERT INTO Students (userID, SchoolID, FirstName, MiddleName, grandfatherName, LastName) "
          "VALUES ($userIdStr, $schoolId, '${studentData.firstName}', '${studentData.middleName}', "
          "'${studentData.grandfatherName}', '${studentData.lastName}')");

      print(
          "Added student, response: $response, Father ID: ${studentData.userID}, Student ID : ${studentData.studentID}");
      if (response == 0) {
        throw Exception("Failed to add student");
      }

      // تحديث قيمة StudentID في النموذج
      studentData.studentID = response;

      return response;
    } catch (e) {
      print("Error adding student: $e");
      rethrow;
    }
  }

  Future<void> updateStudent(StudentModel student, int id) async {
    try {
      print("Student in update : ${student.grandfatherName}");

      // معالجة معرف الحلقة
      String elhalaqaIDStr;
      if (student.elhalaqaID == null) {
        elhalaqaIDStr = "NULL"; // استخدام NULL في SQL بدلاً من 'NULL'
      } else {
        elhalaqaIDStr = "${student.elhalaqaID}";
      }

      int update = await _sqldb.updateData(
          "UPDATE Students SET ElhalagatID = $elhalaqaIDStr, FirstName = '${student.firstName}', MiddleName = '${student.middleName}', grandfatherName = '${student.grandfatherName}', LastName = '${student.lastName}', AttendanceDays = ${student.attendanceDays ?? 'NULL'}, AbsenceDays = ${student.absenceDays ?? 'NULL'}, Excuse = '${student.excuse ?? ''}', ReasonAbsence = '${student.reasonAbsence ?? ''}' WHERE StudentID = $id");
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
    // معالجة معرف الحلقة
    String elhalaqaIDStr;
    if (student.elhalaqaID == null) {
      elhalaqaIDStr = "NULL"; // استخدام NULL في SQL بدلاً من قيمة نصية
    } else {
      elhalaqaIDStr = "${student.elhalaqaID}";
    }

    int add = await _sqldb.insertData(
        "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
        "VALUES ($elhalaqaIDStr, ${student.schoolId}, '${student.firstName}', '${student.middleName}', "
        "'${student.grandfatherName}', '${student.lastName}', ${student.attendanceDays ?? 'NULL'}, "
        "${student.absenceDays ?? 'NULL'}, '${student.excuse ?? ''}', '${student.reasonAbsence ?? ''}')");

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
    print("جاري إضافة الطالب إلى Firebase - معرف المدرسة: ${schoolID}");

    // معالجة معرف الحلقة
    String elhalaqaIDStr;
    if (student.elhalaqaID == null) {
      elhalaqaIDStr = "NULL"; // استخدام NULL في SQL بدلاً من قيمة نصية
    } else {
      elhalaqaIDStr = "${student.elhalaqaID}";
    }

    int idStudent = await _sqldb.insertData(
        "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
        "VALUES ($elhalaqaIDStr, ${schoolID}, '${student.firstName}', '${student.middleName}', "
        "'${student.grandfatherName}', '${student.lastName}', ${student.attendanceDays ?? 'NULL'}, "
        "${student.absenceDays ?? 'NULL'}, '${student.excuse ?? ''}', '${student.reasonAbsence ?? ''}')");

    await firebasehelper.addStudent(idStudent, student, schoolID);
    print("تم إرسال بيانات الطالب إلى Firebase");
  }

  Future<List<StudentModel>> getStudentsWithoutHalaga(int schoolID) async {
    try {
      List<Map<String, dynamic>> studentData = await _sqldb.readData(
          "SELECT * FROM Students WHERE SchoolID = $schoolID AND ElhalagatID IS NULL");

      print(
          "Students without halaga for schoolID $schoolID: ${studentData.length}");

      if (studentData.isEmpty) {
        print("No students without halaga for school: $schoolID");
        return [];
      }

      List<StudentModel> studentsWithoutHalaga = studentData.map((student) {
        return StudentModel(
          studentID: student['StudentID'],
          schoolId: student['SchoolID'],
          firstName: student['FirstName'],
          middleName: student['MiddleName'],
          grandfatherName: student['grandfatherName'],
          lastName: student['LastName'],
          elhalaqaID: null, // نحدد بشكل صريح أن هؤلاء الطلاب ليس لديهم حلقة
        );
      }).toList();

      return studentsWithoutHalaga;
    } catch (e) {
      print("Error fetching students without halaga: $e");
      return [];
    }
  }

  Future<void> assignStudentsToHalaga(
      List<int> studentIds, int halagaID) async {
    try {
      for (int studentId in studentIds) {
        await assignStudentToHalqa(studentId, halagaID);
      }

      // Update the student count for the halaga
      final count = await _sqldb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = $halagaID");
      final studentCount = count[0]['count'] as int;
      int halagaResponse = await _sqldb.updateData(
          "UPDATE Elhalagat SET NumberStudent = $studentCount WHERE halagaID = $halagaID");
      print(
          "Updated NumberStudent to $studentCount for halqa $halagaID, response: $halagaResponse");
    } catch (e) {
      print("Error assigning students to halaga: $e");
      rethrow;
    }
  }
}

StudentController studentController = StudentController();
