import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../service/fierbase_service.dart';

class ChatScreen extends StatefulWidget {
  final UserModel parent;

  ChatScreen({required this.parent});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  List<UserModel> _contacts = [];
  UserModel? _selectedContact;
  List<Message> _messages = [];
  Student? _studentData;
  int? _circleId; // معرف الحلقة

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    // جلب بيانات الطالب المرتبط بولي الأمر
    Student? student = await _firestoreService.getStudentByUserId(widget.parent.user_id.toString());
    
    if (student != null) {
      setState(() {
        _studentData = student;
        // استخدام معرف الحلقة من الطالب
        _circleId = student.elhalagatID;
      });
      
      // جلب المدرسين المرتبطين بحلقة الطالب
      if (_circleId != null) {
        _loadTeachers();
      } else {
        // إذا لم يكن هناك حلقة مرتبطة، يتم عرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا توجد حلقة مرتبطة بالطالب')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يتم العثور على بيانات الطالب')),
      );
    }
  }
  
  Future<void> _loadTeachers() async {
    if (_circleId == null) return;
    
    List<UserModel> teachers = await _firestoreService.getTeachersByCircleId(_circleId!);
    setState(() {
      _contacts = teachers;
    });
  }

  Future<void> _loadMessages() async {
    if (_selectedContact == null || _circleId == null) return;
    List<Message> messages = await _firestoreService.getMessages(
      widget.parent.user_id.toString(),
      _selectedContact!.user_id.toString(),
      _circleId.toString(),
    );
    setState(() {
      _messages = messages;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار جهة اتصال وكتابة رسالة')),
      );
      return;
    }

    Message message = Message(
      senderId: widget.parent.user_id.toString(),
      receiverId: _selectedContact!.user_id.toString(),
      content: _messageController.text,
      timestamp: DateTime.now().toIso8601String(),
      senderType: widget.parent.roleID.toString(),
      receiverType: _selectedContact!.roleID.toString(),
      circleId: _circleId.toString(),
    );

    await _firestoreService.sendMessage(message);
    _messageController.clear();
    _loadMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال الرسالة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرسائل'),
        backgroundColor: Colors.teal,
        actions: [
          if (_selectedContact != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadMessages,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_studentData != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      color: Colors.teal.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('بيانات الطالب:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('الاسم: ${_studentData!.fullName}'),
                            Text('رقم المدرسة: ${_studentData!.schoolID ?? "غير محدد"}'),
                            Text('أيام الحضور: ${_studentData!.attendanceDays ?? 0}'),
                            Text('أيام الغياب: ${_studentData!.absenceDays ?? 0}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                Text('اختر المدرس للتواصل:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                DropdownButton<UserModel>(
                  hint: Text('اختر المدرس'),
                  value: _selectedContact,
                  isExpanded: true,
                  items: _contacts.map((contact) {
                    return DropdownMenuItem<UserModel>(
                      value: contact,
                      child: Text('${contact.first_name} (مدرس)'),
                    );
                  }).toList(),
                  onChanged: (UserModel? newContact) {
                    setState(() {
                      _selectedContact = newContact;
                      _messages = [];
                      if (newContact != null) {
                        _loadMessages();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedContact == null
                ? Center(child: Text('يرجى اختيار جهة اتصال'))
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: _messages.isEmpty
                        ? Center(child: Text('لا توجد رسائل'))
                        : ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isSender = message.senderId == widget.parent.user_id.toString();
                              return ListTile(
                                title: Align(
                                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSender ? Colors.teal.shade100 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(message.content),
                                  ),
                                ),
                                subtitle: Align(
                                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(message.timestamp)),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
          if (_selectedContact != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.teal),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}