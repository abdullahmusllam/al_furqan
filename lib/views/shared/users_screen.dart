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

  // دالة للبحث في المستخدمين
  List<UserModel> _filterUsers(String query) {
    if (query.isEmpty) return displayedUsers;
    
    return displayedUsers.where((user) {
      final name = user.first_name?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
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
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث عن مستخدم...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  displayedUsers = _filterUsers(value);
                });
              },
            ),
          ),
          
          // عنوان القسم
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.currentUser.roleID == 1 
                      ? (displayedUsers.isNotEmpty && displayedUsers[0].roleID == 2 
                          ? 'قائمة المعلمين' 
                          : 'قائمة أولياء الأمور')
                      : 'قائمة المستخدمين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${displayedUsers.length} مستخدم',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 8),
          
          // قائمة المستخدمين
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // إعادة بناء الصفحة
              },
              child: displayedUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            widget.currentUser.roleID == 1
                                ? 'اختر نوع المستخدم أو أضف مستخدمين'
                                : 'لا يوجد مستخدمين متاحين',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.currentUser.roleID == 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                onPressed: showUserTypeDialog,
                                child: Text('اختيار نوع المستخدم'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: displayedUsers.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];
                        return InkWell(
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: user.roleID == 2
                                          ? Colors.blue.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // معلومات المستخدم
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.first_name ?? 'غير معروف',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: user.roleID == 2
                                                  ? Colors.blue.shade50
                                                  : Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user.roleID == 2 ? 'معلم' : 'ولي أمر',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: user.roleID == 2
                                                    ? Colors.blue.shade700
                                                    : Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                          // المعلومات الإضافية للمستخدم
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                user.roleID == 2 ? 'معلم في المدرسة' : 'ولي أمر طالب',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // زر المحادثة
                                IconButton(
                                  icon: Icon(Icons.chat_outlined, color: Colors.blue.shade700),
                                  onPressed: () {
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
                                  tooltip: 'بدء محادثة',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}