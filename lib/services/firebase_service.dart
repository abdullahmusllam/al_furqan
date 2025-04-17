// This file contains Firebase service code, remove it entirely if not needed.
import 'package:al_furqan/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/users_model.dart';
/// غيرت اسم الكلاس كانه يبدأ بحرف صغير f ذالحين خليته F اصلا اي كلاس الاصل أول حرف منه كبير بس شكلها راحت عليك
class FirebaseHelper{
  /// تقصيرر للكود
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addStudent(StudentModel studentData) async {
    final studentsRef = FirebaseFirestore.instance.collection('students');

    // الخطوة 1: الحصول على أعلى ID موجود
    final snapshot = await studentsRef.get();

    int newId = 1;
    if (snapshot.docs.isNotEmpty) {
      final ids = snapshot.docs
          .map((doc) => int.tryParse(doc.id) ?? 0)
          .toList()
        ..sort();

      newId = ids.last + 1;
    }


    // الخطوة 2: إضافة الطالب الجديد بالـ ID الجديد
    await studentsRef.doc(newId.toString()).set({
      'schoolId': studentData.SchoolId,
      'firstName': studentData.firstName,
      'middleName': studentData.middleName,
      'grandfatherName': studentData.grandfatherName,
      'lastName': studentData.lastName
    });

    print('تمت إضافة الطالب بالرقم $newId بنجاح ✅');
  }
  /// دالة تجيب المستخدمين من الفايربيس وتتحقق من الاتصال أول شيئ
  Future<List<UserModel>> getUsers() async {
    // 1. التحقق من الاتصال بالإنترنت
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }

    try {
      // 2. جلب البيانات من Firestore
      QuerySnapshot response = await _firestore
          .collection('users')
          .get();

      // 3. تحويل البيانات إلى List<UserModel>
      return response.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return UserModel(
          user_id: int.tryParse(doc.id),
          first_name: data['first_name'] ?? '',
          middle_name: data['middle_name'] ?? '',
          grandfather_name: data['grandfather_name'] ?? '',
          last_name: data['last_name'] ?? '',
          phone_number: int.tryParse(data['phone_number'].toString()) ?? 0,
          telephone_number: int.tryParse(data['telephone_number'].toString()) ?? 0,
          email: data['email'] ?? '',
          password: data['password'] as int? ?? 0,
          roleID: data['roleID'] as int? ?? 0,
          schoolID: data['schoolID'] as int? ?? 0,
          date: data['date'] ?? '',
          isActivate: data['isActivate'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب البيانات من Firestore: $e');
    }
  }

  // Future<int>addUser(){
  //
  // }
}
/// غيرت اسم الكلاس كانه يبدأ بحرف صغير f ذالحين خليته F اصلا اي كلاس الاصل أول حرف منه كبير بس شكلها راحت عليك
FirebaseHelper firebasehelper = FirebaseHelper();