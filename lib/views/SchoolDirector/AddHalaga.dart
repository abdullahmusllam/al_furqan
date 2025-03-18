import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';

class AddHalaqaScreen extends StatefulWidget {
  @override
  _AddHalaqaScreenState createState() => _AddHalaqaScreenState();
  final UserModel user;
  AddHalaqaScreen({required this.user});
}

class _AddHalaqaScreenState extends State<AddHalaqaScreen> {
  final _formKey = GlobalKey<FormState>();
  HalagaModel _halaqaModel = HalagaModel();
  final TextEditingController halqaNameController = TextEditingController();
  final TextEditingController numberStudentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة حلقة'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقول إدخال البيانات
              _buildTextFormField(
                controller: halqaNameController,
                label: 'اسم الحلقة',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الحلقة';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: numberStudentController,
                label: 'عدد الطلاب',
                isNumber: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عدد الطلاب';
                  }
                  if (int.tryParse(value) == null) {
                    return 'الرجاء إدخال عدد صحيح';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // هنا يتم تنفيذ عملية إضافة الحلقة بعد التحقق
                          _halaqaModel.SchoolID = widget.user.schoolID;
                          _halaqaModel.Name = halqaNameController.text;
                          _halaqaModel.NumberStudent =
                              int.parse(numberStudentController.text);
                          halagaController.addHalaga(_halaqaModel);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة الحلقة بنجاح'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text('إضافة'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // الانتقال إلى صفحة إدارة الحلقات
                      },
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

  // تصميم حقل إدخال نصي
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
