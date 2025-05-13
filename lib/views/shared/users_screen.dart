import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/shared/message_screen.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel> availableParents;
  final List<UserModel> availableTeachers;

  const UsersScreen({
    Key? key,
    required this.currentUser,
    required this.availableParents,
    required this.availableTeachers,
  }) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> displayedUsers = [];

  @override
  void initState() {
    super.initState();
    if (widget.currentUser.roleID != 1) {
      displayedUsers = widget.availableParents
          .where((user) => user.user_id != null && user.user_id != 0)
          .toList();
    }
  }

  void showUserTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('اختيار نوع المحادثة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('مراسلة معلم',
                    style: TextStyle(color: Colors.grey.shade700)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    displayedUsers = widget.availableTeachers
                        .where((user) => user.user_id != null && user.user_id != 0)
                        .toList();
                  });
                },
              ),
              ListTile(
                title: Text('مراسلة ولي أمر',
                    style: TextStyle(color: Colors.grey.shade700)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    displayedUsers = widget.availableParents
                        .where((user) => user.user_id != null && user.user_id != 0)
                        .toList();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser.roleID == 1 && displayedUsers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUserTypeDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار مستخدم', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: widget.currentUser.roleID == 1
            ? [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: showUserTypeDialog,
                  tooltip: 'تصفية المستخدمين',
                ),
              ]
            : [],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // إعادة بناء الصفحة
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: displayedUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          widget.currentUser.roleID == 1
                              ? 'اختر نوع المستخدم أو أضف مستخدمين'
                              : 'لا يوجد مستخدمين متاحين',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: displayedUsers.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final user = displayedUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user.roleID == 2
                                  ? Colors.blue.shade100
                                  : Colors.green.shade100,
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
                              user.roleID == 2 ? 'معلم' : 'ولي أمر',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            onTap: () {
                              print('اختيار مستخدم: ${user.first_name}, user_id: ${user.user_id}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    currentUser: widget.currentUser,
                                    selectedUser: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}