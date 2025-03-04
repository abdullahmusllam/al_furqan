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
}
