// This file contains Firebase service code, remove it entirely if not needed.
import 'package:al_furqan/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class firebaseHelper{
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
}

firebaseHelper firebasehelper = firebaseHelper();