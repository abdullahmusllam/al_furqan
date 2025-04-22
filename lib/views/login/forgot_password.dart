// views/forgot_password_screen.dart
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = userController;
  final _phoneNumberController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSendCode() async {
    setState(() => _isLoading = true);
    try {
      await _controller.sendVerificationCode(int.parse(_phoneNumberController.text.trim()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال رمز التحقق إلى واتساب')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    setState(() => _isLoading = true);
    try {
      _controller.verificationCode = _verificationCodeController.text.trim();
      _controller.newPassword = _newPasswordController.text.trim();
      
      await _controller.resetPassword();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث كلمة المرور بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('استعادة كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_controller.codeSent) ...[
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSendCode,
                child: _isLoading 
                    ? CircularProgressIndicator()
                    : Text('إرسال رمز التحقق عبر واتساب'),
              ),
            ],
            if (_controller.codeSent) ...[
              Text('تم إرسال رمز التحقق إلى الرقم المسجل'),
              SizedBox(height: 20),
              TextField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  labelText: 'رمز التحقق',
                  prefixIcon: Icon(Icons.code),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading 
                    ? CircularProgressIndicator()
                    : Text('تغيير كلمة المرور'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}