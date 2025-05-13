import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:al_furqan/views/shared/message_screen.dart';
import 'package:al_furqan/views/shared/users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel> availableParents;
  final List<UserModel> availableTeachers;

  const ConversationsScreen({
    Key? key,
    required this.currentUser,
    required this.availableParents,
    required this.availableTeachers,
  }) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<UserModel> conversationUsers = [];

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    await messageService.loadMessagesFromFirestore(widget.currentUser.user_id!);
    List<Message> messages = await messageController.getMessages();
    List<int> userIds = [];
    for (var message in messages) {
      if (message.senderId == widget.currentUser.user_id) {
        if (!userIds.contains(message.receiverId)) {
          userIds.add(message.receiverId!);
        }
      } else if (message.receiverId == widget.currentUser.user_id) {
        if (!userIds.contains(message.senderId)) {
          userIds.add(message.senderId!);
        }
      }
    }

    List<UserModel> users = [];
    for (int userId in userIds) {
      UserModel? user;
      for (var parent in widget.availableParents) {
        if (parent.user_id == userId) {
          user = parent;
          break;
        }
      }
      if (user == null) {
        for (var teacher in widget.availableTeachers) {
          if (teacher.user_id == userId) {
            user = teacher;
            break;
          }
        }
      }

      if (user == null) {
        try {
          var doc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId.toString())
              .get();
          if (doc.exists) {
            user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
          }
        } catch (e) {
          print('خطأ في جلب المستخدم $userId: $e');
        }
      }

      if (user == null) {
        user = UserModel(
          user_id: userId,
          first_name: 'مستخدم غير معروف',
          roleID: 0,
        );
      }

      users.add(user);
    }
    if(!mounted) return;
    setState(() {
      conversationUsers = users;
    });
  }

  // استخراج آخر رسالة لكل مستخدم
  Future<Map<int, Message>> _getLastMessages() async {
    List<Message> allMessages = await messageController.getMessages();
    Map<int, Message> lastMessages = {};
    
    for (var user in conversationUsers) {
      if (user.user_id == null) continue;
      
      // البحث عن آخر رسالة بين المستخدم الحالي والمستخدم في المحادثة
      List<Message> userMessages = allMessages
          .where((msg) =>
              (msg.senderId == widget.currentUser.user_id &&
                  msg.receiverId == user.user_id) ||
              (msg.senderId == user.user_id &&
                  msg.receiverId == widget.currentUser.user_id))
          .toList();
      
      if (userMessages.isNotEmpty) {
        // ترتيب الرسائل حسب الوقت (الأحدث أولاً)
        userMessages.sort((a, b) => 
          DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
        
        lastMessages[user.user_id!] = userMessages.first;
      }
    }
    
    return lastMessages;
  }

  // تنسيق التاريخ بشكل أفضل
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      if (messageDate == today) {
        // إذا كانت الرسالة اليوم، أظهر الوقت فقط
        return DateFormat('HH:mm').format(dateTime);
      } else if (messageDate == today.subtract(Duration(days: 1))) {
        // إذا كانت الرسالة بالأمس
        return 'أمس';
      } else {
        // غير ذلك، أظهر التاريخ
        return DateFormat('yyyy/MM/dd').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // يمكن إضافة وظيفة البحث في المستقبل
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('سيتم إضافة البحث قريباً'))
              );
            },
            tooltip: 'بحث',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadConversations,
            tooltip: 'تحديث المحادثات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadConversations,
        child: FutureBuilder<Map<int, Message>>(
          future: _getLastMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && conversationUsers.isNotEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            
            final lastMessages = snapshot.data ?? {};
            
            return conversationUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد محادثات',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('بدء محادثة جديدة'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UsersScreen(
                                  currentUser: widget.currentUser,
                                  availableParents: widget.availableParents,
                                  availableTeachers: widget.availableTeachers,
                                ),
                              ),
                            ).then((_) => loadConversations());
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: conversationUsers.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = conversationUsers[index];
                      final lastMessage = lastMessages[user.user_id];
                      final hasUnreadMessage = lastMessage != null && 
                          lastMessage.senderId != widget.currentUser.user_id;
                      
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                currentUser: widget.currentUser,
                                selectedUser: user,
                              ),
                            ),
                          ).then((_) => loadConversations());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          color: hasUnreadMessage ? Colors.blue.shade50 : null,
                          child: Row(
                            children: [
                              // صورة المستخدم
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: user.roleID == 2
                                    ? Colors.blue.shade100
                                    : Colors.green.shade100,
                                child: Text(
                                  user.first_name?[0] ?? '?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: user.roleID == 2
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // معلومات المحادثة
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.first_name ?? 'غير معروف',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: hasUnreadMessage 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (lastMessage != null)
                                          Text(
                                            _formatTimestamp(lastMessage.timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: hasUnreadMessage 
                                                  ? Colors.blue.shade700
                                                  : Colors.grey.shade600,
                                              fontWeight: hasUnreadMessage 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // نوع المستخدم
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: user.roleID == 2
                                                ? Colors.blue.shade50
                                                : Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user.roleID == 1
                                                ? 'مدير'
                                                : user.roleID == 2
                                                    ? 'معلم'
                                                    : 'ولي أمر',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: user.roleID == 2
                                                  ? Colors.blue.shade700
                                                  : Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // محتوى آخر رسالة
                                        Expanded(
                                          child: Text(
                                            lastMessage?.content ?? 'لا توجد رسائل',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: hasUnreadMessage 
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                              fontWeight: hasUnreadMessage 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        if (hasUnreadMessage)
                                          Container(
                                            margin: EdgeInsets.only(left: 8),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersScreen(
                currentUser: widget.currentUser,
                availableParents: widget.availableParents,
                availableTeachers: widget.availableTeachers,
              ),
            ),
          ).then((_) => loadConversations());
        },
        child: Icon(Icons.add_comment, color: Colors.white),
        backgroundColor: Colors.blue.shade700,
        tooltip: 'محادثة جديدة',
      ),
    );
  }
}