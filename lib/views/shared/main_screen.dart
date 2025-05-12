import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/shared/Conversation_list.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final UserModel currentUser;

  const MainScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<UserModel> parents = [];
  List<UserModel> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      if (widget.currentUser.roleID == 1) {
        print('تحميل المستخدمين للمدير، schoolID: ${widget.currentUser.schoolID}');
        parents = (await fathersController.getFathersBySchoolId(widget.currentUser.schoolID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        print('تم تحميل ${parents.length} من أولياء الأمور: ${parents.map((p) => p.first_name).toList()}');
        teachers = (await halagaController.getTeachers(widget.currentUser.schoolID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        print('تم تحميل ${teachers.length} من المعلمين: ${teachers.map((t) => "${t.first_name} (ID: ${t.user_id})").toList()}');
      } else if (widget.currentUser.roleID == 2) {
        parents = (await fathersController.getFathersByElhalagaId(widget.currentUser.elhalagatID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        print('تم تحميل ${parents.length} من أولياء الأمور: ${parents.map((p) => p.first_name).toList()}');
      } else {
        print('دور المستخدم غير مدعوم: ${widget.currentUser.roleID}');
      }
    } catch (e) {
      print('خطأ في تحميل المستخدمين: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل المستخدمين'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('جاري التحميل...', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              SizedBox(height: 16),
              Text(
                'جاري تحميل البيانات...',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ConversationsScreen(
      currentUser: widget.currentUser,
      availableParents: parents,
      availableTeachers: teachers,
    );
  }
}