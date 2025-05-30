import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Teacher/mainTeacher.dart';
import 'package:al_furqan/views/shared/Conversation_list.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/users_controller.dart';
import '../../helper/sqldb.dart';
import '../../services/firebase_service.dart';
import '../../services/message_sevice.dart';
import '../../services/sync.dart';
  
class MainScreenT extends StatefulWidget {

  const MainScreenT({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenT> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    // Clean up any controllers, streams, or other resources here
    super.dispose();
  }

  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<void> load() async {
    if(await isConnected()){
    await sync.syncUsers();
    await sync.syncElhalagat();
    await sync.syncStudents();
    await loadMessages();
    await loadHalagat();
    await loadPlans();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يوجد اتصال بالانترنت لتحديث البيانات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? Id = prefs.getInt('user_id');
      print('===== ($Id) =====');
      // تحميل الرسائل من فايربيس
      await messageService.loadMessagesFromFirestore(Id!);
    } catch (e) {
      print('خطأ في تحميل الرسائل: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الرسائل'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });

  }

  Future<void> loadHalagat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? Id = prefs.getInt('halagaID');
      print('===== halagaID ($Id) =====');
      // تحميل الحلقات من فايربيس
      await halagaController.getHalagatFromFirebaseByID(Id!, 'halagaID');
    } catch (e) {
      print('خطأ في تحميل الحلقات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الحلقات'),
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

    return TeacherDashboard();
  }
}