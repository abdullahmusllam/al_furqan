import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';
import '../../service/fierbase_service.dart';
import '../student_list_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';


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
  }

  /// حفظ بيانات تسجيل الدخول في SharedPreferences
  Future<void> saveUserLogin(
      String phoneUser, int roleId, int isActivate, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneUser', phoneUser);
    await prefs.setInt('roleID', roleId);
    await prefs.setInt('isActivate', isActivate);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('user_id', userId);
  }

  /// تسجيل الدخول باستخدام رقم الهاتف وكلمة المرور
  void _login(BuildContext context) async {
    // التحقق من صحة المدخلات
    String phoneStr = phoneController.text.trim();
    String password = passwordController.text.trim();
    
    // التحقق من أن رقم الهاتف صالح
    if (phoneStr.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(phoneStr)) {
      _showErrorDialog(context, "خطأ", "الرجاء إدخال رقم هاتف صالح");
      return;
    }
    
    // تحويل رقم الهاتف إلى رقم صحيح
    int phone = int.parse(phoneStr);
    
    if (mounted) {
      setState(() => _isLoading = true);
    }

    /// التحقق من أن الحقول غير فارغة
    if (password.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorDialog(context, "خطأ", "الرجاء إدخال كلمة المرور.");
      return;
    }
    
    // التحقق من اتصال الإنترنت
    bool hasConnection = await InternetConnectionChecker.createInstance().hasConnection;
    if (!hasConnection) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorDialog(context, "خطأ", "لا يوجد اتصال بالإنترنت");
      return;
    }

    try {
      // التحقق من بيانات المستخدم باستخدام FirestoreService
      // استخدام طريقة authenticate التي أضفناها للتحقق من صحة بيانات المستخدم
      UserModel? user = await firestoreService.authenticate(phone, password);

      // التحقق من وجود المستخدم
      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        _showErrorDialog(context, "خطأ", "بيانات تسجيل الدخول غير صحيحة");
        return;
      }
      
      // التحقق من أن الحساب مفعل
      if (user.isActivate == 0) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة");
        return;
      }

      // ملاحظة: لا حاجة للتحقق من كلمة المرور هنا لأنه تم التحقق منها بالفعل في FirestoreService

      // المستخدم موجود بالفعل وكلمة المرور صحيحة
      // حفظ بيانات المستخدم في الذاكرة المؤقتة
      await saveUserLogin(phoneStr, user.roleID!, user.isActivate!, user.user_id!); 
      
      final prefs = await SharedPreferences.getInstance();
      // حفظ معرف المدرسة إذا كان موجوداً
      if (user.schoolID != null) {
        await prefs.setInt('schoolId', user.schoolID!);
      }
      
      // حفظ معرف الحلقة إذا كان موجوداً
      if (user.elhalagatID != null) {
        await prefs.setInt('elhalagatID', user.elhalagatID!);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }

      // التوجيه إلى شاشة قائمة الطلاب
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentListScreen()),
      );

    } catch (e) {
      print("خطأ في تسجيل الدخول: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorDialog(context, "خطأ", "حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى");
    }
  }

  // الطرق السابقة تم استبدالها بطريقة مباشرة للتعامل مع Firebase
  // حيث أن التطبيق مخصص لأولياء الأمور فقط (دور 3)

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
            colors: [Color(0xFFE8F5F0), Colors.white], // Light version of #017546
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                              color: Color(0xFF017546),
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
                            Icon(Icons.lock_rounded, color: Color(0xFF017546)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Color(0xFF017546),
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
                          borderSide:
                              BorderSide(color: Color(0xFFE8F5F0), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Color(0xFF017546), width: 2),
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
                      onPressed: _isLoading ? null : () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF017546),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: Color(0xFF017546).withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
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
                            foregroundColor: Color(0xFF017546),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            minimumSize: Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        prefixIcon: Icon(icon, color: Color(0xFF017546)),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFFE8F5F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF017546), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}