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
       StudentModel StudentData, int schoolID) async {
    final StudentRef = await _firestore.collection('Students');
    
    StudentData.schoolId = schoolID;
    if (StudentData != null) {
      try {
        await StudentRef.doc(StudentData.studentID.toString()).set(StudentData.toMap());
        print('تمت إضافة/تحديث الطالب بالرقم ${StudentData.studentID} بنجاح ');
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

  updateStudentData(StudentModel Student) async {
    final docRef = _firestore.collection('Students').doc(Student.studentID.toString());
    await docRef.update(Student.toMap()).then((_) {
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

  addSchool(SchoolModel school) async {
    final docRef = _firestore.collection('School');
    if (school != null) {
      await docRef.doc(school.user_id.toString()).set({
        'SchoolID': school.schoolID,
        'school_name': school.school_name,
        'school_location': school.school_location,
      });
      print('تم إضافة المدرسة ${school.schoolID} بنجاح');
    } else {
      print('خطأ في إضافة المدرسة');
    }
  }

  updateSchool(SchoolModel school) async {
    final docRef = _firestore.collection('School').doc(school.schoolID.toString());
    if (school != null) {
      await docRef.update({
        'school_name': school.school_name,
        'school_location': school.school_location,
      });
      print('تم تعديل المدرسة ${school.schoolID} بنجاح');
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

  addHalga(HalagaModel halaga) async {
    try{
      final docRef = await _firestore.collection('Elhalaga');
      if(halaga != null){
        docRef.doc(halaga.halagaID.toString()).set(halaga.toMap());
        print('===== تم رفع حلقة ${halaga.Name} بنجاح');
      }
    } catch (e){}
  }

// =========================== End Elhalaga ==============================

// =========================== Start User ===============================

  addUser(UserModel user) async {
    final docRef = _firestore.collection('Users');
    // user.user_id = id;
    if (user != null) {
      await docRef.doc(user.user_id.toString()).set(user.toMap());
      print("تمت اضافة المستخدم ${user.user_id} بنجاح");
    } else {
      print("خطا في الرفع");
    }
  }

  updateUser(UserModel user) async {
    final docRef = _firestore.collection('Users').doc(user.user_id.toString());
    // user.user_id = id;
    await docRef.update(user.toMap()).then((_) {
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

  addRequest(UserModel user) async {
    try {
      final docRef = _firestore.collection('Users').doc(user.user_id.toString());
      docRef.set(user.toMap());
      print("تمت اضافة الطلب ${user.user_id} بنجاح");
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


  Future<bool> checkDocumentExists(String collection, int id) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id.toString())
          .get();
      print("Find document");
      return documentSnapshot.exists;

    } catch (e) {
      print('Not found document');
      return false;
    }
  }
} // End of FirebaseHelper class

FirebaseHelper firebasehelper = FirebaseHelper();
