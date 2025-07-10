import '../../models/user.dart';
import '../../models/student.dart';
import 'parent_message_screen.dart';
import 'package:flutter/material.dart';

class ParentUsersScreen extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel> availableTeachers;
  final List<UserModel>? availablePrincipals; // إضافة قائمة مديري المدارس
  final List<Student> children; // إضافة قائمة أبناء ولي الأمر

  const ParentUsersScreen({
    Key? key,
    required this.currentUser,
    required this.availableTeachers,
    this.availablePrincipals, // إضافة مديري المدارس كمعلمة اختيارية
    required this.children, // إضافة أبناء ولي الأمر كمعلمة مطلوبة
  }) : super(key: key);

  @override
  _ParentUsersScreenState createState() => _ParentUsersScreenState();
}

class _ParentUsersScreenState extends State<ParentUsersScreen> {
  List<UserModel> displayedUsers = [];
  List<UserModel> allUsers = [];
  bool showTeachers = true;
  bool showPrincipals = true;

  @override
  void initState() {
    super.initState();
    // جمع المعلمين ومديري المدارس في قائمة واحدة
    allUsers = [];

    // استخراج قائمة معرفات الحلقات الخاصة بأبناء ولي الأمر
    final List<int?> childrenHalaqatIds = widget.children
        .map((child) => child.elhalagatID)
        .where((id) => id != null)
        .toList();

    // استخراج قائمة معرفات المدارس الخاصة بأبناء ولي الأمر
    final List<int?> childrenSchoolIds = widget.children
        .map((child) => child.schoolID)
        .where((id) => id != null)
        .toList();

    // إضافة المعلمين الذين يشتركون في نفس معرف الحلقة مع أبناء ولي الأمر
    allUsers.addAll(widget.availableTeachers
        .where((user) =>
            user.user_id != null &&
            user.user_id != '' &&
            user.elhalagatID != null &&
            childrenHalaqatIds.contains(user.elhalagatID))
        .toList());

    // إضافة مديري المدارس الذين يشتركون في نفس معرف المدرسة مع أبناء ولي الأمر
    if (widget.availablePrincipals != null) {
      allUsers.addAll(widget.availablePrincipals!
          .where((user) =>
              user.user_id != null &&
              user.user_id != '' &&
              user.schoolID != null &&
              childrenSchoolIds.contains(user.schoolID))
          .toList());
    }

    // تعيين قائمة المستخدمين المعروضة
    displayedUsers = List.from(allUsers);
  }

  // دالة للبحث في المستخدمين
  List<UserModel> _filterUsers(String query) {
    // تصفية المستخدمين حسب الأدوار المحددة
    List<UserModel> filteredByRole = allUsers.where((user) {
      if (user.roleID == 2 && !showTeachers) return false; // معلم
      if (user.roleID == 1 && !showPrincipals) return false; // مدير
      return true;
    }).toList();

    // إذا كان البحث فارغًا، أعد القائمة المصفاة حسب الدور فقط
    if (query.isEmpty) return filteredByRole;

    // تصفية حسب الاسم والدور
    return filteredByRole.where((user) {
      final name = user.first_name?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار مستخدم للمراسلة',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  displayedUsers = _filterUsers(value);
                });
              },
            ),
          ),

          // خيارات التصفية
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'تصفية حسب:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 12),
                // خيار المعلمين
                FilterChip(
                  label: Text('المعلمين'),
                  selected: showTeachers,
                  onSelected: (selected) {
                    setState(() {
                      showTeachers = selected;
                      displayedUsers = _filterUsers('');
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade700,
                ),
                SizedBox(width: 8),
                // خيار المديرين
                FilterChip(
                  label: Text('المديرين'),
                  selected: showPrincipals,
                  onSelected: (selected) {
                    setState(() {
                      showPrincipals = selected;
                      displayedUsers = _filterUsers('');
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green.shade700,
                ),
              ],
            ),
          ),

          // عنوان القسم
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showTeachers && showPrincipals
                      ? 'قائمة المستخدمين'
                      : showTeachers
                          ? 'قائمة المعلمين'
                          : showPrincipals
                              ? 'قائمة المديرين'
                              : 'لا يوجد مستخدمين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${displayedUsers.length} ' +
                      (showTeachers && showPrincipals
                          ? 'مستخدم'
                          : showTeachers
                              ? 'معلم'
                              : showPrincipals
                                  ? 'مدير'
                                  : ''),
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
                          Icon(Icons.person_off,
                              size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            'لا يوجد معلمين متاحين للمراسلة',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: displayedUsers.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];
                        return InkWell(
                          onTap: () {
                            print(
                                'اختيار معلم: ${user.first_name}, user_id: ${user.user_id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParentChatScreen(
                                  currentUser: widget.currentUser,
                                  selectedUser: user,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                // صورة المستخدم
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    user.first_name?[0] ?? '?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // معلومات المستخدم
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: user.roleID == 1
                                                  ? Colors.green.shade50
                                                  : Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user.roleID == 1
                                                  ? 'مدير'
                                                  : 'معلم',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: user.roleID == 1
                                                    ? Colors.green.shade700
                                                    : Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                          // المعلومات الإضافية للمستخدم
                                          if (user.elhalagatName != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Text(
                                                user.elhalagatName!,
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
                                  icon: Icon(Icons.chat_outlined,
                                      color: Colors.blue.shade700),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ParentChatScreen(
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
