import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:al_furqan/views/login/login_auth.dart';
import 'package:al_furqan/views/splashScreen.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
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
      home: SplashScreen(),
    );
  }
}
