import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Supervisor/add_school.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
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
  bool _isActivate = false;
  bool _isPasswordVisible = false;
  String? _selectedRole;
  int? _selectedSchoolId = 0;
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
                value: school.schoolID,
                child: Text("${school.school_name!} ${school.school_location}"),
              ))
          .toList();
      _selectedSchoolId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مستخدم جديد'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _firstname,
                  label: 'الاسم الأول',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال الاسم الأول',
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _fathername,
                  label: 'اسم الأب',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال اسم الأب',
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _grandfathername,
                  label: 'اسم الجد',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال اسم الجد',
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _lastname,
                  label: 'القبيلة',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال القبيلة',
                ),
                SizedBox(height: 10),
                _buildNumberFormField(
                    controller: _phone,
                    label: 'رقم الجوال',
                    maxLength: 9,
                    inputType: TextInputType.phone,
                    validatorMsg: 'الرجاء إدخال رقم الجوال',
                    additionalValidator: (value) {
                      if (value!.length < 9) {
                        return 'رقم الجوال يجب أن يكون 9 أرقام';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'ادخل ارقاماً';
                      }
                      return null;
                    }),
                SizedBox(height: 10),
                _buildNumberFormField(
                  controller: _telephone,
                  label: 'رقم البيت',
                  maxLength: 6,
                  inputType: TextInputType.phone,
                  validatorMsg: 'الرجاء إدخال رقم البيت',
                  additionalValidator: (value) {
                    if (value!.length < 6) {
                      return 'رقم البيت يجب أن يكون 6 أرقام';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'ادخل ارقاماً';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _email,
                  label: 'البريد الإلكتروني',
                  maxLength: 50,
                  inputType: TextInputType.emailAddress,
                  validatorMsg: 'الرجاء إدخال بريد إلكتروني',
                  additionalValidator: (value) {
                    final emailRegex =
                        RegExp(r'^[a-zA-Z0-9@._\-]+@[gmail]+\.[com]');
                    if (!emailRegex.hasMatch(value!)) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                _buildPasswordFormField(),
                SizedBox(height: 10),
                _buildDateFormField(),
                SizedBox(height: 10),
                _buildSchoolDropdown(),
                SizedBox(height: 10),
                _buildRoleDropdown(),
                SizedBox(height: 10),
                _buildActivateSwitch(),
                SizedBox(height: 10),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    required TextInputType inputType,
    required String validatorMsg,
    String? Function(String?)? additionalValidator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[0-9_\-!#\$%^&*(),?":{}|<>]'))
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (additionalValidator != null) {
          return additionalValidator(value);
        }
        return null;
      },
    );
  }

  TextFormField _buildNumberFormField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    required TextInputType inputType,
    required String validatorMsg,
    String? Function(String?)? additionalValidator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
            RegExp(r'[ا-يa-zA-Z@._\-!#\$%^&*(),?":{}|<>]'))
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (additionalValidator != null) {
          return additionalValidator(value);
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordFormField() {
    return TextFormField(
      controller: _password,
      obscureText: !_isPasswordVisible,
      maxLength: 8,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
        return null;
      },
    );
  }

  TextFormField _buildDateFormField() {
    return TextFormField(
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
          String formattedDate = DateFormat.yMMMd().format(pickedDate);
          setState(() {
            _date.text = formattedDate;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال تاريخ الميلاد';
        }
        return null;
      },
    );
  }

  Row _buildSchoolDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
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
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddSchool()));
            await _loadSchools();
          },
        ),
      ],
    );
  }

  DropdownButtonFormField<String> _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'اختر الدور',
        border: OutlineInputBorder(),
      ),
      items: <String>['مشرف', 'مدير', 'معلم'].map((String value) {
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
        return null;
      },
    );
  }

  SwitchListTile _buildActivateSwitch() {
    return SwitchListTile(
      title: Text('تفعيل المستخدم'),
      value: _isActivate,
      onChanged: (bool value) {
        setState(() {
          _isActivate = value;
        });
      },
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _submitForm();
        }
      },
      child: Text('إضافة المستخدم'),
    );
  }

  void _submitForm() {
    int phone = int.parse(_phone.text);
    int telephone = int.parse(_telephone.text);
    int password = int.parse(_password.text);
    int? roleID;
    int activate = _isActivate ? 1 : 0;

    _userModel.first_name = _firstname.text;
    _userModel.middle_name = _fathername.text;
    _userModel.grandfather_name = _grandfathername.text;
    _userModel.last_name = _lastname.text;
    _userModel.phone_number = phone;
    _userModel.telephone_number = telephone;
    _userModel.email = _email.text;
    _userModel.password = password;
    _userModel.date = _date.text;
    _userModel.isActivate = activate;
    _userModel.schoolID = _selectedSchoolId;

    switch (_selectedRole) {
      case "مشرف":
        roleID = 0;
        break;
      case "مدير":
        roleID = 1;
        break;
      case "معلم":
        roleID = 2;
        break;
    }
    _userModel.roleID = roleID;
    userController.addUser(_userModel);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تمت إضافة مستخدم بنجاح"),
      ),
    );
    setState(() {});
    Navigator.of(context).pop();
  }
}
