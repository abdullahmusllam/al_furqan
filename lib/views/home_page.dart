// import 'package:firebase_auth/firebase_auth.dart';
import 'package:father/views/auth/login.dart';
import 'package:father/views/parent/parent_conversation_list.dart';
import 'package:father/views/student_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/fierbase_service.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  final List<UserModel> availableTeachers;

  const HomeScreen({Key? key, this.availableTeachers = const []})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _parent;
  List<UserModel> _availableTeachers = [];
  List<UserModel> _availablePrincipals = []; // إضافة قائمة لمديري المدارس

  @override
  void initState() {
    super.initState();
    _loadParent();
    _loadTeachers();
  }

  Future<void> _loadParent() async {
    try {
      // الحصول على معرف المستخدم من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId != null) {
        // جلب بيانات ولي الأمر من Firestore
        UserModel? parent = await _firestoreService.getUser(userId);

        if (!mounted) return; // Check if widget is still mounted

        setState(() {
          _parent = parent;
        });
      }
    } catch (e) {
      print('خطأ في تحميل بيانات ولي الأمر: $e');
    }
  }

  Future<void> _loadTeachers() async {
    try {
      // استخدام القائمة المتوفرة من widget إذا كانت غير فارغة
      if (widget.availableTeachers.isNotEmpty) {
        setState(() {
          _availableTeachers = widget.availableTeachers;
        });
        return;
      }

      // جلب المدرسين من Firestore (roleID = 2)
      List<UserModel> teachers =
          await _firestoreService.getUsersByRole(2); // 2 = معلم

      // جلب مديري المدارس من Firestore (roleID = 1)
      List<UserModel> principals =
          await _firestoreService.getUsersByRole(1); // 1 = مدير

      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _availableTeachers = teachers;
        _availablePrincipals = principals;
      });
    } catch (e) {
      print('خطأ في تحميل بيانات المدرسين والمديرين: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_parent?.first_name ?? '',
            style: TextStyle(
                fontFamily: 'RB',
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF017546),
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5F0),
              Colors.white
            ], // Light version of #017546
          ),
        ),
        child: _parent == null
            ? Center(child: CircularProgressIndicator(color: Color(0xFF017546)))
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   padding: EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(15),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Color(0xFF017546).withOpacity(0.1),
                    //         spreadRadius: 2,
                    //         blurRadius: 5,
                    //         offset: Offset(0, 3),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 30,
                    //         backgroundColor: Color(0xFF017546),
                    //         child: Text(
                    //           (_parent!.first_name ?? '').isNotEmpty
                    //               ? (_parent!.first_name ?? '').substring(0, 1)
                    //               : '',
                    //           style: TextStyle(
                    //               fontSize: 24,
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.bold),
                    //         ),
                    //       ),
                    //       SizedBox(width: 16),
                    //       // Column(
                    //       //   crossAxisAlignment: CrossAxisAlignment.start,
                    //       //   children: [
                    //       //     Text(
                    //       //       'مرحبًا،',
                    //       //       style: TextStyle(
                    //       //           fontSize: 16,
                    //       //           color: Colors.grey.shade700,
                    //       //           fontFamily: 'RB'),
                    //       //     ),
                    //       //     Text(
                    //       //       '${_parent!.first_name}',
                    //       //       style: TextStyle(
                    //       //           fontSize: 24,
                    //       //           fontWeight: FontWeight.bold,
                    //       //           fontFamily: 'RB'),
                    //       //     ),
                    //       //   ],
                    //       // ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 24),
                    Text(
                      'الخدمات',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RB',
                          color: Color(0xFF017546)),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Color(0xFFE8F5F0), // Light version of #017546
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.person, color: Color(0xFF017546)),
                        ),
                        title: Text(' أبنائي',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RB',
                                fontSize: 16)),
                        subtitle: Text('عرض معلومات الطالب والحضور والغياب',
                            style: TextStyle(
                                fontFamily: 'RB',
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF017546), size: 16),
                        onTap: () async {
                          // جلب بيانات الطالب المرتبط بولي الأمر
                          if (_parent != null && _parent!.user_id != null) {
                            // جلب قائمة الطلاب المرتبطين بولي الأمر
                            final students = await _firestoreService
                                .getStudentsByParentId(_parent!.user_id!);

                            if (students.isNotEmpty) {
                              // الانتقال إلى صفحة تفاصيل الطالب مع كائن الطالب الأول
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentListScreen(),
                                ),
                              );
                            } else {
                              // إذا لم يتم العثور على طلاب
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'لم يتم العثور على طلاب مرتبطين بهذا الحساب')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'حدث خطأ في تحميل بيانات ولي الأمر')),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Color(0xFFE8F5F0), // Light version of #017546
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.message, color: Color(0xFF017546)),
                        ),
                        title: Text('الرسائل',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RB',
                                fontSize: 16)),
                        subtitle: Text('التواصل مع المعلمين والإدارة',
                            style: TextStyle(
                                fontFamily: 'RB',
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF017546), size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParentConversationsScreen(
                                  currentUser: _parent!,
                                  availableTeachers: _availableTeachers,
                                  availablePrincipals:
                                      _availablePrincipals), // إضافة قائمة مديري المدارس
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
