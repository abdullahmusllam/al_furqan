import 'dart:ffi';

import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';

class EditHalagaScreen extends StatefulWidget {
  // final StudentModel? student;
  final HalagaModel halga;
  const EditHalagaScreen({super.key, required this.halga});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditHalagaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController NameController = TextEditingController();
  final TextEditingController NumberStudentController = TextEditingController();
  final TextEditingController grandfatherNameController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // تعبئة الحقول بالبيانات الحالية للطالب
    NameController.text = widget.halga.Name ?? '';
    // NumberStudentController.text =
    //     (widget.halga.NumberStudent ?? '' as int) as String;
    // grandfatherNameController.text = widget.student.grandfatherName ?? '';
    // lastNameController.text = widget.student.lastName ?? '';
  }

  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     widget.student.firstName = firstNameController.text;
  //     widget.student.middleName = NumberStudentController.text;
  //     widget.student.grandfatherName = grandfatherNameController.text;
  //     widget.student.lastName = lastNameController.text;

  //     studentController.updateStudent(widget.student,
  //         widget.student.studentID!); // استخدام الدالة لتحديث بيانات الطالب

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('تم تعديل بيانات الطالب بنجاح')),
  //     );
  //     Navigator.pop(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل بيانات الطالب')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(NameController, 'الاسم الأول'),
              _buildTextField(NumberStudentController, 'عدد الطلاب'),
              _buildTextField(grandfatherNameController, 'اسم الجد'),
              _buildTextField(lastNameController, 'اسم العائلة'),
              SizedBox(height: 20),
              Row(
                children: [
                  // Expanded(
                  //   // child: ElevatedButton(
                  //   //   // onPressed: //_submitForm,
                  //   //   // style: ElevatedButton.styleFrom(
                  //   //   //     backgroundColor: Colors.blue),
                  //   //   child: Text('تعديل'),
                  //   // ),
                  // ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // العودة بدون حفظ التعديلات
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('إلغاء'),
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
