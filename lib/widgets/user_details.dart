import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool _isActivate = false;

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
    _refreshData();
  }

  void _refreshData() async {
    await userController.get_data();
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
                _buildTextField(
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
                _buildTextField(
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
                _buildTextField(
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
                _buildTextField(
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
                _buildTextField(
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
                _buildTextField(
                  controller: _email,
                  label: 'البريد الإلكتروني',
                  readOnly: !_isEditable,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
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
                _buildPasswordField(),
                SizedBox(height: 10),
                _buildDateField(),
                SizedBox(height: 10),
                _buildDropdownField(),
                SizedBox(height: 10),
                _buildSwitchListTile(),
                SizedBox(height: 10),
                _buildEditButton(),
                if (_isEditable) _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      readOnly: readOnly,
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _password,
      obscureText: !_isPasswordVisible,
      maxLength: 8,
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
      readOnly: !_isEditable,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        } else if (value.length < 8) {
          return 'كلمة المرور يجب أن تكون 8 أرقام أو أكثر';
        }
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _date,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'تاريخ الميلاد',
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        if (_isEditable) {
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
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال تاريخ الميلاد';
        }
      },
    );
  }

  Widget _buildDropdownField() {
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
      onChanged: _isEditable
          ? (newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            }
          : null,
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار الدور';
        }
      },
    );
  }

  Widget _buildSwitchListTile() {
    return SwitchListTile(
      title: Text('تفعيل المستخدم'),
      value: _isActivate,
      onChanged: _isEditable
          ? (bool value) {
              setState(() {
                _isActivate = value;
              });
            }
          : null,
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isEditable = !_isEditable;
        });
      },
      child: Text(_isEditable ? 'إلغاء' : 'تعديل البيانات'),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Handle form submission
          int phone = int.parse(_phone.text);
          int telephone = int.parse(_telephone.text);
          int password = int.parse(_password.text);
          int? role_id;
          int activate = _isActivate ? 1 : 0;

          widget.user.first_name = _firstname.text;
          widget.user.middle_name = _fathername.text;
          widget.user.grandfather_name = _grandfathername.text;
          widget.user.last_name = _lastname.text;
          widget.user.phone_number = phone;
          widget.user.telephone_number = telephone;
          widget.user.email = _email.text;
          widget.user.password = password;
          widget.user.date = _date.text; // تعيين تاريخ الميلاد
          widget.user.isActivate = activate; // تعيين حالة التفعيل

          switch (_selectedRole) {
            case "مشرف":
              role_id = 0;
              break;
            case "مدير":
              role_id = 1;
              break;
            case "معلم":
              role_id = 2;
              break;
          }
          widget.user.role_id = role_id;
          userController.update_user(widget.user);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم حفظ التعديلات بنجاح"),
            ),
          );
          setState(() {
            _isEditable = false;
          });
          _refreshData();
          Navigator.of(context)
              .pop(true); // Return true to indicate that data was updated
        }
      },
      child: Text('حفظ التعديلات'),
    );
  }
}
