import 'package:al_furqan/firebase_options.dart';
import 'package:al_furqan/views/SchoolDirector/SchoolDirectorHome.dart';
import 'package:al_furqan/views/SchoolDirector/TeachersAttendance.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';
import 'package:al_furqan/views/home_screen.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:al_furqan/widgets/custom_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Teacher/AddIslamicStudiesPlanPage.dart';
import 'package:al_furqan/views/Teacher/studentListPage.dart';
import 'package:al_furqan/views/Teacher/StudentDetilesPage.dart';
import 'package:al_furqan/views/Teacher/mainTeacher.dart';
import 'package:al_furqan/views/Teacher/addStusentData.dart';
import 'package:al_furqan/views/Teacher/privateActivity.dart';
import 'package:al_furqan/views/Teacher/activitiesOfficer.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 117, 70)),
        useMaterial3: true,
        fontFamily: 'RB',
      ),
      locale: Locale('ar'), // تحديد اللغة الافتراضية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // جعل التطبيق بالكامل RTL
          child: child!,
        );
      },
      home: LoginScreen(),
    );
  }
}
