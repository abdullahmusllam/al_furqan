// This file contains Firebase service code, remove it entirely if not needed.
import 'package:al_furqan/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  // ======================= Start Student ==============
  Future<void> addStudent(int id, StudentModel studentData, int schoolID) async {
    final studentRef = FirebaseFirestore.instance.collection('Students');

    if (studentData != null) {
      await studentRef.doc(id.toString()).set({
        'StudentID': id,
        'ElhalagatID': studentData.elhalaqaID,
        'SchoolID': schoolID,
        'FirstName': studentData.firstName,
        'MiddleName': studentData.middleName,
        'grandfatherName': studentData.grandfatherName,
        'LastName': studentData.lastName,
        'AttendanceDays': studentData.attendanceDays,
        'AbsenceDays': studentData.absenceDays,
        'Excuse': studentData.excuse,
        'ReasonAbsence': studentData.reasonAbsence
      });
      print('تمت إضافة/تحديث العنصر بالرقم $id بنجاح');
    } else {
      print('studentData فارغ');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentData(int id) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Students')
          .where('SchoolID', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('تم العثور على مستند');
        return querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        print('لا توجد مستندات تطابق الشرط');
        return [];
      }
    } catch (e) {
      print('خطأ أثناء جلب البيانات: $e');
      return [];
    }
  }

  Future<void> updateStudentData(StudentModel student, int id) async {
    final docRef =
        FirebaseFirestore.instance.collection('Students').doc(id.toString());

    await docRef.update({
      'StudentID': id,
      'ElhalagatID': student.elhalaqaID,
      'SchoolID': student.schoolId,
      'FirstName': student.firstName,
      'MiddleName': student.middleName,
      'grandfatherName': student.grandfatherName,
      'LastName': student.lastName,
      'AttendanceDays': student.attendanceDays,
      'AbsenceDays': student.absenceDays,
      'Excuse': student.excuse,
      'ReasonAbsence': student.reasonAbsence
    }).then((_) {
      print('تم التعديل بنجاح');
    }).catchError((error) {
      print('حدث خطأ: $error');
    });
  }
  // ===================== End Student ===========================

  // =========================== Start Elhalaga ===========================

  Future<void> addHalaga() async {
    // Add Halaga logic here
  }
}

FirebaseHelper firebasehelper = FirebaseHelper();
