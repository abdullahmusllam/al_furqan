import 'package:al_furqan/controllers/StudentController.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController grandfatherNameController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  StudentModel studentModel = StudentModel();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      studentModel.firstName = firstNameController.text;
      studentModel.middleName = middleNameController.text;
      studentModel.grandfatherName = grandfatherNameController.text;
      studentModel.lastName = lastNameController.text;

      studentController.addStudent(studentModel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة الطالب بنجاح')),
        //  setState(() {});
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: _submitForm,
                      child: Text('إضافة'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('إدارة'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
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
