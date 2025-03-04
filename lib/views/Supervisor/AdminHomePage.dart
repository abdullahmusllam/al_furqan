// ignore: file_names
import 'package:al_furqan/widgets/drawer_list.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // مكتبة المخططات
import 'package:al_furqan/widgets/stat_card.dart';
import 'package:al_furqan/widgets/meeting_list.dart';
import 'package:al_furqan/widgets/chart_card.dart';
import 'package:al_furqan/widgets/notification_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لوحة تحكم المشرف')),
      drawer: DrawerList(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الكروت الأربعة الرئيسية
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        title: 'عدد المدارس', value: '12', color: Colors.blue)),
                SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        title: 'عدد المعلمين',
                        value: '250',
                        color: Colors.green)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        title: 'عدد الطلاب',
                        value: '5000',
                        color: Colors.orange)),
                SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        title: 'عدد الإنجازات',
                        value: '20',
                        color: Colors.red)),
              ],
            ),
            SizedBox(height: 20),
            // قائمة الاجتماعات
            Text('الاجتماعات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            MeetingList(),
            SizedBox(height: 20),
            // مخطط نسبة تنفيذ الأنشطة
            ChartCard(
                title: 'نسبة تنفيذ الأنشطة',
                color: Colors.blue,
                percentage: 70),
            SizedBox(height: 20),
            // مخطط نسبة الانضباط
            ChartCard(
                title: 'نسبة الانضباط', color: Colors.green, percentage: 85),
            SizedBox(height: 20),
            // كارد الإشعارات
            NotificationCard(),
          ],
        ),
      ),
    );
  }
}
