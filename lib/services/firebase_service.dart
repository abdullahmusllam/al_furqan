// This file contains Firebase service code, remove it entirely if not needed.
import 'package:al_furqan/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper{
 Future<void> addStudent(int id, StudentModel StudentData, int schoolID) async {
  final StudentRef = FirebaseFirestore.instance.collection('Students');

  if (StudentData != Null) {
    await StudentRef.doc(id.toString()).set({
      'StudentID': id,
      'SchoolID': schoolID,
      'FirstName': StudentData.firstName,
      'MiddleName': StudentData.middleName,
      'grandfatherName': StudentData.grandfatherName,
      'LastName': StudentData.lastName
    }
    );
    print('تمت إضافة/تحديث العنص بالرقم $id بنجاح ');
  } else {
    print('studentData فارغ ');
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



}

FirebaseHelper firebasehelper = FirebaseHelper();