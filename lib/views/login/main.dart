import 'package:flutter/material.dart';
// import 'package:lloginn/login.dart';
// import 'package:lloginn/register.dart';
// import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // البداية مع صفحة تسجيل الدخول
      // routes: {
      //   '/': (context) => LoginScreen(),
      //   '/register': (context) => RegisterScreen(),
      // },
    );
  }
}
