import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel? selectedUser;

  const ChatScreen({
    Key? key,
    required this.currentUser,
    this.selectedUser,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  List<Message> receivedMessages = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedUser != null) {
      loadMessages();
    } else {
      loadReceivedMessages();
    }
  }

  // دالة لتحميل المحادثة بين المستخدم الحالي والمستخدم المختار
  Future<void> loadMessages() async {
    if (widget.selectedUser == null || widget.selectedUser!.user_id == null) {
      print('خطأ: لا يوجد مستخدم مختار أو معرف المستخدم غير موجود');
      return;
    }

    List<Message> allMessages = await messageController.getMessages();
    setState(() {
      messages = allMessages
          .where((msg) =>
              (msg.senderId == widget.currentUser.user_id &&
                  msg.receiverId == widget.selectedUser!.user_id) ||
              (msg.senderId == widget.selectedUser!.user_id &&
                  msg.receiverId == widget.currentUser.user_id))
          .toList();
    });
  }

  // دالة لتحميل الرسائل المرسلة إلى المستخدم الحالي فقط
  Future<void> loadReceivedMessages() async {
    if (widget.currentUser.user_id == null) {
      print('خطأ: معرف المستخدم الحالي غير موجود');
      return;
    }

    List<Message> allMessages = await messageController.getMessages();
    setState(() {
      receivedMessages = allMessages
          .where((msg) => msg.receiverId == widget.currentUser.user_id)
          .toList();
    });
  }

  // دالة لإرسال رسالة جديدة
  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال رسالة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.selectedUser == null || widget.selectedUser!.user_id == null) {
      print('خطأ: لا يمكن إرسال رسالة بدون مستخدم مختار');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: اختر مستخدمًا للمراسلة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final message = Message(
      senderId: widget.currentUser.user_id,
      receiverId: widget.selectedUser!.user_id!,
      content: _controller.text,
      timestamp: DateTime.now().toIso8601String(),
      sync: 0,
      senderType: widget.currentUser.roleID.toString(),
    );

    try {
      await messageService.saveMessage(message, 1);
      _controller.clear();
      loadMessages(); // تحديث الرسائل بعد الإرسال
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال الرسالة'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('خطأ في إرسال الرسالة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال الرسالة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة لحذف رسالة
  Future<void> deleteMessage(int messageId) async {
    await messageService.deleteMessage(messageId.toString(), messageId);
    loadMessages(); // تحديث الرسائل بعد الحذف
    loadReceivedMessages(); // تحديث الرسائل المستلمة
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showReceivedMessages = widget.selectedUser == null;
    List<Message> displayMessages = showReceivedMessages ? receivedMessages : messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showReceivedMessages
              ? 'الرسائل المستلمة'
              : 'محادثة مع ${widget.selectedUser!.first_name}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: showReceivedMessages ? loadReceivedMessages : loadMessages,
            tooltip: 'تحديث الرسائل',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: showReceivedMessages ? loadReceivedMessages : loadMessages,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: displayMessages.isEmpty
                    ? Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.message, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                showReceivedMessages
                                    ? 'لا توجد رسائل مستلمة'
                                    : 'لا توجد رسائل، ابدأ المحادثة!',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: displayMessages.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final message = displayMessages[index];
                          final isSender =
                              message.senderId == widget.currentUser.user_id;

                          return ListTile(
                            title: Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSender
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message.content,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            subtitle: Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                message.timestamp,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ),
                            trailing: isSender
                                ? IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteMessage(message.id!),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: !showReceivedMessages
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                    onPressed: sendMessage,
                    tooltip: 'إرسال',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}