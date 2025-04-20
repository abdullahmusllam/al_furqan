import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';

class AddHalaqaScreen extends StatefulWidget {
  @override
  _AddHalaqaScreenState createState() => _AddHalaqaScreenState();
  final UserModel user;
  const AddHalaqaScreen({super.key, required this.user});
}

class _AddHalaqaScreenState extends State<AddHalaqaScreen> {
  final _formKey = GlobalKey<FormState>();
  final HalagaModel _halaqaModel = HalagaModel();
  final TextEditingController halqaNameController = TextEditingController();
  
  List<UserModel> teachers = [];
  UserModel? selectedTeacher; // المتغير الذي يخزن المعلم المختار

  @override
  void initState() {
    super.initState();
    _loadTeachers(); // استدعاء دالة تحميل المعلمين
  }

  void _loadTeachers() async {
    // جلب المعلمين حسب SchoolID
    List<UserModel> loadedTeachers = await halagaController.getTeachers(widget.user.schoolID!);
    setState(() {
      teachers = loadedTeachers; // تعيين المعلمين في القائمة
    });
  }

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
              
              SizedBox(height: 20),

              // القائمة المنسدلة لاختيار المعلم
              DropdownButtonFormField<UserModel>(
                value: selectedTeacher,
                items: teachers.map((teacher) {
                  return DropdownMenuItem<UserModel>(
                    value: teacher,
                    child: Text('${teacher.first_name} ${teacher.last_name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTeacher = value; // تعيين المعلم المختار
                  });
                },
                decoration: InputDecoration(
                  labelText: 'اختر المعلم',
                  border: OutlineInputBorder(),
                ),
                // validator: (value) {
                //   if (value == null) {
                //     return 'الرجاء اختيار معلم';
                //   }
                //   return null;
                // },
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // إضافة الحلقة مع البيانات
                          _halaqaModel.SchoolID = widget.user.schoolID;
                          _halaqaModel.Name = halqaNameController.text;
                          // int TeacherID = selectedTeacher!.userID; // تعيين ID المعلم

                          halagaController.addHalaga(_halaqaModel);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة الحلقة بنجاح'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: Text('إضافة'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // الانتقال إلى صفحة إدارة الحلقات
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: Text('إدارة'),
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
