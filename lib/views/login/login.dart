import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';
import 'package:al_furqan/views/login/profile.dart';
import 'package:flutter/material.dart';
// import 'package:lloginn/profile.dart';
import '../../models/users_model.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  void _login(BuildContext context) async {
    String phone = phoneController.text;
    String password = passwordController.text;

    if (phone.isNotEmpty && password.isNotEmpty) {
      await userController.get_data_users();
      var user = userController.users.firstWhere(
          (user) =>
              user.phone_number == int.parse(phone) &&
              user.password == int.parse(password),
          orElse: () => UserModel());

      if (user.user_id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        _showErrorDialog(context, "خطأ", "يرجى إنشاء حساب اولاً.");
      }
    } else {
      _showErrorDialog(context, "خطأ", "الرجاء إدخال رقم الجوال وكلمة المرور.");
    }
  }

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignupScreen(),
                ),
              );
            },
            child: Text("إنشاء حساب"),
          ),
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
        child: Column(
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
            _buildTextField(passwordController, Icons.lock, "كلمة المرور",
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
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
