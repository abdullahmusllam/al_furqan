import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditStudentScreen extends StatefulWidget {
  // final UserModel? user;
  final StudentModel student; // استلام بيانات الطالب لتعديلها
  // final UserModel fatherModel;

  const EditStudentScreen({super.key, required this.student});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final grandfatherNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final grandFatherNameForFatherStudent = TextEditingController();
  final gmailOfFatherStudent = TextEditingController();
  final passwordFatherStudent = TextEditingController();
  final phoneFatherStudent = TextEditingController();
  final telephoneFatherStudent = TextEditingController();
  final dateFatherStudent = TextEditingController();
  var father = fathersController.fatherByID;

  // final studentModel = StudentModel();

  @override
  void initState() {
    super.initState();
    _fetchFatherStudent();
    // تعبئة الحقول بالبيانات الحالية للطالب
    // initTextContoller();
  }

  void initTextContoller() async {
    // تعبئة الحقول بالبيانات الحالية للطالب
    print("this's initTextColtoller method");
    print("Student ID in initTextColtoller method : ${father.first_name}");
    firstNameController.text = widget.student.firstName ?? '';
    middleNameController.text = widget.student.middleName ?? '';
    grandfatherNameController.text = widget.student.grandfatherName ?? '';
    lastNameController.text = widget.student.lastName ?? '';
    grandFatherNameForFatherStudent.text = father.grandfather_name ?? '';
    dateFatherStudent.text = father.date ?? '';
    gmailOfFatherStudent.text = father.email ?? 'gh';
    phoneFatherStudent.text = father.phone_number.toString();
    telephoneFatherStudent.text = father.telephone_number.toString();
  }

  Future<void> _fetchFatherStudent() async {
    await fathersController.getFathersStudentsByStudentID(
        widget.student.schoolId!, widget.student.studentID!);
    initTextContoller();
  }

  Future<void> _refreshData() async {
    List<StudentModel>? loadedStudent =
        await studentController.getSchoolStudents(widget.student.schoolId!);
    print("Hi this's refreshing data");
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      widget.student.firstName = firstNameController.text;
      widget.student.middleName = middleNameController.text;
      widget.student.grandfatherName = grandfatherNameController.text;
      widget.student.lastName = lastNameController.text;
      father.first_name = middleNameController.text;
      father.middle_name = grandfatherNameController.text;
      father.grandfather_name = grandFatherNameForFatherStudent.text;
      father.last_name = lastNameController.text;
      father.phone_number = int.parse(phoneFatherStudent.text);
      father.telephone_number = int.parse(telephoneFatherStudent.text);
      father.email = gmailOfFatherStudent.text;
      father.date = dateFatherStudent.text;

      await studentController.updateStudent(widget.student,
          widget.student.studentID!, 1); // استخدام الدالة لتحديث بيانات الطالب
      await userController.updateUser(father,1).then((_) async {
        // تحميل البيانات من القاعدة المحلية

        // إذا لم يكن هناك اتصال بالإنترنت، يتم تحميل البيانات من القاعدة المحلية فقط
        await _refreshData();
        Navigator.pop(context); // العودة إلى الصفحة السابقة
      });
    } else {
      print("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل بيانات الطالب')),
      body: SingleChildScrollView(
        child: Padding(
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
                dataOfFatherStudent(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text('تعديل',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // العودة بدون حفظ التعديلات
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text('إلغاء',
                            style: TextStyle(color: Colors.white)),
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

  Container dataOfFatherStudent() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "بيانات ولي الامر",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              _buildTextField(middleNameController, "اسم ولى الامر"),
              _buildTextField(
                  grandfatherNameController, "الاسم الاوسط لولي الامر"),
              _buildTextField(
                  grandFatherNameForFatherStudent, "اسم جد ولي الامر"),
              _buildTextField(lastNameController, "القبيلة"),
              _buildTextFieldData(),
              _buildTextField(gmailOfFatherStudent, "البريد الالكتروني"),
              _builtTextFieldNumber("رقم الجوال", phoneFatherStudent, 9),
              _builtTextFieldNumber("رقم البيت", telephoneFatherStudent, 6),
            ],
          ),
        ));
  }

  Padding _buildTextFieldData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        controller: dateFatherStudent,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'تاريخ الميلاد',
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1700),
            lastDate: DateTime(2300),
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat.yMMMd().format(pickedDate);
            setState(() {
              dateFatherStudent.text = formattedDate;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال تاريخ الميلاد';
          }
          return null;
        },
      ),
    );
  }

  Widget _builtTextFieldNumber(
      String label, TextEditingController controller, int maxLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
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
