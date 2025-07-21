import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:flutter/cupertino.dart';

class MessageProvider with ChangeNotifier {
  final List<Message> messages = [];

  MessageProvider() {
    loadMessage();
    loadMessageFromFirebase();
  }

  loadMessage() async {
    List<Message> messagesList = await messageController.getMessages();
    messages.addAll(messagesList);
    notifyListeners();
  }

  loadMessageFromFirebase() async {
    String? id = perf.getString('user_id');
    await messageService.loadMessagesFromFirestore(id!);
    loadMessage();
  }
}
