import 'package:father/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'auth/login.dart';
import 'student_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // عرض الشاشة لمدة ثانيتين ثم التحقق من حالة تسجيل الدخول
    Future.delayed(Duration(seconds: 2), () {
      _checkLoginStatus();
    });
  }



  // التحقق من حالة تسجيل الدخول في SharedPreferences
  Future<void> _checkLoginStatus() async {
    try {
      // الحصول على مثيل من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // التحقق مما إذا كان المستخدم مسجل الدخول
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userId = prefs.getInt('user_id');
      
      print('===== isLoggedIn: $isLoggedIn =====');
      print('===== userId: $userId =====');
      
      if (!mounted) return; // Check if widget is still mounted
      
      if (isLoggedIn && userId != null) {
        // إذا كان المستخدم مسجل الدخول وتم العثور على معرف المستخدم
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // إذا لم يكن المستخدم مسجل الدخول أو لم يتم العثور على معرف المستخدم
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print('خطأ في التحقق من حالة تسجيل الدخول: $e');
      
      if (!mounted) return; // Check if widget is still mounted
      
      // في حالة حدوث خطأ، الانتقال إلى شاشة تسجيل الدخول
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }
  




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F0), Colors.white], // Light version of #017546
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/pictures/al_furqan_icon.png',
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Color(0xFF017546)),
              SizedBox(height: 20),
              Text(
                "جاري التحميل...",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF017546),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}