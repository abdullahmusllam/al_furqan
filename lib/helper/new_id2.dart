import 'package:uuid/uuid.dart';

Future<String> getMaxValue(String table, String column) async {
  try {
    // إنشاء UUID جديد
    var uuid = Uuid();
    String newId = uuid.v4(); // إنشاء UUID نسخة 4 (عشوائي)
    
    print("-------------------> جدول: $table");
    print("-------------------> عمود: $column");
    print("-------------------> UUID الجديد: $newId");
    
    return newId;
  } catch (e) {
    print('Error generating UUID: $e');
    // إنشاء UUID في حالة الخطأ أيضاً
    return Uuid().v4();
  }
}
