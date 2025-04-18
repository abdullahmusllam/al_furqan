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

  Future<List<StudentModel>> getSchoolStudents(int id) async {
  try {
    // جلب الطلاب المرتبطين بالمدارس
    List<Map<String, dynamic>> studentData = await _sqldb.readData(
        "SELECT * FROM Students WHERE SchoolID = '$id'");

    print("الطلاب الذين تم جلبهم من القاعدة المحلية: $studentData");

    if (studentData.isEmpty) {
      print("لا توجد بيانات للطلاب مع SchoolID: $id");
      return []; // إذا كانت البيانات فارغة، نرجع قائمة فارغة.
    }

    // تحويل البيانات المسترجعة إلى قائمة من StudentModel
    List<StudentModel> students = studentData.map((student) {
      return StudentModel(
        studentID: student['StudentID'],
        firstName: student['FirstName'],
        middleName: student['MiddleName'],
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
    "'${student.lastName}', '${student.AttendanceDays}', '${student.AbsenceDays}', "
    "'${student.Excuse}', '${student.ReasonAbsence}')"
  );// تحويل إلى Map
    firebasehelper.addStudent(add, student, schoolIDF);
  }

 Future<void> addStudentToLocal(StudentModel student) async {
  int add = await _sqldb.insertData(
    "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
    "VALUES (''${student.elhalaqaID}', '${student.SchoolId}', "
    "'${student.firstName}', '${student.middleName}', '${student.grandfatherName}', "
    "'${student.lastName}', '${student.AttendanceDays}', '${student.AbsenceDays}', "
    "'${student.Excuse}', '${student.ReasonAbsence}')"
  );

  print("تمت الإضافة بنجاح: $add");
}

  updateStudent(StudentModel student, int id) async {
    // تعديل بيانات الطالب
    int update = await _sqldb.updateData(
        "UPDATE Students SET ElhalagatID = '${student.elhalaqaID}', SchoolID = '${student.SchoolId}', FirstName = '${student.firstName}', MiddleName = '${student.middleName}', grandfatherName = '${student.grandfatherName}', LastName = '${student.lastName}', AttendanceDays = '${student.AttendanceDays}', AbsenceDays = '${student.AbsenceDays}', Excuse = '${student.Excuse}', ReasonAbsence = '${student.ReasonAbsence}' WHERE StudentID = ${id}");
    print("uuuuuuuuuuuuuuuuuuu$update");
  }
  
}

StudentController studentController = StudentController();
