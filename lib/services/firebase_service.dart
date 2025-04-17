// This file contains Firebase service code, remove it entirely if not needed.
import 'package:al_furqan/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper{
 Future<void> add(int id, Map<String, dynamic> modelData, String collection) async {
  final modelRef = FirebaseFirestore.instance.collection('${collection}');

  if (modelData.isNotEmpty) {
    await modelRef.doc(id.toString()).set(
      modelData,
      SetOptions(merge: true), // دمج بدلاً من الاستبدال الكامل
    );
    print('تمت إضافة/تحديث العنص بالرقم $id بنجاح ');
  } else {
    print('studentData فارغ ');
  }
}

Future<Map<String, dynamic>?> getPrivateData(
  String collection,
  int id,
  String fieldName,
) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where(fieldName, isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print(' تم العثور على مستند');
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      print(' لا توجد مستندات تطابق الشرط');
      return null;
    }
  } catch (e) {
    print(' خطأ أثناء جلب البيانات: $e');
    return null;
  }
}

}
FirebaseHelper firebasehelper = FirebaseHelper();