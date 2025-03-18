import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/login/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import '../SchoolDirector/SchoolDirectorHome.dart';
import '../Teacher/mainTeacher.dart';
import 'signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

int id = 0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// حفظ بيانات تسجيل الدخول في SharedPreferences
  Future<void> saveUserLogin(
      String phoneUser, int roleId, int isActivate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneUser', phoneUser);
    await prefs.setInt('roleID', roleId);
    await prefs.setInt('isActivate', isActivate);
    await prefs.setBool('isLoggedIn', true);
  }

  /// تسجيل خروج المستخدم وحذف جميع البيانات المحفوظة
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // حذف جميع البيانات المحفوظة
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  /// التحقق مما إذا كان المستخدم مسجل الدخول
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// الحصول على رقم الهاتف المحفوظ في SharedPreferences
  Future<String?> getUserphone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneUser');
  }

  /// الحصول على رقم الدور المحفوظ في SharedPreferences
  Future<int?> getUserRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('roleID');
  }

  /// الحصول على رقم التفعيل المحفوظ في SharedPreferences
  Future<int?> getIsActivate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('isActivate');
  }

  /// التحقق من حالة تسجيل الدخول واستدعاء _loginPref إذا كان المستخدم مسجل الدخول
  void _checkLoginStatus() async {
    print(
        "----------------------Here check Login Status--------------------------");
    bool isLogin = await isUserLoggedIn();
    if (isLogin) {
      print(
          "----------------------Here if check Login Status--------------------------");
      _loginPref();
    }
  }

  /// تسجيل الدخول باستخدام البيانات المحفوظة في SharedPreferences
  void _loginPref() async {
    setState(() => _isLoading = true);
    try {
      int? roleId = await getUserRoleId();
      int? isActivate = await getIsActivate();
      setState(() => _isLoading = false);
      if (roleId != null && isActivate != null && isActivate == 1) {
        await chooseScreen(context);
      } else {
        _showErrorDialog(context, "خطأ", "حسابك غير مفعل أو بيانات غير صحيحة.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(context, "خطأ", "حدث خطأ: $e");
    }
  }

  /// تسجيل الدخول باستخدام رقم الهاتف وكلمة المرور
  void _login(BuildContext context) async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    setState(() => _isLoading = true);

    /// التحقق من أن الحقول غير فارغة
    if (phone.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "خطأ", "الرجاء إدخال رقم الجوال وكلمة المرور.");
      return;
    }

    /// التحقق من صحة بيانات تسجيل الدخول
    final user = await SqlDb().getUser(phone, password);
    setState(() => _isLoading = false);

    /// التحقق من أن المستخدم موجود
    if (user == null || user.user_id == null) {
      _showErrorDialog(context, "خطأ", "بيانات تسجيل الدخول غير صحيحة.");
      return;
    }

    /// التحقق من أن الحساب مفعل
    await chiceRole(user, context, phone);
  }

  /// اختيار الدور المناسب للمستخدم وتوجيهه إلى الشاشة المناسبة
  Future<void> chiceRole(
      UserModel user, BuildContext context, String phone) async {
    if (user.roleID == null || user.isActivate == 0) {
      _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
      return;
    }
    id = user.user_id!;
    await saveUserLogin(phone, user.roleID!, user.isActivate!);
    await chooseScreen(context);
  }

  /// اختيار الشاشة المناسبة للمستخدم بناءً على دوره
  Future<void> chooseScreen(BuildContext context) async {
    int? roleId = await getUserRoleId();
    if (roleId == null) {
      _showErrorDialog(context, "خطأ", "فشل في تحديد دور المستخدم.");
      return;
    }
    switch (roleId) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SchoolManagerScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TeacherDashboard()));
        break;
      default:
        _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
    }
  }

  /// عرض رسالة خطأ في حوار
  void _showErrorDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text("موافق"),
            onPressed: () => Navigator.pop(context),
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
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

  /// بناء حقل نصي مع أيقونة
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
