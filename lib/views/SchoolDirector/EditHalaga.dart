import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/add_students_to_halqa_screen.dart';
import 'package:flutter/material.dart';

class EditHalagaScreen extends StatefulWidget {
  final HalagaModel halga;
  const EditHalagaScreen({super.key, required this.halga});

  @override
  _EditHalagaScreenState createState() => _EditHalagaScreenState();
}

class _EditHalagaScreenState extends State<EditHalagaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  List<StudentModel> students = [];
  List<UserModel> teachers = [];
  int? selectedTeacherId;
  bool _isLoading = false;
  final _sqlDb = SqlDb();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.halga.Name ?? '';
    _loadTeachers();
    _loadStudents();
  }

  Future<void> _loadTeachers() async {
    if (widget.halga.SchoolID == null) {
      print("SchoolID is null");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف المدرسة غير متوفر')),
        );
      }
      return;
    }
    try {
      final fetchedTeachers =
          await halagaController.getTeachers(widget.halga.SchoolID!);
      if (mounted) {
        setState(() {
          teachers = fetchedTeachers;
          // تحديد المعلم الحالي بناءً على TeacherName أو ElhalagatID
          if (widget.halga.TeacherName != null &&
              widget.halga.TeacherName != 'لا يوجد معلم للحلقة') {
            final currentTeacher = teachers.firstWhere(
              (teacher) =>
                  '${teacher.first_name} ${teacher.last_name}' ==
                  widget.halga.TeacherName,
              orElse: () => UserModel(),
            );
            selectedTeacherId = currentTeacher.user_id;
          }
        });
      }
    } catch (e) {
      print("Error loading teachers: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب المعلمين: $e')),
        );
      }
    }
  }

  Future<void> _loadStudents() async {
    if (widget.halga.halagaID == null) {
      print("halagaID is null");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف الحلقة غير متوفر')),
        );
      }
      return;
    }
    try {
      if (mounted) setState(() => _isLoading = true);
      final fetchedStudents =
          await studentController.getStudents(widget.halga.halagaID!);
      if (mounted) {
        setState(() {
          students = fetchedStudents;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading students: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب الطلاب: $e')),
        );
      }
    }
  }

  Future<void> _removeStudent(int studentId) async {
    try {
      await studentController.removeStudentFromHalqa(studentId);
      if (mounted) {
        setState(() {
          students.removeWhere((student) => student.studentID == studentId);
        });
        // تحديث عدد الطلاب في الحلقة
        final count =
            await halagaController.getStudentCount(widget.halga.halagaID!);
        await _sqlDb.updateData(
            "UPDATE Elhalagat SET NumberStudent = $count WHERE halagaID = ${widget.halga.halagaID}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء ارتباط الطالب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error removing student: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إلغاء ارتباط الطالب: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedHalaga = HalagaModel(
          halagaID: widget.halga.halagaID,
          Name: nameController.text,
          SchoolID: widget.halga.SchoolID,
          NumberStudent: students.length,
          TeacherName: selectedTeacherId != null
              ? teachers
                  .firstWhere((teacher) => teacher.user_id == selectedTeacherId)
                  .first_name
              : null,
        );

        await halagaController.updateHalaga(updatedHalaga, selectedTeacherId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تعديل بيانات الحلقة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print("Error updating halaga: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في تعديل الحلقة: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل بيانات الحلقة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, 'اسم الحلقة'),
              const SizedBox(height: 16),
              _buildTeacherDropdown(),
              const SizedBox(height: 16),
              const Text(
                'الطلاب الحاليون:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : students.isEmpty
                        ? const Center(
                            child: Text(
                              'لا يوجد طلاب في هذه الحلقة',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return ListTile(
                                title: Text(
                                  '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.grandfatherName ?? ''} ${student.lastName ?? ''}'
                                      .trim(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeStudent(student.studentID!),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (widget.halga.halagaID == null ||
                      widget.halga.SchoolID == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('خطأ: معرف الحلقة أو المدرسة غير متوفر')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStudentsToHalqaScreen(
                        halqaID: widget.halga.halagaID,
                        schoolID: widget.halga.SchoolID,
                      ),
                    ),
                  ).then((_) => _loadStudents());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'إضافة طلاب جدد',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'حفظ التعديلات',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTeacherDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedTeacherId,
      decoration: const InputDecoration(
        labelText: 'اختر المعلم',
        border: OutlineInputBorder(),
      ),
      items: teachers.map((teacher) {
        return DropdownMenuItem<int>(
          value: teacher.user_id,
          child: Text(
            '${teacher.first_name ?? ''} ${teacher.last_name ?? ''}'.trim(),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTeacherId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار معلم';
        }
        return null;
      },
    );
  }
}
