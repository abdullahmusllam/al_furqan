import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/models/halaga_model.dart'; // إضافة استيراد نموذج الحلقة
import 'package:al_furqan/views/shared/Conversation_list.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/users_controller.dart';
import '../../helper/sqldb.dart';
import '../../services/firebase_service.dart';
import '../../services/message_sevice.dart';
import '../../services/sync.dart';
import 'SchoolDirectorHome.dart';

class MainScreenD extends StatefulWidget {
  // final UserModel User;

  const MainScreenD({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenD> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<void> load() async {
    if (await isConnected()) {
      await sync.syncUsers();
      await sync.syncElhalagat();
      await sync.syncStudents();
      await loadStudents();
      await loadHalagat();
      await loadPlans();
      await loadMessages();
      await loadUsersFromFirebase();
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SchoolManagerScreen()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يوجد اتصال بالانترنت لتحديث البيانات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadUsersFromFirebase() async {
    await userController.addToLocalOfFirebase();
  }

  Future<void> loadStudents() async {
    final perfs = await SharedPreferences.getInstance();
    int? schoolId = perfs.getInt('schoolId');
    print('===== schoolID ($schoolId) =====');
    // تحميل الطلاب من فايربيس
    await studentController.addToLocalOfFirebase(schoolId!);
  }

  Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? Id = prefs.getString('user_id');
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

  Future<void> loadHalagat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? schoolId = prefs.getInt('schoolId');
      print('===== schoolID ($schoolId) =====');
      // تحميل الحلقات من فايربيس
      await halagaController.getHalagatFromFirebaseByID(schoolId!, 'schoolID');
    } catch (e) {
      print('خطأ في تحميل الحلقات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الحلقات'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadPlans() async {
    try {
      halagaController.halagatId.clear();

      final prefs = await SharedPreferences.getInstance();
      int? schoolId = prefs.getInt('schoolId');
      if (schoolId != null) {
        List<HalagaModel> halaqat = await halagaController.getData(schoolId);

        for (var halqa in halaqat) {
          if (halqa.halagaID != null) {
            halagaController.halagatId.add(halqa.halagaID!);
          }
        }
      }

      List<int> halagaIds = halagaController.halagatId;
      if (halagaIds.isEmpty) {
        print('===== قائمة معرفات الحلقات فارغة =====');
        return;
      }

      for (int halagaId in halagaIds) {
        await planController.getPlansFirebaseToLocal(halagaId);
      }
    } catch (e) {
      print('خطأ في تحميل الخطط: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الخطط'),
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
          title: Text('جاري التحميل...',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
