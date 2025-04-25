import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/login/forgot_password.dart';
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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    loadUsersFromFirebase();
  }

  loadUsersFromFirebase() async {
    List<UserModel> users = await firebasehelper.getUsers();
      for(var user in users){
        bool exists = await  sqlDb.checkIfitemExists("Users", user.user_id!, "user_id");
        if(exists){
          await userController.updateUser(user, 1);
        }else{
          await userController.addUser(user, 0);
        }
      }
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
    print("-------------: $isLogin");
    if (isLogin) {
      print(
          "----------------------Here if check Login Status--------------------------");
      _loginPref();
      // logoutUser();
    }
  }

  /// تسجيل الدخول باستخدام البيانات المحفوظة في SharedPreferences
  void _loginPref() async {
    setState(() => _isLoading = true);
    try {
      int? roleId = await getUserRoleId();
      int? isActivate = await getIsActivate();
      setState(() => _isLoading = false);
      if (roleId != null) {
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
    resizeToAvoidBottomInset: true,
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade100, Colors.white],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.green))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 1),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/pictures/al_furqan_icon.png',
                              height: 180,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "مرحباً بك",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "سجل الدخول للوصول إلى حسابك",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildTextField(
                          phoneController,
                          Icons.phone_android,
                          "رقم الهاتف",
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.lock_rounded, color: Colors.green),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            hintText: "كلمة المرور",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: Colors.green.shade200, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            shadowColor: Colors.green.withOpacity(0.5),
                          ),
                          child: Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ليس لديك حساب؟",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                minimumSize: Size(50, 30),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "إنشاء حساب",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ),
  );
}


  /// بناء حقل نصي مع أيقونة
  Widget _buildTextField(
      TextEditingController controller, IconData icon, String hint,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.green.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
