// ignore: file_names
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:al_furqan/widgets/drawer_list.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // مكتبة المخططات
import 'package:al_furqan/widgets/stat_card.dart';
import 'package:al_furqan/widgets/meeting_list.dart';
import 'package:al_furqan/widgets/chart_card.dart';
import 'package:al_furqan/widgets/notification_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with UserDataMixin {
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
                  MaterialPageRoute(builder: (context) => LoginScreen()));
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
                    title: 'عدد المدارس', value: '12', color: Colors.blue)),
            SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    title: 'عدد المعلمين', value: '250', color: Colors.green)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: StatCard(
                    title: 'عدد الطلاب', value: '5000', color: Colors.orange)),
            SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    title: 'عدد الإنجازات', value: '20', color: Colors.red)),
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
