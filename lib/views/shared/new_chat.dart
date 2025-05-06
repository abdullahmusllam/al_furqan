import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:flutter/material.dart';

class NewConversationScreen extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel> availableUsers;

  const NewConversationScreen({
    required this.currentUser,
    required this.availableUsers,
    Key? key,
  }) : super(key: key);

  @override
  _NewConversationScreenState createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  UserModel? _selectedReceiver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محادثة جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // From field (read-only)
            Text(
              'من',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: TextEditingController(
                  text: widget.currentUser.first_name ?? 'Unknown'),
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),

            // To field (dropdown)
            Text(
              'الى',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<UserModel>(
              value: _selectedReceiver,
              hint: Text('أختر المستقبل'),
              items: widget.availableUsers.map((user) {
                return DropdownMenuItem<UserModel>(
                  value: user,
                  child: Text(user.first_name ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReceiver = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Message field
            Text(
              'المحتوى',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب الرساله هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            // Send button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_messageController.text.isEmpty ||
                      _selectedReceiver == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('عليك ملء كل الحقول')),
                    );
                    return;
                  }

                  final message = Message(
                    senderId: widget.currentUser.user_id,
                    receiverId: _selectedReceiver!.user_id,
                    content: _messageController.text,
                    timestamp: DateTime.now().toIso8601String(),
                    sync: 0,
                    senderType: widget.currentUser.roleID.toString(),
                  );

                  await firebaseHelper.saveMessage(message);
                  Navigator.pop(context); // Return to ChatScreen
                },
                child: Text('ارسال'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}