import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/users_model.dart';
import '../SchoolDirector/SchoolDirectorHome.dart';
import '../Teacher/mainTeacher.dart';
import 'signup_screen.dart';

int id = 0;

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  void toDashboardAdmin(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
  }

  void toDashboardManeger(BuildContext context, UserModel user) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SchoolManagerScreen(user: user)));
  }

  void toDashboardTeacher(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => TeacherDashboard()));
  }

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

      if (user.role_id != null) {
        // احفظ رقم الهاتف في المتغير بعد التحقق الناجح
        id = user.user_id!;

        switch (user.role_id) {
          case 0:
            toDashboardAdmin(context);
            break;
          case 1:
            toDashboardManeger(context, user);
            break;
          case 2:
            toDashboardTeacher(
              context,
            );
            break;
          default:
            _showErrorDialog(
                context, "خطأ", "حسابك غير موجود أو غير مفعل تواصل مع مديرك");
            break;
        }
      } else {
        _showErrorDialog(
            context, "خطأ", "حسابك غير موجود أو غير مفعل تواصل مع مديرك");
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
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}' // Emoticons
      r'\u{1F300}-\u{1F5FF}' // Misc Symbols and Pictographs
      r'\u{1F680}-\u{1F6FF}' // Transport and Map Symbols
      r'\u{1F700}-\u{1F77F}' // Alchemical Symbols
      r'\u{1F780}-\u{1F7FF}' // Geometric Shapes Extended
      r'\u{1F800}-\u{1F8FF}' // Supplemental Arrows-C
      r'\u{1F900}-\u{1F9FF}' // Supplemental Symbols and Pictographs
      r'\u{1FA00}-\u{1FA6F}' // Chess Symbols
      r'\u{1FA70}-\u{1FAFF}' // Symbols and Pictographs Extended-A
      r'\u{2600}-\u{26FF}' // Miscellaneous Symbols
      r'\u{2700}-\u{27BF}' // Dingbats
      r'\u{2300}-\u{23FF}' // Miscellaneous Technical
      r'\u{2B50}-\u{2B55}' // Stars and Miscellaneous
      r'\u{1F1E6}-\u{1F1FF}' // Flags (regional indicator symbols)
      r'\u{1F201}-\u{1F251}' // Enclosed Ideographic Supplement
      r'\u{1F004}' // Mahjong Tile Red Dragon
      r'\u{1F0CF}' // Playing Card Black Joker
      r'\u{1F9C0}' // Cheese Wedge
      r'\u{1F018}-\u{1F270}' // Enclosed CJK Letters and Months
      r'\u{1F202}-\u{1F2FF}]', // More Enclosed Ideographic Supplement
      unicode: true,
    );
    return TextField(
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(emojiRegex)],
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
