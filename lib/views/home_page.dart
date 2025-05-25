// import 'package:firebase_auth/firebase_auth.dart';
import 'package:father/views/student_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/fierbase_service.dart';
import '../views/student_details_screen.dart';
import '../views/chat_screen.dart';
// import '../views/auth_service.dart';

import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _parent;

  @override
  void initState() {
    super.initState();
    _loadParent();
  }

  Future<void> _loadParent() async {
    try {
      // الحصول على معرف المستخدم من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      
      if (userId != null) {
        // جلب بيانات ولي الأمر من Firestore
        UserModel? parent = await _firestoreService.getUser(userId);
        setState(() {
          _parent = parent;
        });
      }
    } catch (e) {
      print('خطأ في تحميل بيانات ولي الأمر: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تطبيق ولي الأمر', style: TextStyle(fontFamily: 'RB', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
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
                // await _authService.signOut();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => LoginScreen()),
                // );
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
            colors: [Colors.green.shade100, Colors.white],
          ),
        ),
        child: _parent == null
          ? Center(child: CircularProgressIndicator(color: Colors.green.shade700))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green.shade600,
                          child: Text(
                            (_parent!.first_name ?? '').isNotEmpty ? (_parent!.first_name ?? '').substring(0, 1) : '',
                            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحبًا،',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'RB'),
                            ),
                            Text(
                              '${_parent!.first_name}',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'RB'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'الخدمات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'RB', color: Colors.green.shade800),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.person, color: Colors.green.shade700),
                      ),
                      title: Text(' أبنائي', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RB', fontSize: 16)),
                      subtitle: Text('عرض معلومات الطالب والحضور والغياب', style: TextStyle(fontFamily: 'RB', fontSize: 12, color: Colors.grey.shade600)),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade700, size: 16),
                      onTap: () async {
                        // جلب بيانات الطالب المرتبط بولي الأمر
                        if (_parent != null && _parent!.user_id != null) {
                          // جلب قائمة الطلاب المرتبطين بولي الأمر
                          final students = await _firestoreService.getStudentsByParentId(_parent!.user_id!);
                          
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
                              SnackBar(content: Text('لم يتم العثور على طلاب مرتبطين بهذا الحساب')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('حدث خطأ في تحميل بيانات ولي الأمر')),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.message, color: Colors.green.shade700),
                      ),
                      title: Text('الرسائل', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RB', fontSize: 16)),
                      subtitle: Text('التواصل مع المعلمين والإدارة', style: TextStyle(fontFamily: 'RB', fontSize: 12, color: Colors.grey.shade600)),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade700, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(parent: _parent!),
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