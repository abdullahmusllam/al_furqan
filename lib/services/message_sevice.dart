import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/messages_model.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check internet connectivity
  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<void> loadMessagesFromFirestore(String receiverId) async {
    try {
      // جلب الرسائل من Firestore بناءً على receiverId
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('receiverId', isEqualTo: receiverId)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('============ فااااااارغ ============');
      }

      // حفظ الرسائل في قاعدة البيانات المحلية وتحويلها
      for (var doc in snapshot.docs) {
        Message message = Message.fromMap(doc.data() as Map<String, dynamic>);

        bool exists =
            await sqlDb.checkIfitemExists('messages', message.id!, 'id');
        debugPrint('================== 1');

        if (exists) {
          await messageService.updateMessage(message, 0);
          debugPrint('===== Find message (update) =====');
        } else {
          await messageService.saveMessage(message, 0);
          debugPrint('===== Find message (add) =====');
        }
      }
    } catch (e) {
      debugPrint('خطأ في جلب الرسائل من Firestore: $e');
    }
  }

  // Save message to Firebase and local if online, otherwise only local
  Future<void> saveMessage(Message message, int type) async {
    if (type == 1) {
      message.id = await someController.newId('messages', 'id');
      if (await isConnected()) {
        message.sync = 1;
        await _firestore
            .collection('messages')
            .doc(message.id.toString())
            .set(message.toJson());
        await messageController.saveMessage(message);
      } else {
        // Save to local with sync = 0
        message.sync = 0;
        await messageController.saveMessage(message);
        debugPrint('===== تم الاضافة لكن محليا =====');
      }
    } else {
      await messageController.saveMessage(message);
    }
    debugPrint('===== تم اضافة المحادثة بنجاح =====');
  }

  // Delete message from Firebase and local
  Future<void> deleteMessage(String firebaseId, int localId) async {
    if (await isConnected()) {
      await _firestore.collection('messages').doc(firebaseId).delete();
    }
    await messageController.deleteMessage(localId);
  }

  Future<void> updateMessage(Message message, int type) async {
    if (type == 1) {
      if (await isConnected()) {
        message.sync = 1;
        await _firestore
            .collection('messages')
            .doc(message.id.toString())
            .update(message.toJson());
        await messageController.updateMessage(message);
      } else {
        message.sync = 0;
        await messageController.updateMessage(message);
        debugPrint('===== تم التعديل محليا =====');
      }
    } else {
      await messageController.updateMessage(message);
    }
  }

  // تحديث حالة قراءة الرسائل في الفايربيس
  Future<void> updateMessagesReadStatus(String receiverId) async {
    try {
      if (await isConnected()) {
        // جلب الرسائل غير المقروءة مباشرة من فايربيس
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('receiverId', isEqualTo: receiverId)
            .where('isRead', isEqualTo: 0)
            .get();

        // تحديث كل رسالة في الفايربيس
        int updatedCount = 0;
        for (var doc in snapshot.docs) {
          await FirebaseFirestore.instance
              .collection('messages')
              .doc(doc.id)
              .update({'isRead': 1});
          updatedCount++;
        }

        debugPrint('تم تحديث حالة قراءة $updatedCount رسالة في الفايربيس');
      }
    } catch (e) {
      debugPrint('خطأ في تحديث حالة قراءة الرسائل في الفايربيس: $e');
    }
  }
}

FirebaseHelper messageService = FirebaseHelper();
