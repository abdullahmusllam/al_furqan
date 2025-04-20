// import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper/sqldb.dart';

class SomeController {
  final SqlDb _sqlDb = SqlDb();

  // Replace Firestore usage with local database logic
  Future<void> getData() async {
    // Query Firestore
    // QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('collection').get();

    // Use local database instead
    List<Map> response = await _sqlDb.readData("SELECT * FROM 'collection'");
    // ...process response...
  }
 Future<int> newId(String table, String column) async {
  List<Map> response = await _sqlDb.readData("SELECT MAX($column) AS max_id FROM $table");

  var maxId = response[0]['max_id'];
  // var maxID=response.last['max_id'];
  if (maxId == null) {
    return 1; // يعني أول رقم جديد
  }
  return maxId + 1;
}

  }

SomeController someController = SomeController();