// This file contains Firebase service code, remove it entirely if not needed.
import 'dart:math';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //  UserColl = _firestore.collection('Users');

  // ======================= Start Student ==============
  Future<void> addStudent(
      int id, StudentModel StudentData, int schoolID) async {
    final StudentRef = await _firestore.collection('Students');

    if (StudentData != null) {
      try {
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
        print('تمت إضافة/تحديث الطالب بالرقم $id بنجاح ');
      } catch (e) {
        print('خطأ أثناء إضافة الطالب إلى Firebase: $e');
      }
    } else {
      print('تحذير: studentData فارغ');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentData(int id) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
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

  updateStudentData(StudentModel Student, int id) async {
    final docRef = _firestore.collection('Students').doc(id.toString());

    await docRef.update({
      'StudentID': id,
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
    }).then((_) {
      print('تم التعديل بنجاح');
    }).catchError((error) {
      print('حدث خطأ: $error');
    });
  }
// ===================== End Student ===========================

// =========================== Start School =============================

  Future<List<SchoolModel>> getSchool() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('School').get();

      if (querySnapshot.docs.isNotEmpty) {
        print('تم العثور على المدارس');
        return querySnapshot.docs
            .map((doc) =>
                SchoolModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        print('لا توجد مدارس');
        return [];
      }
    } catch (e) {
      print('خطأ أثناء جلب بيانات المدارس: $e');
      return [];
    }
  }

  addSchool(SchoolModel school, int id) async {
    final docRef = _firestore.collection('School');
    if (school != null) {
      await docRef.doc(id.toString()).set({
        'SchoolID': id,
        'school_name': school.school_name,
        'school_location': school.school_location,
      });
      print('تم إضافة المدرسة $id بنجاح');
    } else {
      print('خطأ في إضافة المدرسة');
    }
  }

  updateSchool(SchoolModel school, int id) async {
    final docRef = _firestore.collection('School').doc(id.toString());
    if (school != null) {
      await docRef.update({
        'school_name': school.school_name,
        'school_location': school.school_location,
      });
      print('تم تعديل المدرسة $id بنجاح');
    } else {
      print('خطأ في تعديل المدرسة');
    }
  }

// ========================== End School ================================

// =========================== Start Elhalaga ===========================

//get data from elhalaga collection on schoolID
  Future<List<Map<String, dynamic>>> getElhalagaData(int schoolID) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Elhalaga')
          .where('SchoolID', isEqualTo: schoolID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('تم العثور على حلقات');
        return querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        print('لا توجد حلقات تطابق الشرط');
        return [];
      }
    } catch (e) {
      print('خطأ أثناء جلب بيانات الحلقات: $e');
      return [];
    }
  }

  // addHalga(HalagaModel Halaga) async {
  //   try{
  //     final docRef = _firestore.collection('Elhalaga');
  //     if(Halaga != null){

  //     }
  //   } catch (e){}
  // }

// =========================== End Elhalaga ==============================

// =========================== Start User ===============================

  addUser(int id, UserModel user) async {
    final docRef = _firestore.collection('Users');
    if (user != null) {
      await docRef.doc(id.toString()).set({
        'user_id': id,
        'ActivityID': user.activityID,
        'ElhalagatID': user.elhalagatID,
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
    final docRef = _firestore.collection('Users').doc(id.toString());
    await docRef.update({
      'user_id': id,
      'ActivityID': user.activityID,
      'ElhalagatID': user.elhalagatID,
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
      final docRef = _firestore.collection('Users').doc(id.toString());
      await docRef.delete();
      print('تم حذف المستخدم $id بنجاح');
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  activateUser(int id) async {
    try {
      final docRef = _firestore.collection('Users').doc(id.toString());
      await docRef.update({'isActivate': 1});
      print('تم تفعيل المستخدم $id بنجاح');
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  deactivateUser(int id) async {
    try {
      final docRef = _firestore.collection('Users').doc(id.toString());
      await docRef.update({'isActivate': 0});
      print('تم تعطيل المستخدم $id بنجاح');
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  addRequest(int id, UserModel user) async {
    try {
      final docRef = _firestore.collection('Users').doc(id.toString());
      docRef.set({
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

  Future<List<UserModel>> getUsers() async {
    try {
      final docRef = _firestore.collection('Users');
      final snapshot = await docRef.get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('حدث خطأ: $e');
      return [];
    }
  }

// services/password_service.dart
  // إرسال رمز التحقق عبر واتساب
  Future<String> sendWhatsAppVerification(int idNumber) async {
    try {
      // 1. البحث عن المستخدم في Firestore
      final query = await _firestore
          .collection('Users')
          .where('phone_number', isEqualTo: idNumber)
          .limit(1)
          .get();

      print(query.docs.first.data());

      if (query.docs.isEmpty) {
        throw 'رقم الهاتف غير مسجل';
      }

      final userData = query.docs.first.data();
      final userPhone = userData['phone_number'];

      if (userPhone == null || userPhone.toString().isEmpty) {
        throw 'لا يوجد رقم هاتف مسجل لهذا الحساب';
      }

      // 2. توليد رمز تحقق عشوائي (6 أرقام)
      final verificationCode = (100000 + Random().nextInt(900000)).toString();

      // 3. تنظيف رقم الهاتف
      final cleanUserPhone =
          userPhone.toString().replaceAll(RegExp(r'[^0-9]'), '');

      // 4. إعداد رابط واتساب مع رقم المرسل الثابت
      final message = 'رمز التحقق لتغيير كلمة المرور هو: $verificationCode';

      final whatsappUrl =
          "https://wa.me/$cleanUserPhone?text=${Uri.encodeComponent(message)}"; // إضافة رقم المرسل
      // 5. إرسال الرسالة
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
        return verificationCode;
      } else {
        throw 'لا يمكن فتح واتساب';
      }
    } catch (e) {
      // throw 'فشل إرسال الرمز: ${e.toString()}';
      print(e.toString());
      return null!;
    }
  }

  // تحديث كلمة المرور في Firestore
  Future<void> updatePassword(int idNumber, String newPassword) async {
    try {
      final query = await _firestore
          .collection('Users')
          .where('phone_number', isEqualTo: idNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw 'رقم الهاتف غير مسجل';
      }

      await query.docs.first.reference.update({
        'password': newPassword, // يجب تشفير كلمة المرور في التطبيق الحقيقي
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل تحديث كلمة المرور: ${e.toString()}';
    }
  }
  // =========================== End User =================================
} // End of FirebaseHelper class

FirebaseHelper firebasehelper = FirebaseHelper();
