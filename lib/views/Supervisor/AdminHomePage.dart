import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/sync.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:al_furqan/widgets/chart_card.dart';
import 'package:al_furqan/widgets/drawer_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/meeting_list.dart';
import '../../widgets/notification_card.dart';
import '../Teacher/activitiesOfficer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with UserDataMixin {
  final _schools = schoolController.schools;
  final _teachers = teacherController.teachers;
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    syncData();
    _refreshData();
  }

  Future<void> syncData() async {
    await sync.syncUsers;
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFFFFFFF), // الأبيض
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), // الأزرق
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'الرجاء الانتظار حتى رفع البيانات',
                    style: TextStyle(color: Color(0xFF212121)), // أسود
                  ),
                ),
              ],
            ),
          );
        }).then((value) {
      Navigator.pop(context);
    });
  }

  Future<void> _refreshData() async {
    try {
      await schoolController.getData();
      await teacherController.getTeachers();
      _totalStudents = await studentController.getTotalStudents();
      setState(() {});
      print(
          "Refreshed admin data: ${_schools.length} schools, ${_teachers.length} teachers, $_totalStudents students");
    } catch (e) {
      print("Error refreshing admin data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب البيانات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم المشرف'),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: user == null ? null : DrawerList(user: user),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text("فشل في جلب بيانات المستخدم"))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCards(),
                      SizedBox(height: 20),
                      _buildSectionTitle('الاجتماعات'),
                      MeetingList(),
                      SizedBox(height: 20),
                      _buildChartCard('نسبة تنفيذ الأنشطة', Colors.blue, 70),
                      SizedBox(height: 20),
                      _buildChartCard('نسبة الانضباط', Colors.green, 85),
                      SizedBox(height: 20),
                      NotificationCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: StatCard(
              title: 'عدد المدارس',
              value: '${_schools.length}',
            )),
            SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    title: 'عدد المعلمين',
                    value: '${_teachers.length}',
                    )),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: StatCard(
                    title: 'عدد الطلاب',
                    value: '$_totalStudents',
                    )),
            SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    title: 'عدد الإنجازات', value: '20')),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildChartCard(String title, Color color, double percentage) {
    return ChartCard(
      title: title,
      color: color,
      percentage: percentage,
    );
  }
}
