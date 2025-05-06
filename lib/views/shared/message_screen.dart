import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:flutter/material.dart';
import '../../models/messages_model.dart';
import 'new_chat.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({required this.user, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  List<UserModel> _availableUsers = [];
  List<UserModel> _conversationUsers = [];
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
    _loadConversations();
  }

  // Load available users based on roleID
  Future<void> _loadAvailableUsers() async {
    List<UserModel> users = [];
    try {
      if (widget.user.roleID == 1) {
        print('===== Role is : ${widget.user.roleID} =====');
        // Manager: Load all parents for the school
        users = await fathersController.getFathersBySchoolId(widget.user.schoolID!);
        
        print('===== Manager loaded ${users.length} parents =====');
      } else if (widget.user.roleID == 2) {
        // Teacher: Load parents by elhalagatID
        users = await fathersController.getFathersByElhalagaId(widget.user.elhalagatID!);
        
        print('===== Teacher loaded ${users.length} parents =====');
      } else if (widget.user.roleID == 3) {
        // Parent: Load manager and teacher
        // TODO: Implement logic to fetch manager and teacher
      }
    } catch (e) {
      print('Error loading users: $e');
    }

    setState(() {
      _availableUsers = users;
    });
  }

  // Load users with whom the current user has conversations
  Future<void> _loadConversations() async {
    final messages = await messageController.getMessages();
    final userIds = <int>{};
    for (var msg in messages) {
      if (msg.senderId == widget.user.user_id) {
        userIds.add(msg.receiverId!);
      } else if (msg.receiverId == widget.user.user_id) {
        userIds.add(msg.senderId!);
      }
    }

    // Fetch UserModel for each user ID (assuming you have a way to get UserModel by ID)
    List<UserModel> conversationUsers = [];
    for (var id in userIds) {
      // Placeholder: Replace with actual logic to fetch UserModel by ID
      var user = _availableUsers.firstWhere(
        (u) => u.user_id == id,
        orElse: () => UserModel(
          user_id: id,
          first_name: 'Unknown',
          roleID: 0,
          schoolID: widget.user.schoolID,
        ),
      );
      conversationUsers.add(user);
    }

    setState(() {
      _conversationUsers = conversationUsers;
    });
  }

  // Load messages for the selected user
  Future<void> _loadMessages() async {
    if (_selectedUser == null) return;

    final messages = await messageController.getMessages();
    setState(() {
      _messages = messages
          .where((msg) =>
              (msg.senderId == widget.user.user_id &&
                  msg.receiverId == _selectedUser!.user_id) ||
              (msg.senderId == _selectedUser!.user_id &&
                  msg.receiverId == widget.user.user_id))
          .toList();
    });
  }

  // Send a new message
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _selectedUser == null) return;

    final message = Message(
      senderId: widget.user.user_id,
      receiverId: _selectedUser!.user_id,
      content: _controller.text,
      timestamp: DateTime.now().toIso8601String(),
      sync: 0,
      senderType: widget.user.roleID.toString(),
    );

    await firebaseHelper.saveMessage(message);
    _controller.clear();
    _loadMessages();
    _loadConversations(); // Refresh conversation list
  }

  // Delete a message
  Future<void> _deleteMessage(int localId) async {
    await firebaseHelper.deleteMessage(localId.toString(), localId);
    _loadMessages();
    _loadConversations(); // Refresh conversation list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedUser == null
            ? 'المحادثات'
            : 'محادثة مع ${_selectedUser!.first_name}'),
      ),
      body: _selectedUser == null ? _buildConversationList() : _buildChatView(),
      floatingActionButton: _selectedUser == null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewConversationScreen(
                      currentUser: widget.user,
                      availableUsers: _availableUsers,
                    ),
                  ),
                ).then((_) => _loadConversations()); // Refresh after returning
              },
              child: Icon(Icons.add_comment),
              tooltip: 'New Conversation',
            )
          : null,
    );
  }

  // Build the list of conversations
  Widget _buildConversationList() {
    return _conversationUsers.isEmpty
        ? Center(child: Text('لا توجد محادثات'))
        : ListView.builder(
            itemCount: _conversationUsers.length,
            itemBuilder: (context, index) {
              final user = _conversationUsers[index];
              return ListTile(
                title: Text(user.first_name ?? 'Unknown'),
                subtitle: Text(
                  user.roleID == 1
                      ? 'Manager'
                      : user.roleID == 2
                          ? 'Teacher'
                          : 'Parent',
                ),
                onTap: () {
                  setState(() {
                    _selectedUser = user;
                  });
                  _loadMessages();
                },
              );
            },
          );
  }

  // Build the chat view
  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isSender = message.senderId == widget.user.user_id;

              return ListTile(
                title: Text(message.content),
                subtitle: Text(message.timestamp),
                trailing: isSender
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteMessage(message.id!),
                      )
                    : null,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}