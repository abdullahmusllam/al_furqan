import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';

class AddStudentScreen extends StatefulWidget {
  final UserModel? user;
  const AddStudentScreen({super.key, required this.user});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final grandfatherNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final studentModel = StudentModel();
  final _connectivity = Connectivity().checkConnectivity();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // user is manager of school
      studentModel.studentID = widget.user?.schoolID;
      studentModel.firstName = firstNameController.text;
      studentModel.middleName = middleNameController.text;
      studentModel.grandfatherName = grandfatherNameController.text;
      studentModel.lastName = lastNameController.text;

      // firebasehelper.addStudent(studentModel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة الطالب بنجاح')),
        //  setState(() {});
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _schoolId = widget.user?.schoolID;
    return Scaffold(
      appBar: AppBar(title: Text('إضافة طالب')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(firstNameController, 'الاسم الأول'),
              _buildTextField(middleNameController, 'الاسم الأوسط'),
              _buildTextField(grandfatherNameController, 'اسم الجد'),
              _buildTextField(lastNameController, 'اسم العائلة'),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        print(
                            "widget.user?.schoolID : ${widget.user?.schoolID}");
                        if (_formKey.currentState!.validate()) {
                          studentModel.schoolId = _schoolId;
                          studentModel.firstName = firstNameController.text;
                          studentModel.middleName = middleNameController.text;
                          studentModel.grandfatherName =
                              grandfatherNameController.text;
                          studentModel.lastName = lastNameController.text;
                          print(
                              "Student Models in Add Student : ${studentModel.grandfatherName}");
                          await studentController.addStudent(studentModel);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              "Adedd!",
                            ),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ));
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: Text(
                        'إضافة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: Text(
                        'جلب ملف إكسل',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[0-9٠-٩]'))
        ],
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
