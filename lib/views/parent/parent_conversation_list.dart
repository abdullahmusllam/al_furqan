import '../../models/message.dart';
import '../../models/student.dart';
import '../../models/user.dart';
import '../../service/fierbase_service.dart';
import '../../service/message_sevice.dart';
import 'parent_message_screen.dart';
import 'parent_users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParentConversationsScreen extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel> availableTeachers;
  final List<UserModel>? availablePrincipals; // إضافة قائمة مديري المدارس

  const ParentConversationsScreen({
    Key? key,
    required this.currentUser,
    required this.availableTeachers,
    this.availablePrincipals, // إضافة مديري المدارس كمعلمة اختيارية
  }) : super(key: key);

  @override
  _ParentConversationsScreenState createState() =>
      _ParentConversationsScreenState();
}

class _ParentConversationsScreenState extends State<ParentConversationsScreen> {
  List<UserModel> conversationUsers = [];
  List<Student> children = [];
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    loadConversations();
    _loadChildren();
  }

  // تحميل بيانات أبناء ولي الأمر
  Future<void> _loadChildren() async {
    if (widget.currentUser.user_id != null) {
      final studentsList = await firestoreService
          .getStudentsByParentId(widget.currentUser.user_id!);
      if (mounted) {
        setState(() {
          children = studentsList;
        });
      }
    }
  }

  Future<void> loadConversations() async {
    try {
      // تحميل الرسائل من الخدمة
      List<Message> messages = await messageService.getAllMessages();
      Set<String> userIds = {};

      // جمع معرفات المستخدمين الذين تبادلوا الرسائل مع المستخدم الحالي
      for (var message in messages) {
        if (message.senderId == widget.currentUser.user_id &&
            message.receiverId != null) {
          userIds.add(message.receiverId!);
        } else if (message.receiverId == widget.currentUser.user_id &&
            message.senderId != null) {
          userIds.add(message.senderId!);
        }
      }

      // إنشاء قائمة المستخدمين من معرفاتهم
      List<UserModel> users = [];

      // إضافة المعلمين الذين تبادلوا الرسائل مع المستخدم الحالي
      for (var teacher in widget.availableTeachers) {
        if (teacher.user_id != null && userIds.contains(teacher.user_id)) {
          users.add(teacher);
          // إزالة المعرف من القائمة بعد إضافة المستخدم
          userIds.remove(teacher.user_id);
        }
      }

      // إضافة مديري المدارس الذين تبادلوا الرسائل مع المستخدم الحالي
      if (widget.availablePrincipals != null) {
        for (var principal in widget.availablePrincipals!) {
          if (principal.user_id != null &&
              userIds.contains(principal.user_id)) {
            users.add(principal);
            // إزالة المعرف من القائمة بعد إضافة المستخدم
            userIds.remove(principal.user_id);
          }
        }
      }

      // البحث عن المستخدمين المتبقين في Firestore
      for (String userId in userIds) {
        try {
          var doc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .get();

          if (doc.exists) {
            UserModel user =
                UserModel.fromJson(doc.data() as Map<String, dynamic>);
            users.add(user);
          } else {
            // إضافة مستخدم غير معروف إذا لم يتم العثور عليه
            users.add(UserModel(
              user_id: userId,
              first_name: 'مستخدم غير معروف',
              roleID: 0,
            ));
          }
        } catch (e) {
          print('خطأ في جلب المستخدم $userId: $e');
          // إضافة مستخدم غير معروف في حالة حدوث خطأ
          users.add(UserModel(
            user_id: userId,
            first_name: 'مستخدم غير معروف',
            roleID: 0,
          ));
        }
      }

      if (!mounted) return;
      setState(() {
        conversationUsers = users;
      });
    } catch (e) {
      print('خطأ في تحميل المحادثات: $e');
    }
  }

  // استخراج آخر رسالة لكل مستخدم
  Future<Map<String, Message>> _getLastMessages() async {
    List<Message> allMessages = await messageService.getAllMessages();
    Map<String, Message> lastMessages = {};

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
            icon: Icon(Icons.refresh),
            onPressed: loadConversations,
            tooltip: 'تحديث المحادثات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadConversations,
        child: FutureBuilder<Map<String, Message>>(
          future: _getLastMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                conversationUsers.isNotEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            final lastMessages = snapshot.data ?? {};

            return conversationUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Theme.of(context).disabledColor),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد محادثات',
                          style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('بدء محادثة جديدة'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParentUsersScreen(
                                  currentUser: widget.currentUser,
                                  availableTeachers: widget.availableTeachers,
                                  availablePrincipals:
                                      widget.availablePrincipals,
                                  children: children,
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
                          lastMessage.senderId != widget.currentUser.user_id &&
                          lastMessage.isRead ==
                              0; // فقط إذا كانت الرسالة غير مقروءة

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParentChatScreen(
                                currentUser: widget.currentUser,
                                selectedUser: user,
                              ),
                            ),
                          ).then((_) => loadConversations());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
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
                                            _formatTimestamp(
                                                lastMessage.timestamp),
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: user.roleID == 2
                                                ? Colors.blue.shade50
                                                : Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                            lastMessage?.content ??
                                                'لا توجد رسائل',
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
              builder: (context) => ParentUsersScreen(
                currentUser: widget.currentUser,
                availableTeachers: widget.availableTeachers,
                availablePrincipals:
                    widget.availablePrincipals, // تمرير قائمة مديري المدارس
                children: children, // تمرير قائمة أبناء ولي الأمر
              ),
            ),
          ).then((_) => loadConversations());
        },
        child: Icon(Icons.add_comment, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'محادثة جديدة',
      ),
    );
  }
}
