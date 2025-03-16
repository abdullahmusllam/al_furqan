import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/users_model.dart';
import '../SchoolDirector/SchoolDirectorHome.dart';
import '../Teacher/mainTeacher.dart';
import 'signup_screen.dart';
import 'database_helper.dart'; // استيراد ملف قاعدة البيانات

int id = 0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper(); // استدعاء DatabaseHelper

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // حفظ بيانات تسجيل الدخول
  Future<void> saveUserLogin(String phoneUser, int roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneUser', phoneUser);
    await prefs.setInt('role_id', roleId);
    await prefs.setBool('isLoggedIn', true);
  }

  // التحقق من حالة تسجيل الدخول
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String? phone = prefs.getString('phoneUser');
      if (phone != null) {
        _loginWithSavedData(phone);
      }
    }
  }

  // تسجيل الدخول باستخدام البيانات المحفوظة
  Future<void> _loginWithSavedData(String phone) async {
    final user = await _dbHelper.getUserByPhone(phone);
    if (user != null) {
      chiceRole(user, context, phone);
    }
  }

  // تسجيل الدخول باستخدام SQLite عبر DatabaseHelper
  Future<void> _login(BuildContext context) async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "خطأ", "الرجاء إدخال رقم الجوال وكلمة المرور.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _dbHelper.getUser(phone, password);
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        chiceRole(user, context, phone);
      } else {
        _showErrorDialog(context, "خطأ", "بيانات تسجيل الدخول غير صحيحة.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(context, "خطأ", "حدث خطأ أثناء تسجيل الدخول: $e");
    }
  }

  // اختيار الدور وتوجيه المستخدم
  void chiceRole(UserModel user, BuildContext context, String phone) {
    if (user.role_id == null) {
      _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
      return;
    }

    id = user.user_id!;
    saveUserLogin(phone, user.role_id!);

    switch (user.role_id) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SchoolManagerScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherDashboard()));
        break;
      default:
        _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
    }
  }

  // عرض رسالة خطأ
  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("موافق"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        "مرحباً",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "سجل الدخول باستخدام رقمك ",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                _buildTextField(
                    phoneController, Icons.phone_enabled_rounded, "رقمك"),
                SizedBox(height: 15),
                _buildTextField(
                    passwordController, Icons.lock, "كلمة المرور",
                    obscureText: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text("سجل الدخول",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "ليس لديك حساب؟ إنشاء حساب",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, IconData icon, String hint,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}