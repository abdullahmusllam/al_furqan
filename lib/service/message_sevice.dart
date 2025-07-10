import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check internet connectivity
  Future<bool> isConnected() async {
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  // Generate a new ID for a message
  Future<int> _generateNewId() async {
    try {
      // Get the highest ID from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 1; // Start with ID 1 if no messages exist
      }

      // Extract the highest ID and increment by 1
      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      int highestId = data['id'] ?? 0;
      return highestId + 1;
    } catch (e) {
      print('خطأ في إنشاء معرف جديد: $e');
      // Fallback to timestamp-based ID
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  // Load messages from Firestore for a specific receiver
  Future<List<Message>> getMessagesByReceiverId(String receiverId) async {
    List<Message> messages = [];
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت');
        return [];
      }

      // Get messages from Firestore based on receiverId
      QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print('لا توجد رسائل في Firestore للمستلم: $receiverId');
        return [];
      }

      // Convert Firestore documents to Message objects
      for (var doc in snapshot.docs) {
        Message message = Message.fromMap(doc.data() as Map<String, dynamic>);
        messages.add(message);
      }

      return messages;
    } catch (e) {
      print('خطأ في جلب الرسائل من Firestore: $e');
      return [];
    }
  }

  // Get all messages from Firestore
  Future<List<Message>> getAllMessages() async {
    List<Message> messages = [];
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت');
        return [];
      }

      // Get all messages from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print('لا توجد رسائل في Firestore');
        return [];
      }

      // Convert Firestore documents to Message objects
      for (var doc in snapshot.docs) {
        Message message = Message.fromMap(doc.data() as Map<String, dynamic>);
        messages.add(message);
      }

      return messages;
    } catch (e) {
      print('خطأ في جلب جميع الرسائل: $e');
      return [];
    }
  }

  // Get conversation list (unique senders/receivers)
  Future<List<Message>> getConversationList(int userId) async {
    List<Message> conversations = [];
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت');
        return [];
      }

      // Get all messages where the user is sender or receiver
      QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where(Filter.or(Filter('senderId', isEqualTo: userId),
              Filter('receiverId', isEqualTo: userId)))
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print('لا توجد محادثات للمستخدم: $userId');
        return [];
      }

      // Process messages to get unique conversations
      Map<String, Message> latestMessageByContact = {};

      for (var doc in snapshot.docs) {
        Message message = Message.fromMap(doc.data() as Map<String, dynamic>);

        // Determine the contact ID (the other person in the conversation)
        String contactId = message.senderId == userId
            ? message.receiverId!
            : message.senderId!;

        // If we haven't seen this contact yet, or if this message is newer
        if (!latestMessageByContact.containsKey(contactId) ||
            message.timestamp
                    .compareTo(latestMessageByContact[contactId]!.timestamp) >
                0) {
          latestMessageByContact[contactId] = message;
        }
      }

      // Convert the map values to a list
      conversations = latestMessageByContact.values.toList();

      return conversations;
    } catch (e) {
      print('خطأ في جلب قائمة المحادثات: $e');
      return [];
    }
  }

  // Save message to Firebase
  Future<bool> saveMessage(Message message) async {
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت، لا يمكن إرسال الرسالة');
        return false;
      }

      // Generate a new ID if not provided
      if (message.id == null) {
        message.id = await _generateNewId();
      }

      // Set timestamp if not provided
      if (message.timestamp.isEmpty) {
        message.timestamp = DateTime.now().toIso8601String();
      }

      // Save to Firebase
      await _firestore
          .collection('messages')
          .doc(message.id.toString())
          .set(message.toJson());

      print('تم إرسال وحفظ الرسالة بنجاح');
      return true;
    } catch (e) {
      print('خطأ في حفظ الرسالة: $e');
      return false;
    }
  }

  // Delete message from Firebase
  Future<bool> deleteMessage(int messageId) async {
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت، لا يمكن حذف الرسالة');
        return false;
      }

      await _firestore
          .collection('messages')
          .doc(messageId.toString())
          .delete();

      print('تم حذف الرسالة بنجاح');
      return true;
    } catch (e) {
      print('خطأ في حذف الرسالة: $e');
      return false;
    }
  }

  // Update message in Firebase
  Future<bool> updateMessage(Message message) async {
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت، لا يمكن تحديث الرسالة');
        return false;
      }

      await _firestore
          .collection('messages')
          .doc(message.id.toString())
          .update(message.toJson());

      print('تم تحديث الرسالة بنجاح');
      return true;
    } catch (e) {
      print('خطأ في تحديث الرسالة: $e');
      return false;
    }
  }

  // Update read status of messages for a specific receiver
  Future<int> updateMessagesReadStatus(String receiverId) async {
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت، لا يمكن تحديث حالة القراءة');
        return 0;
      }

      // Get unread messages for the receiver
      QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: receiverId)
          .where('isRead', isEqualTo: 0)
          .get();

      int updatedCount = 0;

      // Update each message
      for (var doc in snapshot.docs) {
        await _firestore
            .collection('messages')
            .doc(doc.id)
            .update({'isRead': 1});
        updatedCount++;
      }

      print('تم تحديث حالة قراءة $updatedCount رسالة في Firestore');
      return updatedCount;
    } catch (e) {
      print('خطأ في تحديث حالة قراءة الرسائل: $e');
      return 0;
    }
  }

  // Get unread messages count for a specific receiver
  Future<int> getUnreadMessagesCount(int receiverId) async {
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت، لا يمكن جلب عدد الرسائل غير المقروءة');
        return 0;
      }

      // Get count of unread messages
      QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: receiverId)
          .where('isRead', isEqualTo: 0)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('خطأ في جلب عدد الرسائل غير المقروءة: $e');
      return 0;
    }
  }

  // Get messages between two users
  Future<List<Message>> getMessagesBetweenUsers(
      String userId1, String userId2) async {
    List<Message> messages = [];
    try {
      if (!await isConnected()) {
        print('لا يوجد اتصال بالإنترنت');
        return [];
      }

      // استخدام استعلامين منفصلين بدلاً من استعلام مركب
      // الاستعلام الأول: الرسائل من المستخدم 1 إلى المستخدم 2
      QuerySnapshot snapshot1 = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: userId1)
          .where('receiverId', isEqualTo: userId2)
          .get();

      // الاستعلام الثاني: الرسائل من المستخدم 2 إلى المستخدم 1
      QuerySnapshot snapshot2 = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .get();

      // دمج نتائج الاستعلامين
      List<QueryDocumentSnapshot> allDocs = [];
      allDocs.addAll(snapshot1.docs);
      allDocs.addAll(snapshot2.docs);

      if (allDocs.isEmpty) {
        print('لا توجد رسائل بين المستخدمين $userId1 و $userId2');
        return [];
      }

      // Convert Firestore documents to Message objects
      for (var doc in allDocs) {
        Message message = Message.fromMap(doc.data() as Map<String, dynamic>);
        messages.add(message);
      }

      // ترتيب الرسائل حسب الوقت
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    } catch (e) {
      print('خطأ في جلب الرسائل بين المستخدمين: $e');
      return [];
    }
  }
}

// Singleton instance
final messageService = MessageService();
