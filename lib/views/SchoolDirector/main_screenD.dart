import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/shared/Conversation_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/users_controller.dart';
import '../../helper/sqldb.dart';
import '../../services/firebase_service.dart';
import '../../services/message_sevice.dart';
import '../../services/sync.dart';
import 'SchoolDirectorHome.dart';

class MainScreenD extends StatefulWidget {
  final UserModel User;

  const MainScreenD({Key? key, required this.User}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenD> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    sync.syncUsers();
    sync.syncElhalagat();
    sync.syncStudents();
    loadDate();
    loadUsersFromFirebase();
    halagaController.getHalagatFromFirebase();
    loadPlans();

    load();
  }

  Future<void> load() async {
    await sync.syncUsers();
    await sync.syncElhalagat();
    await sync.syncStudents();
    await loadDate();
    await loadUsersFromFirebase();
    await halagaController.getHalagatFromFirebase();
  }
  Future<void> loadUsersFromFirebase() async {
    List<UserModel> users = await firebasehelper.getUsers();
    for (var user in users) {
      bool exists =
      await sqlDb.checkIfitemExists("Users", user.user_id!, "user_id");
      if (exists) {
        await userController.updateUser(user, 0);
        print('===== Find user (update) =====');
      } else {
        await userController.addUser(user, 0);
        print('===== Find user (add) =====');
      }
    }
  }
  Future<void> loadDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? Id = prefs.getInt('user_id');
      print('===== ($Id) =====');
      // تحميل الرسائل من فايربيس
      await messageService.loadMessagesFromFirestore(Id!);
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل البيانات'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });

  }
  Future<void> loadPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? Id = prefs.getInt('halagaID');
      print('===== halagaID ($Id) =====');
      // تحميل الرسائل من فايربيس
      await planController.getPlansFirebaseToLocal(Id!);
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل البيانات'),
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

    return SchoolManagerScreen();
  }
}