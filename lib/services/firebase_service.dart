// This file contains Firebase service code, remove it entirely if not needed.
import 'dart:math';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/models/verification_code_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //  UserColl = _firestore.collection('Users');

  // ======================= Start Student ==============
  Future<void> addStudent(StudentModel StudentData, int schoolID) async {
    final StudentRef = await _firestore.collection('Students');

    StudentData.schoolId = schoolID;
    if (StudentData != null) {
      try {
        await StudentRef.doc(StudentData.studentID.toString())
            .set(StudentData.toMap());
        print('تمت إضافة/تحديث الطالب بالرقم ${StudentData.studentID} بنجاح ');
      } catch (e) {
        print('خطأ أثناء إضافة الطالب إلى Firebase: $e');
      }
    } else {
      print('تحذير: studentData فارغ');
    }
  }

  Future<List<StudentModel>> getStudentData(int id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Students')
          .where('SchoolID', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('تم العثور على مستند');
        return snapshot.docs.map((doc) => StudentModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
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
    final docRef =
        _firestore.collection('Students').doc(Student.studentID.toString());
    await docRef.update(Student.toMap()).then((_) {
      print('تم التعديل بنجاح');
    }).catchError((error) {
      print('حدث خطأ: $error');
    });
  }

  assignStudentToHalqa(int studentId, int halqaID) async {
    try{
    final docRef = _firestore.collection('Students').doc(studentId.toString());
    await docRef.update({'ElhalagatID': halqaID});
    }catch (e){
      print('error=== $e');
    }
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
    final docRef =
        _firestore.collection('School').doc(school.schoolID.toString());
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

  updateHalaga(HalagaModel halaga) async {
    try{
      final docRef = await _firestore.collection('Elhalaga');
      if(halaga != null) {
        docRef.doc(halaga.halagaID.toString()).update(halaga.toMap());
      }
    }
    catch (e){
      print('error ==== $e');
    }
  }

  /// الغاء ارتباط المعلم بالحلقة
  Future<void> teacherCancel(int halagaId) async {
  try {
    final docRef = _firestore.collection('Users');

    // ابحث عن المستخدم الذي لديه نفس ElhalagatID
    final querySnapshot = await docRef
        .where('ElhalagatID', isEqualTo: halagaId)
        .where('roleID', isEqualTo: 2) // للتأكد أنه معلم
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;

      // تحديث ElhalagatID إلى null
      await docRef.doc(docId).update({'ElhalagatID': null});

      print('تم إلغاء ارتباط المعلم بالحلفة بنجاح من Firebase');
    } else {
      print('لم يتم العثور على معلم مرتبط بهذه الحلقة');
    }
  } catch (e) {
    print('حدث خطأ أثناء إلغاء ارتباط المعلم: $e');
  }
}

newTeacher(int halagaId, int teacherId) async {
  try{
      final docRef = _firestore.collection('Users');
      await docRef.doc(teacherId.toString()).update({'ElhalagatID': halagaId});
  } catch(e){
    print('error====$e');
  }

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

  Future<UserModel?> getUserByPhoneNumber(int phoneNumber) async {
    try {
      final docRef = _firestore.collection('Users');
      final snapshot = await docRef
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('حدث خطأ: $e');
      return null;
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

  
  // Generate verification code for a request
  

  // تحديث كلمة المرور في Firestore
  
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

//   ================== Plans FireBase Method Start ====================
  Future<void> addConservationPlan(
      ConservationPlanModel plan, int idDoc) async {
    try {
      await _firestore
          .collection("ConservationPlans")
          .doc(idDoc.toString())
          .set(plan.toMap());
      print(
          "---------------> The addConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in addConservationPlan in ((FirebaseService)) : $e");
    }
  }

  Future<void> addEltlawahPlan(EltlawahPlanModel plan, int idDoc) async {
    try {
      await _firestore
          .collection("EltlawahPlans")
          .doc(idDoc.toString())
          .set(plan.toMap());
      print(
          "---------------> The addEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in addEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  Future<void> addIslamicStudyplan(IslamicStudiesModel plan, int idDoc) async {
    try {
      await _firestore
          .collection("IslamicStudies")
          .doc(idDoc.toString())
          .set(plan.toMap());
      print(
          "---------------> The addIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in addIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }
  //===================== Update ConservationPlan =================
  Future<void> updateConservationPlan(
      ConservationPlanModel plan, int idDoc) async {
    try {
      await _firestore
          .collection("ConservationPlans")
          .doc(idDoc.toString())
          .update(plan.toMap());
      print(
          "---------------> The updateConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in updateConservationPlan in ((FirebaseService)) : $e");
    }
  }
  //===================== Update EltlawahPlan =================
  Future<void> updateEltlawahPlan(EltlawahPlanModel plan, int idDoc) async {
    try {
      await _firestore
          .collection("EltlawahPlans")
          .doc(idDoc.toString())
          .update(plan.toMap());
      print(
          "---------------> The updateEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in updateEltlawahPlan in ((FirebaseService)) : $e");
    }
  }
  //===================== Update IslamicStudyplan =================
  Future<void> updateIslamicStudyplan(IslamicStudiesModel plan, int idDoc) async {
    try {
      await _firestore
          .collection("IslamicStudies")
          .doc(idDoc.toString())
          .update(plan.toMap());
      print(
          "---------------> The updateIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in updateIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }
} // End of FirebaseHelper class

FirebaseHelper firebasehelper = FirebaseHelper();
