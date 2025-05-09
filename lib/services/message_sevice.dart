import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/messages_model.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check internet connectivity
  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn ;
  }

  // Save message to Firebase and local if online, otherwise only local
  Future<void> saveMessage(Message message) async {
    message.id = await someController.newId('messages', 'id');
    if (await isConnected()) {
      // Save to Firebase
      await _firestore.collection('messages').add(message.toJson());
      // Save to local with sync = 1
      message.sync = 1;
      await messageController.saveMessage(message, message.id!);
      print('===== تم اضافة المحادثة بنجاح =====');
    } else {
      // Save to local with sync = 0
      message.sync = 0;
      await messageController.saveMessage(message, message.id!);
      print('===== تم الاضافة لكن محليا =====');
    }
  }

  // Delete message from Firebase and local
  Future<void> deleteMessage(String firebaseId, int localId) async {

    if (await isConnected()) {
      await _firestore.collection('messages').doc(firebaseId).delete();
    }
    await messageController.deleteMessage(localId);
  }

  Future<void> updateMessage(Message message) async {
  if (await isConnected()) {
    // Update in Firebase
    await _firestore.collection('messages').doc(message.id.toString()).update(message.toJson());
    // Update local with sync = 1
    message.sync = 1;
    await messageController.updateMessage(message);
    print('===== تم تعديل المحادثة بنجاح =====');
  } else {
    // Update local with sync = 0
    message.sync = 0;
    await messageController.updateMessage(message);
    print('===== تم التعديل محليًا =====');
  }
}
}
FirebaseHelper firebaseHelper = FirebaseHelper();