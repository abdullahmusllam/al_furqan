import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:intl/intl.dart';

import '../../../controllers/TeacherController.dart';

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
  final TextEditingController islamicStudiesSubjectController =
      TextEditingController();
  final TextEditingController islamicStudiesContentController =
      TextEditingController();

  // تواريخ خطة الحفظ
  DateTime? conservationStartDate;
  DateTime? conservationEndDate;

  // تواريخ خطة التلاوة
  DateTime? recitationStartDate;
  DateTime? recitationEndDate;

  List<UserModel> teachers = [];
  UserModel? selectedTeacher; // المتغير الذي يخزن المعلم المختار

  List<StudentModel> studentsWithoutHalaga = [];
  Map<int, bool> selectedStudents = {}; // تخزين الطلاب المحددين
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeachers(); // استدعاء دالة تحميل المعلمين
  }

  void _loadTeachers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      // جلب المعلمين حسب SchoolID
      await teacherController.getTeachersBySchoolID(widget.user.schoolID!);

      // ترتيب المعلمين: المتاحين أولاً ثم المرتبطين بحلقات
      List<UserModel> availableTeachers = [];
      List<UserModel> assignedTeachers = [];

      for (var teacher in teacherController.teachers) {
        if (teacher.elhalagatID == null) {
          availableTeachers.add(teacher);
        } else {
          assignedTeachers.add(teacher);
        }
      }

      // دمج القائمتين مع وضع المتاحين أولاً
      if (mounted) {
        setState(() {
          teachers = [...availableTeachers, ...assignedTeachers];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء جلب المعلمين: $e";
          _isLoading = false;
        });
      }
    }
  }

  // جلب الطلاب الذين ليس لديهم حلقة
  Future<void> _loadStudentsWithoutHalaga() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final students = await studentController
          .getStudentsWithoutHalaga(widget.user.schoolID!);
      if (mounted) {
        setState(() {
          studentsWithoutHalaga = students;
          // تهيئة قائمة الطلاب المحددين
          for (var student in students) {
            selectedStudents[student.studentID!] = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء جلب الطلاب: $e";
          _isLoading = false;
        });
      }
    }
  }

  // عدد الطلاب المحددين
  int get selectedStudentCount {
    return selectedStudents.values.where((isSelected) => isSelected).length;
  }

  // تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return 'لم يتم التحديد';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة حلقة', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<UserModel>(
                            value: selectedTeacher,
                            items: teachers.isEmpty
                                ? [
                                    DropdownMenuItem<UserModel>(
                                      enabled: false,
                                      value: null,
                                      child: Text(
                                        'لا يوجد معلمين متاحين',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  ]
                                : teachers.map((teacher) {
                                    // التحقق مما إذا كان المعلم لديه حلقة بالفعل
                                    bool hasHalaga =
                                        teacher.elhalagatID != null;

                                    return DropdownMenuItem<UserModel>(
                                      value: teacher,
                                      // تعطيل المعلمين الذين لديهم حلقات
                                      enabled: !hasHalaga,
                                      child: Row(
                                        children: [
                                          // عرض أيقونة تشير إلى حالة المعلم
                                          Icon(
                                            hasHalaga
                                                ? Icons.person_off
                                                : Icons.person_outlined,
                                            color: hasHalaga
                                                ? Colors.grey
                                                : Colors.green,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          // عرض اسم المعلم
                                          Text(
                                            '${teacher.first_name} ${teacher.last_name}',
                                            style: TextStyle(
                                              color: hasHalaga
                                                  ? Colors.grey
                                                  : Colors.black,
                                              fontWeight: hasHalaga
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                            ),
                                          ),
                                          // إضافة وصف للمعلمين الذين لديهم حلقات
                                          if (hasHalaga)
                                            Expanded(
                                              child: Text(
                                                ' (مرتبط بحلقة)',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                        ],
                                      ),
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
                              hintText: 'اختر معلم غير مرتبط بحلقة',
                            ),
                            isExpanded:
                                true, // للتأكد من أن النص يظهر بشكل كامل
                          ),

                          // إضافة ملاحظة توضيحية حول المعلمين
                          if (teachers
                              .any((teacher) => teacher.elhalagatID == null))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 16, color: Colors.green),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'فقط المعلمون الغير مرتبطين بحلقات متاحون للاختيار',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // إضافة رسالة عندما لا يوجد معلمين متاحين
                          if (!teachers.any(
                                  (teacher) => teacher.elhalagatID == null) &&
                              teachers.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      size: 16, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'جميع المعلمين مرتبطين بحلقات حالياً. يمكنك تحرير حلقة لإلغاء ارتباط معلم.',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                SizedBox(height: 20),

                // زر لعرض الطلاب الذين ليس لديهم حلقة
                ElevatedButton.icon(
                  onPressed: _loadStudentsWithoutHalaga,
                  icon:
                      Icon(Icons.people, color: Theme.of(context).primaryColor),
                  label: Text('عرض الطلاب بدون حلقة',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),

                SizedBox(height: 10),

                // عرض عدد الطلاب المحددين
                if (selectedStudentCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'الطلاب المحددين: $selectedStudentCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: selectedStudentCount >= 5
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),

                // عرض رسالة الخطأ إذا وجدت
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                // عرض مؤشر التحميل
                if (_isLoading) Center(child: CircularProgressIndicator()),

                // قائمة الطلاب مع صناديق الاختيار
                if (studentsWithoutHalaga.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 300,
                    child: ListView.builder(
                      itemCount: studentsWithoutHalaga.length,
                      itemBuilder: (context, index) {
                        final student = studentsWithoutHalaga[index];
                        return CheckboxListTile(
                          title: Text(
                              '${student.firstName} ${student.middleName} ${student.lastName}'),
                          subtitle: Text('رقم الطالب: ${student.studentID}'),
                          value: selectedStudents[student.studentID] ?? false,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedStudents[student.studentID!] = value!;
                            });
                          },
                        );
                      },
                    ),
                  ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // التحقق من صحة النموذج وعدد الطلاب المحددين
                          if (_formKey.currentState!.validate()) {
                            if (selectedStudentCount < 5) {
                              setState(() {
                                _errorMessage = "يجب اختيار 5 طلاب على الأقل";
                              });
                              return;
                            }

                            // إضافة الحلقة مع البيانات
                            _halaqaModel.SchoolID = widget.user.schoolID;
                            _halaqaModel.Name = halqaNameController.text;

                            // إضافة خطة الحفظ
                            // if (conservationStartDate != null &&
                            //     conservationEndDate != null) {
                            //   _halaqaModel.conservationPlanStart =
                            //       _formatDate(conservationStartDate);
                            //   _halaqaModel.conservationPlanEnd =
                            //       _formatDate(conservationEndDate);
                            // }

                            // إضافة خطة التلاوة
                            // if (recitationStartDate != null &&
                            //     recitationEndDate != null) {
                            //   _halaqaModel.recitationPlanStart =
                            //       _formatDate(recitationStartDate);
                            //   _halaqaModel.recitationPlanEnd =
                            //       _formatDate(recitationEndDate);
                            // }

                            // إضافة العلوم الشرعية
                            // if (islamicStudiesSubjectController
                            //     .text.isNotEmpty) {
                            //   _halaqaModel.islamicStudiesSubject =
                            //       islamicStudiesSubjectController.text;
                            //   _halaqaModel.islamicStudiesContent =
                            //       islamicStudiesContentController.text;
                            // }

                            try {
                              // تعيين عدد الطلاب في نموذج الحلقة
                              int studentCount = selectedStudentCount;
                              _halaqaModel.NumberStudent = studentCount;
                              
                              // إضافة الحلقة
                              await halagaController.addHalaga(_halaqaModel,1);

                              // الحصول على قائمة معرفات الطلاب المحددين
                              List<int> selectedStudentIds = [];
                              selectedStudents.forEach((studentId, isSelected) {
                                if (isSelected) {
                                  selectedStudentIds.add(studentId);
                                }
                              });

                              // إضافة الطلاب للحلقة
                              await studentController.assignStudentsToHalaga(
                                  selectedStudentIds, _halaqaModel.halagaID!);

                              // إضافة المعلم للحلقة (إذا تم اختياره)
                              if (selectedTeacher != null) {
                                // التحقق من أن المعلم غير مرتبط بحلقة أخرى
                                if (selectedTeacher!.elhalagatID != null) {
                                  setState(() {
                                    _errorMessage =
                                        "المعلم المختار مرتبط بحلقة أخرى بالفعل";
                                  });
                                  return;
                                }
                                // تأكيد تعيين عدد الطلاب قبل تحديث الحلقة
                                _halaqaModel.NumberStudent = studentCount;
                                await halagaController.updateHalaga(
                                    _halaqaModel, 1);
                                await halagaController.updateTeacherAssignment(selectedTeacher!.user_id!, _halaqaModel.halagaID!);
                                // تحديث elhalagatID للمعلم
                                selectedTeacher!.elhalagatID = _halaqaModel.halagaID;
                                await userController.updateUser(selectedTeacher!, 1);
                                print("تم تحديث المعلم ${selectedTeacher!.first_name} ${selectedTeacher!.last_name} بحلقة رقم ${_halaqaModel.halagaID}");
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم إضافة الحلقة بنجاح'),
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              setState(() {
                                _errorMessage =
                                    "حدث خطأ أثناء إضافة الحلقة: $e";
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        child: Text('إضافة'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                        ),
                        child: Text('الغاء'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تصميم حقل إدخال نصي
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
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