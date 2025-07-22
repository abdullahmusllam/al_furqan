import 'dart:developer';

import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/provider/message_provider.dart';
import 'package:al_furqan/models/provider/student_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/models/halaga_model.dart'; // إضافة استيراد نموذج الحلقة
import 'package:al_furqan/views/shared/Conversation_list.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/users_controller.dart';
import '../../services/message_sevice.dart';
import '../../services/sync.dart';
import 'SchoolDirectorHome.dart';

class MainScreenD extends StatefulWidget {
  // final UserModel User;

  const MainScreenD({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenD> {
  bool isLoading = true;
  int? timeLoadTotal,
      timeSyncUser,
      timeSyncElhalagat,
      timeSyncStudents,
      timeLoadStudents,
      timeLoadElhalagat,
      timeLoadPlans,
      timeLoadMessages,
      timeLoadUsersFromFirebase;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<void> load() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => SchoolManagerScreen()));
    if (await isConnected()) {
      final swTotal = Stopwatch()..start();

      final sw1 = Stopwatch()..start();
      await sync.syncUsers();
      sw1.stop();
      timeSyncUser = sw1.elapsedMilliseconds;
      log("Time Sync User is : $timeSyncUser ms");

      final sw2 = Stopwatch()..start();
      await sync.syncElhalagat();
      sw2.stop();
      timeSyncElhalagat = sw2.elapsedMilliseconds;
      log("Time Sync Elhalagat is : $timeSyncElhalagat ms");

      final sw3 = Stopwatch()..start();
      await sync.syncStudents();
      sw3.stop();
      timeSyncStudents = sw3.elapsedMilliseconds;
      log("Time Sync Students is : $timeSyncStudents ms");

      final sw4 = Stopwatch()..start();
      await Provider.of<StudentProvider>(context, listen: false).loadStudents();
      sw4.stop();
      timeLoadStudents = sw4.elapsedMilliseconds;
      log("Time Load Students is : $timeLoadStudents ms");

      final sw5 = Stopwatch()..start();
      await loadHalagat();

      sw4.stop();
      timeLoadElhalagat = sw5.elapsedMilliseconds;
      log("Time Load Elhalagat is : $timeLoadElhalagat ms");

      final sw6 = Stopwatch()..start();
      await loadPlans();
      sw6.stop();
      timeLoadPlans = sw6.elapsedMilliseconds;
      log("Time Load Plans is : $timeLoadPlans ms");

      final sw7 = Stopwatch()..start();
      await Provider.of<MessageProvider>(context, listen: false).loadMessages();
      sw7.stop();
      timeLoadMessages = sw7.elapsedMilliseconds;
      log("Time Load Messages is : $timeLoadMessages ms");

      final sw8 = Stopwatch()..start();
      await loadUsersFromFirebase();
      sw8.stop();
      timeLoadUsersFromFirebase = sw8.elapsedMilliseconds;
      log("Time Load Users From Firebase is : $timeLoadUsersFromFirebase ms");

      swTotal.stop();
      timeLoadTotal = swTotal.elapsedMilliseconds;
      log("-----> Time Total For Load Data : $timeLoadTotal ms");
    } else {
      if (!mounted) return;
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
    int? schoolId = perf.getInt('schoolId');
    debugPrint('===== schoolID ($schoolId) =====');
    // تحميل الطلاب من فايربيس
    await studentController.addToLocalOfFirebase(schoolId!);
  }

  Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('user_id');
      debugPrint('===== ($id) =====');
      // تحميل الرسائل من فايربيس
      await messageService.loadMessagesFromFirestore(id!);
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      if (!mounted) return;
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
      debugPrint('===== schoolID ($schoolId) =====');
      // تحميل الحلقات من فايربيس
      await halagaController.getHalagatFromFirebaseByID(schoolId!, 'schoolID');
    } catch (e) {
      debugPrint('خطأ في تحميل الحلقات: $e');
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

      List<String> halagaIds = halagaController.halagatId;
      if (halagaIds.isEmpty) {
        debugPrint('===== قائمة معرفات الحلقات فارغة =====');
        return;
      }

      for (var halagaId in halagaIds) {
        await planController.getPlansFirebaseToLocal(halagaId);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الخطط: $e');
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
