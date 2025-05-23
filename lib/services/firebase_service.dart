// This file contains Firebase service code, remove it entirely if not needed.
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  // ======================= Start Student ==============
<<<<<<< HEAD
  Future<void> addStudent(
      int id, StudentModel StudentData, int schoolID) async {
    final StudentRef = FirebaseFirestore.instance.collection('Students');

    if (StudentData != Null) {
      await StudentRef.doc(id.toString()).set({
        'StudentID': id,
        'ElhalagatID': StudentData.elhalaqaID,
        'SchoolID': schoolID,
        'FirstName': StudentData.firstName,
        'MiddleName': StudentData.middleName,
        'grandfatherName': StudentData.grandfatherName,
        'LastName': StudentData.lastName,
        'AttendanceDays': StudentData.attendanceDays,
        'AbsenceDays': StudentData.absenceDays,
        'Excuse': StudentData.excuse,
        'ReasonAbsence': StudentData.reasonAbsence
      });
      print('تمت إضافة/تحديث العنص بالرقم $id بنجاح ');
    } else {
      print('studentData فارغ ');
=======
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
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
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

<<<<<<< HEAD
  updateStudentData(StudentModel Student, int id) async {
=======
  Future<void> updateStudentData(StudentModel student, int id) async {
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
    final docRef =
        FirebaseFirestore.instance.collection('Students').doc(id.toString());

    await docRef.update({
      'StudentID': id,
<<<<<<< HEAD
      'ElhalagatID': Student.elhalaqaID,
      'SchoolID': Student.schoolId,
      'FirstName': Student.firstName,
      'MiddleName': Student.middleName,
      'grandfatherName': Student.grandfatherName,
      'LastName': Student.lastName,
      'AttendanceDays': Student.attendanceDays,
      'AbsenceDays': Student.absenceDays,
      'Excuse': Student.excuse,
      'ReasonAbsence': Student.reasonAbsence
=======
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
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
    }).then((_) {
      print('تم التعديل بنجاح');
    }).catchError((error) {
      print('حدث خطأ: $error');
    });
  }
<<<<<<< HEAD
// ===================== End Student ===========================

// =========================== Start Elhalaga ===========================

// =========================== End Elhalag ==============================

// =========================== Start User ===============================

  addUser(int id, UserModel user) async {
    final docRef = FirebaseFirestore.instance.collection('Users');
    if (user != null) {
      await docRef.doc(id.toString()).set({
        'user_id': id,
        'ActivityID': user.ActivityID,
        'ElhalagatID': user.ElhalagatID,
        'first_name': user.first_name,
        'middle_name': user.middle_name,
        'grandfather_name': user.grandfather_name,
        'last_name': user.last_name,
        'password': user.password,
        'email': user.email,
        'phone_number': user.phone_number,
        'telephone_number': user.telephone_number,
        'roleID': user.roleID,
        'schoolID': user.schoolID,
        'date': user.date,
        'isActivate': user.isActivate
      });
      print("تمت اضافة المستخدم $id بنجاح");
    } else {
      print("خطا في الرفع");
    }
  }

  updateUser(int id, UserModel user) async {
    final docRef =
        FirebaseFirestore.instance.collection('Users').doc(id.toString());
    await docRef.update({
      'user_id': id,
      'ActivityID': user.ActivityID,
      'ElhalagatID': user.ElhalagatID,
      'first_name': user.first_name,
      'middle_name': user.middle_name,
      'grandfather_name': user.grandfather_name,
      'last_name': user.last_name,
      'password': user.password,
      'email': user.email,
      'phone_number': user.phone_number,
      'telephone_number': user.telephone_number,
      'roleID': user.roleID,
      'schoolID': user.schoolID,
      'date': user.date,
      'isActivate': user.isActivate
    }).then((_) {
      print('تم التعديل بنجاح');
    }).catchError((error) {
      print('حدث خطأ: $error');
    });
  }

  deleteUser(int id) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('Users').doc(id.toString());
      await docRef.delete();
      print('تم حذف المستخدم $id بنجاح');
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  activateUser(int id) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('Users').doc(id.toString());
      await docRef.update({'isActivate': 1});
      print('تم تفعيل المستخدم $id بنجاح');
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  deactivateUser(int id) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('Users').doc(id.toString());
      await docRef.update({'isActivate': 0});
      print('تم تعطيل المستخدم $id بنجاح');
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  addRequest(int id, UserModel user) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('Users').doc(id.toString());
      await docRef.set({
        'user_id': id,
        'first_name': user.first_name,
        'middle_name': user.middle_name,
        'grandfather_name': user.grandfather_name,
        'last_name': user.last_name,
        'password': user.password,
        'email': user.email,
        'phone_number': user.phone_number,
        'telephone_number': user.telephone_number,
        'roleID': user.roleID,
        'schoolID': user.schoolID,
        'date': user.date,
        'isActivate': 0
      });
      print("تمت اضافة الطلب $id بنجاح");
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('Users');
      final snapshot = await docRef.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
    print('حدث خطأ: $e');
    return [];
  }
}
// =========================== End User =================================
}
=======
  // ===================== End Student ===========================

  // =========================== Start Elhalaga ===========================

  Future<void> addHalaga() async {
    // Add Halaga logic here
  }
}
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04

FirebaseHelper firebasehelper = FirebaseHelper();
