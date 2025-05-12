import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:al_furqan/views/shared/message_screen.dart';
import 'package:al_furqan/views/shared/users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    print('=============================');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor, // لون SchoolManagerScreen
        foregroundColor: Colors.white,
        elevation: 0, // بدون ظل
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadConversations, // تحديث المحادثات
            tooltip: 'تحديث المحادثات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadConversations, // دعم السحب للتحديث
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0), // حشوة عامة
            child: conversationUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.red), // أيقونة خطأ
                        SizedBox(height: 16),
                        Text(
                          'لا توجد محادثات',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 4, // ظل البطاقة
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: conversationUsers.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final user = conversationUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user.roleID == 2
                                  ? Colors.blue.shade100 // لون المعلمين
                                  : Colors.green.shade100, // لون أولياء الأمور
                              child: Text(
                                user.first_name?[0] ?? '?',
                                style: TextStyle(
                                    color: user.roleID == 2
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700),
                              ),
                            ),
                            title: Text(
                              user.first_name ?? 'غير معروف',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              user.roleID == 1
                                  ? 'مدير'
                                  : user.roleID == 2
                                      ? 'معلم'
                                      : 'ولي أمر',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
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
                          );
                        },
                      ),
                    ),
                  ),
          ),
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
        backgroundColor: Theme.of(context).primaryColor, // لون SchoolManagerScreen
        tooltip: 'محادثة جديدة',
      ),
    );
  }
}