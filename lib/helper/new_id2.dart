import 'package:sqflite/sqflite.dart';
import 'sqldb.dart';

Future<int> newId2(String table, String column) async {
  final SqlDb sqlDb = SqlDb();
  try {
    return await sqlDb.transaction((txn) async {
      // جلب أكبر معرف من الجدول
      List<Map> response =
          await txn.rawQuery("SELECT MAX($column) AS max_id FROM $table");
      int maxId =
          response[0]['max_id'] != null ? response[0]['max_id'] as int : 0;
      return maxId + 1; // المعرف الجديد هو أكبر معرف + 1
    });
  } catch (e) {
    print("Error generating new ID for $table.$column: $e");
    return -1; // في حالة الخطأ
  }
}
