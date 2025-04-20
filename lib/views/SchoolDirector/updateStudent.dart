import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';

class EditStudentScreen extends StatefulWidget {
  // final UserModel? user;
  final StudentModel student; // استلام بيانات الطالب لتعديلها
  const EditStudentScreen({super.key, required this.student});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController grandfatherNameController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // تعبئة الحقول بالبيانات الحالية للطالب
    firstNameController.text = widget.student.firstName ?? '';
    middleNameController.text = widget.student.middleName ?? '';
    grandfatherNameController.text = widget.student.grandfatherName ?? '';
    lastNameController.text = widget.student.lastName ?? '';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.student.firstName = firstNameController.text;
      widget.student.middleName = middleNameController.text;
      widget.student.grandfatherName = grandfatherNameController.text;
      widget.student.lastName = lastNameController.text;
      studentController.updateStudent(widget.student,
          widget.student.studentID!); // استخدام الدالة لتحديث بيانات الطالب

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تعديل بيانات الطالب بنجاح')),
      );
      Navigator.pop(context);
    }
  }

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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: Text('تعديل'),
                    ),
                  ),
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
        keyboardType: TextInputType.name,
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[0-9٠-٩]'))
        ],
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
