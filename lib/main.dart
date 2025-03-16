import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/material.dart';

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
      home: UserManagementPage(),
    );
  }
}
