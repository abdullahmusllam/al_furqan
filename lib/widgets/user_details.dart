import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/school_controller.dart';
import '../views/Supervisor/add_school.dart';
import 'build_text_field.dart';
import 'build_password_field.dart';
import 'build_date_field.dart';
import 'build_dropdown_field.dart';
import 'build_switch_list_tile.dart';
import 'build_edit_button.dart';
import 'build_save_button.dart';

class UserDetails extends StatefulWidget {
  final UserModel user;

  UserDetails({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditable = false;

  late TextEditingController _firstname;
  late TextEditingController _fathername;
  late TextEditingController _grandfathername;
  late TextEditingController _lastname;
  late TextEditingController _phone;
  late TextEditingController _telephone;
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _date;
  bool _isPasswordVisible = false;
  String? _selectedRole;
  int? _selectedSchoolId; // تعيين القيمة الافتراضية إلى صفر
  List<DropdownMenuItem<int>> _schoolItems = [];

  bool _isActivate = false;

  Future<void> _loadSchools() async {
    await schoolController.get_data();
    widget.user.school_id;
    schoolController.schools.forEach((element) {
      print("School ID : ${element.school_id}");
    });

    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.school_id,
                child:
                    Text("${school.school_name!}\n${school.school_location}"),
              ))
          .toList();
      // _selectedSchoolId =
      //     widget.user.school_id; // تعيين القيمة الافتراضية إلى null
    });
  }

  @override
  void initState() {
    super.initState();
    _firstname = TextEditingController(text: widget.user.first_name);
    _fathername = TextEditingController(text: widget.user.middle_name);
    _grandfathername =
        TextEditingController(text: widget.user.grandfather_name);
    _lastname = TextEditingController(text: widget.user.last_name);
    _phone = TextEditingController(text: widget.user.phone_number.toString());
    _telephone =
        TextEditingController(text: widget.user.telephone_number.toString());
    _email = TextEditingController(text: widget.user.email);
    _password = TextEditingController(text: widget.user.password.toString());
    _date = TextEditingController(text: widget.user.date);
    _selectedRole = widget.user.role_id == 0
        ? "مشرف"
        : widget.user.role_id == 1
            ? "مدير"
            : "معلم";
    _isActivate = widget.user.isActivate == 1;
    _selectedSchoolId = widget.user.school_id;
    _refreshData();
  }

  void _refreshData() async {
    await userController.get_data_users();
    _loadSchools();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("معلومات المستخدم"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                buildTextField(
                  controller: _firstname,
                  label: 'الاسم الأول',
                  readOnly: !_isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الأول';
                    }
                  },
                ),
                SizedBox(height: 10),
                buildTextField(
                  controller: _fathername,
                  label: 'اسم الأب',
                  readOnly: !_isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الأب';
                    }
                  },
                ),
                SizedBox(height: 10),
                buildTextField(
                  controller: _grandfathername,
                  label: 'اسم الجد',
                  readOnly: !_isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الجد';
                    }
                  },
                ),
                SizedBox(height: 10),
                buildTextField(
                  controller: _lastname,
                  label: 'القبيلة',
                  readOnly: !_isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال القبيلة';
                    }
                  },
                ),
                SizedBox(height: 10),
                buildTextField(
                  controller: _phone,
                  label: 'رقم الجوال',
                  readOnly: !_isEditable,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
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
                buildTextField(
                  controller: _telephone,
                  label: 'رقم البيت',
                  readOnly: !_isEditable,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم البيت';
                    }
                  },
                ),
                SizedBox(height: 10),
                buildTextField(
                  controller: _email,
                  label: 'البريد الإلكتروني',
                  readOnly: !_isEditable,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  validator: (value) {
                    final emailRegex =
                        RegExp(r'^[a-zA-Z0-9@._\-]+@[gmail]+\.[com]');
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال بريد إلكتروني';
                    } else if (!emailRegex.hasMatch(value)) {
                      return 'البريد الإلكتروني غير صالح';
                      // التحقق من صحة البريد الإلكتروني
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                buildPasswordField(
                  controller: _password,
                  isPasswordVisible: _isPasswordVisible,
                  isEditable: _isEditable,
                  togglePasswordVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                SizedBox(height: 10),
                buildDateField(
                  controller: _date,
                  isEditable: _isEditable,
                  context: context,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedSchoolId,
                        decoration: InputDecoration(
                          labelText: 'اختر المدرسة',
                          border: OutlineInputBorder(),
                        ),
                        items: _schoolItems,
                        onChanged: _isEditable
                            ? (newValue) {
                                setState(() {
                                  _selectedSchoolId = newValue;
                                });
                              }
                            : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddSchool()));
                        await _loadSchools(); // Reload schools after adding a new one
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                buildDropdownField(
                  selectedRole: _selectedRole,
                  isEditable: _isEditable,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                ),
                SizedBox(height: 10),
                buildSwitchListTile(
                  isActivate: _isActivate,
                  isEditable: _isEditable,
                  onChanged: (bool value) {
                    setState(() {
                      _isActivate = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                buildEditButton(
                  isEditable: _isEditable,
                  onPressed: () {
                    setState(() {
                      _isEditable = !_isEditable;
                    });
                  },
                ),
                if (_isEditable)
                  buildSaveButton(
                    formKey: _formKey,
                    user: widget.user,
                    firstname: _firstname,
                    fathername: _fathername,
                    grandfathername: _grandfathername,
                    lastname: _lastname,
                    phone: _phone,
                    telephone: _telephone,
                    email: _email,
                    password: _password,
                    date: _date,
                    selectedRole: _selectedRole,
                    selectedSchoolID: _selectedSchoolId,
                    isActivate: _isActivate,
                    refreshData: _refreshData,
                    context: context,
                    setEditable: (bool value) {
                      setState(() {
                        _isEditable = value;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
