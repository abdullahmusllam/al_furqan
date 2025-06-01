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
        StudentData.isSync = 1;
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
        return snapshot.docs
            .map((doc) =>
                StudentModel.fromJson(doc.data() as Map<String, dynamic>))
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
    Student.isSync = 1;
    final docRef =
        _firestore.collection('Students').doc(Student.studentID.toString());
    await docRef.update(Student.toMap()).then((_) {
      print('تم التعديل بنجاح');
    }).catchError((error) {
      print('حدث خطأ: $error');
    });
  }

  assignStudentToHalqa(int studentId, int halqaID) async {
    try {
      final docRef =
          _firestore.collection('Students').doc(studentId.toString());
      await docRef.update({'ElhalagatID': halqaID});
    } catch (e) {
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
      await docRef.doc(school.schoolID.toString()).set({
        'SchoolID': school.schoolID,
        'school_name': school.school_name,
        'school_location': school.school_location,
        'isSync': 1,
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
        'isSync': 1,
      });
      print('تم تحديث المدرسة ${school.schoolID} بنجاح');
    } else {
      print('خطأ في تحديث المدرسة');
    }
  }

  /// حذف مدرسة من Firebase
  Future<void> deleteSchool(int schoolId) async {
    try {
      final docRef = _firestore.collection('School').doc(schoolId.toString());
      await docRef.delete();
      print('تم حذف المدرسة $schoolId من Firebase بنجاح');
    } catch (e) {
      print('خطأ في حذف المدرسة من Firebase: $e');
      rethrow;
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
    try {
      final docRef = await _firestore.collection('Elhalaga');
      if (halaga != null) {
        docRef.doc(halaga.halagaID.toString()).set(halaga.toMap());
        print('===== تم رفع حلقة ${halaga.Name} بنجاح');
      }
    } catch (e) {}
  }

  updateHalaga(HalagaModel halaga) async {
    try {
      final docRef = await _firestore.collection('Elhalaga');
      if (halaga != null) {
        docRef.doc(halaga.halagaID.toString()).update(halaga.toMap());
      }
    } catch (e) {
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
    try {

      final docRef = _firestore.collection('Users');
      await docRef.doc(teacherId.toString()).update({'ElhalagatID': halagaId});
    } catch (e) {
      print('error====$e');
    }
  }

// =========================== End Elhalaga ==============================

// =========================== Start User ===============================

  addUser(UserModel user) async {
    print("addUser(UserModel user)");
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
      await docRef.update({'isSync': 1});
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
      final docRef =
          _firestore.collection('Users').doc(user.user_id.toString());
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
      ConservationPlanModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("ConservationPlans")
          .doc(idDoc)
          .set(plan.toMap());
      print(
          "---------------> The addConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in addConservationPlan in ((FirebaseService)) : $e");
    }
  }

  Future<void> addEltlawahPlan(EltlawahPlanModel plan, String idDoc) async {
    try {
      await _firestore.collection("EltlawahPlans").doc(idDoc).set(plan.toMap());
      print(
          "---------------> The addEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in addEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  Future<void> addIslamicStudyplan(
      IslamicStudiesModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("IslamicStudies")
          .doc(idDoc)
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
      ConservationPlanModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("ConservationPlans")
          .doc(idDoc)
          .update(plan.toMap());
      print(
          "---------------> The updateConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in updateConservationPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update EltlawahPlan =================
  Future<void> updateEltlawahPlan(EltlawahPlanModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("EltlawahPlans")
          .doc(idDoc)
          .update(plan.toMap());
      print(
          "---------------> The updateEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in updateEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update IslamicStudyplan =================
  Future<void> updateIslamicStudyplan(
      IslamicStudiesModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("IslamicStudies")
          .doc(idDoc)
          .update(plan.toMap());
      print(
          "---------------> The updateIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in updateIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }

  //===================== Delete ConservationPlan =================
  Future<void> deleteConservationPlan(String idDoc) async {
    try {
      await _firestore.collection("ConservationPlans").doc(idDoc).delete();
      print(
          "---------------> The deleteConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in deleteConservationPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Delete EltlawahPlan =================
  Future<void> deleteEltlawahPlan(String idDoc) async {
    try {
      await _firestore.collection("EltlawahPlans").doc(idDoc).delete();
      print(
          "---------------> The deleteEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in deleteEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Delete IslamicStudyplan =================
  Future<void> deleteIslamicStudyplan(String idDoc) async {
    try {
      await _firestore.collection("IslamicStudies").doc(idDoc).delete();
      print(
          "---------------> The deleteIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      print(
          "---------------> The Error in deleteIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update Attendance =================
  Future<void> updateAttendance(
      int studentID, bool isPresent, String absenceReasons) async {
    try {
      // الحصول على بيانات الطالب الحالية من Firestore
      var studentDoc = await _firestore
          .collection("Students")
          .doc(studentID.toString())
          .get();

      if (studentDoc.exists) {
        var studentData = studentDoc.data();

        // استخراج قيم الحضور والغياب الحالية
        int currentAttendance = studentData?['AttendanceDays'] ?? 0;
        int currentAbsence = studentData?['AbsenceDays'] ?? 0;

        // تحديث القيم بناءً على حالة الحضور
        if (isPresent) {
          await _firestore
              .collection("Students")
              .doc(studentID.toString())
              .update({
            "AttendanceDays": currentAttendance + 1,
            "isSync": 1, // إضافة هذا السطر لتحديث حالة المزامنة
          });
        } else {
          await _firestore
              .collection("Students")
              .doc(studentID.toString())
              .update({
            "AbsenceDays": currentAbsence + 1,
            "ReasonAbsence": absenceReasons,
            "isSync": 1, // إضافة هذا السطر لتحديث حالة المزامنة
          });
        }

        print("---------------> تم تحديث بيانات الحضور في Firestore بنجاح");
      } else {
        print(
            "---------------> لم يتم العثور على الطالب في Firestore برقم: $studentID");
      }
    } catch (e) {
      print("---------------> خطأ في تحديث بيانات الحضور في Firestore: $e");
    }
  }

  Future<List<ConservationPlanModel>> getConservationPlans(int halagaId) async {
    try {
      print(
          "-------------------> Fetching conservation plans from Firestore for halaga: $halagaId");

      // جلب الخطط من مجموعة ConservationPlans حيث elhalagatId يساوي halagaId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('ConservationPlans')
          .where('ElhalagatID', isEqualTo: halagaId)
          .get();

      print(
          "-------------------> Found ${querySnapshot.docs.length} conservation plans");

      // تحويل البيانات إلى نماذج ConservationPlanModel
      List<ConservationPlanModel> plans = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ConservationPlanModel(
          conservationPlanId: data['ConservationPlanID'],
          elhalagatId: data['ElhalagatID'],
          studentId: data['StudentID'],
          plannedStartSurah: data['PlannedStartSurah'],
          plannedStartAya: data['PlannedStartAya'],
          plannedEndSurah: data['PlannedEndSurah'],
          plannedEndAya: data['PlannedEndAya'],
          executedStartSurah: data['ExecutedStartSurah'],
          executedStartAya: data['ExecutedStartAya'],
          executedEndSurah: data['ExecutedEndSurah'],
          executedEndAya: data['ExecutedEndAya'],
          executedRate: data['executedRate']?.toDouble(),
          planMonth: data['planMonth'],
          isSync: data['isSync'] ?? 1,
        );
      }).toList();

      print("-------------------> Successfully converted plans to models");
      return plans;
    } catch (e) {
      print("-------------------> Error fetching conservation plans: $e");
      throw Exception('فشل في جلب خطط الحفظ: $e');
    }
  }

  /// جلب خطط التلاوة من Firestore
  Future<List<EltlawahPlanModel>> getEltlawahPlans(int halagaId) async {
    try {
      print(
          "-------------------> جاري جلب خطط التلاوة من Firestore للحلقة: $halagaId");

      // جلب الخطط من مجموعة EltlawahPlans حيث elhalagatId يساوي halagaId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('EltlawahPlans')
          .where('ElhalagatID', isEqualTo: halagaId)
          .get();

      print(
          "-------------------> تم العثور على ${querySnapshot.docs.length} خطة تلاوة");

      // تحويل البيانات إلى نماذج EltlawahPlanModel
      List<EltlawahPlanModel> plans = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EltlawahPlanModel(
          eltlawahPlanId: data['EltlawahPlanID'],
          elhalagatId: data['ElhalagatID'],
          studentId: data['StudentID'],
          plannedStartSurah: data['PlannedStartSurah'],
          plannedStartAya: data['PlannedStartAya'],
          plannedEndSurah: data['PlannedEndSurah'],
          plannedEndAya: data['PlannedEndAya'],
          executedStartSurah: data['ExecutedStartSurah'],
          executedStartAya: data['ExecutedStartAya'],
          executedEndSurah: data['ExecutedEndSurah'],
          executedEndAya: data['ExecutedEndAya'],
          executedRate: data['ExecutedRate']?.toDouble(),
          planMonth: data['PlanMonth'],
          isSync: data['isSync'] ?? 1,
        );
      }).toList();

      print("-------------------> تم تحويل خطط التلاوة بنجاح");
      return plans;
    } catch (e) {
      print("-------------------> خطأ في جلب خطط التلاوة: $e");
      throw Exception('فشل في جلب خطط التلاوة: $e');
    }
  }

  /// جلب خطط العلوم الشرعية من Firestore
  Future<List<IslamicStudiesModel>> getIslamicStudyPlans(int halagaId) async {
    try {
      print(
          "-------------------> جاري جلب خطط العلوم الشرعية من Firestore للحلقة: $halagaId");

      // جلب الخطط من مجموعة IslamicStudies حيث elhalagatId يساوي halagaId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('IslamicStudies')
          .where('ElhalagatID', isEqualTo: halagaId)
          .get();

      print(
          "-------------------> تم العثور على ${querySnapshot.docs.length} خطة علوم شرعية");

      // تحويل البيانات إلى نماذج IslamicStudiesModel
      List<IslamicStudiesModel> plans = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IslamicStudiesModel(
          islamicStudiesID: data['IslamicStudiesID'],
          elhalagatID: data['ElhalagatID'],
          studentID: data['StudentID'],
          subject: data['Subject'],
          plannedContent: data['PlannedContent'],
          executedContent: data['ExecutedContent'],
          planMonth: data['PlanMonth'],
          isSync: data['isSync'] ?? 1,
        );
      }).toList();

      print("-------------------> تم تحويل خطط العلوم الشرعية بنجاح");
      return plans;
    } catch (e) {
      print("-------------------> خطأ في جلب خطط العلوم الشرعية: $e");
      throw Exception('فشل في جلب خطط العلوم الشرعية: $e');
    }
  }
} // End of FirebaseHelper class

FirebaseHelper firebasehelper = FirebaseHelper();
