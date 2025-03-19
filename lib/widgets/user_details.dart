import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  const UserDetails({super.key, required this.user});

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
  int? _selectedSchoolId;
  List<DropdownMenuItem<int>> _schoolItems = [];

  bool _isActivate = false;

  Future<void> _loadSchools() async {
    await schoolController.get_data();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.schoolID,
                child:
                    Text("${school.school_name!}\n${school.school_location}"),
              ))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _selectedRole = _getRole(widget.user.roleID!);
    _isActivate = widget.user.isActivate == 1;
    _selectedSchoolId = widget.user.schoolID;
    _refreshData();
  }

  void _initializeControllers() {
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
  }

  String _getRole(int roleId) {
    switch (roleId) {
      case 0:
        return "مشرف";
      case 1:
        return "مدير";
      default:
        return "معلم";
    }
  }

  void _refreshData() async {
    await userController.getDataUsers();
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
                _buildTextField(
                    _firstname, 'الاسم الأول', TextInputType.text, 50),
                SizedBox(height: 10),
                _buildTextField(
                    _fathername, 'اسم الأب', TextInputType.text, 50),
                SizedBox(height: 10),
                _buildTextField(
                    _grandfathername, 'اسم الجد', TextInputType.text, 50),
                SizedBox(height: 10),
                _buildTextField(_lastname, 'القبيلة', TextInputType.text, 50),
                SizedBox(height: 10),
                _buildTextField(_phone, 'رقم الجوال', TextInputType.phone, 9),
                SizedBox(height: 10),
                _buildTextField(
                    _telephone, 'رقم البيت', TextInputType.phone, 6),
                SizedBox(height: 10),
                _buildTextField(_email, 'البريد الإلكتروني',
                    TextInputType.emailAddress, 50),
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
                _buildSchoolDropdown(),
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

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType, int maxLength) {
    return buildTextField(
      controller: controller,
      label: label,
      readOnly: !_isEditable,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال $label';
        }
        if (keyboardType == TextInputType.phone && value.length < maxLength) {
          return '$label يجب أن يكون $maxLength أرقام';
        }
        if (keyboardType == TextInputType.emailAddress) {
          final emailRegex = RegExp(r'^[a-zA-Z0-9@._\-]+@[gmail]+\.[com]');
          if (!emailRegex.hasMatch(value)) {
            return 'البريد الإلكتروني غير صالح';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSchoolDropdown() {
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
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddSchool()));
            await _loadSchools(); // Reload schools after adding a new one
          },
        ),
      ],
    );
  }
}
