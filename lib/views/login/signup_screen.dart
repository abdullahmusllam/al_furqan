import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/users_model.dart';
import '../Supervisor/add_school.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  UserModel _userModel = UserModel();
  final _formKey = GlobalKey<FormState>();
  final _firstname = TextEditingController();
  final _fathername = TextEditingController();
  final _grandfathername = TextEditingController();
  final _lastname = TextEditingController();
  final _phone = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _date = TextEditingController();
  bool _isPasswordVisible = false;
  String? _selectedRole;
  int? _selectedSchoolId;
  List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    await schoolController.get_data();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.school_id,
                child: Text(school.school_name!),
              ))
          .toList();
      if (_schoolItems.isNotEmpty &&
          !_schoolItems.any((item) => item.value == _selectedSchoolId)) {
        _selectedSchoolId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب جديد'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _firstname,
                  keyboardType: TextInputType.name,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'الاسم الأول',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الأول';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _fathername,
                  keyboardType: TextInputType.name,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'اسم الأب',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الأب';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _grandfathername,
                  keyboardType: TextInputType.name,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'اسم الجد',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الجد';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _lastname,
                  keyboardType: TextInputType.name,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'القبيلة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال القبيلة';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الجوال';
                    }
                    if (value.length < 9) {
                      return 'رقم الجوال يجب أن يكون 9 أرقام';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _telephone,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  decoration: InputDecoration(
                    labelText: 'رقم البيت',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم البيت';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    } else if (!value.contains('@')) {
                      return 'البريد الإلكتروني يجب أن يحتوي على @';
                    } else if (!value.contains('.')) {
                      return 'البريد الإلكتروني يجب أن يحتوي على .';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _password,
                  obscureText: !_isPasswordVisible,
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    } else if (value.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أرقام أو أكثر';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'تاريخ الميلاد',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1700),
                      lastDate: DateTime(2300),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat.yMMMd().format(pickedDate);
                      setState(() {
                        _date.text = formattedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال تاريخ الميلاد';
                    }
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedSchoolId,
                  decoration: InputDecoration(
                    labelText: 'اختر المدرسة',
                    border: OutlineInputBorder(),
                  ),
                  items: _schoolItems,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSchoolId = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'اختر الدور',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['مدير', 'معلم'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'الرجاء اختيار الدور';
                    }
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission
                        int phone = int.parse(_phone.text);
                        int telephone = int.parse(_telephone.text);
                        int password = int.parse(_password.text);

                        _userModel.first_name = _firstname.text;
                        _userModel.middle_name = _fathername.text;
                        _userModel.grandfather_name = _grandfathername.text;
                        _userModel.last_name = _lastname.text;
                        _userModel.phone_number = phone;
                        _userModel.telephone_number = telephone;
                        _userModel.email = _email.text;
                        _userModel.password = password;
                        _userModel.date = _date.text; // تعيين تاريخ الميلاد
                        _userModel.school_id = _selectedSchoolId;
                        _userModel.role_id = _selectedRole == "مدير" ? 1 : 2;

                        userController.add_request(_userModel);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("تم إرسال طلب التسجيل بنجاح"),
                          ),
                        );
                        setState(() {});
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('إرسال الطلب'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
