import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final grandFatherNameForFatherStudent = TextEditingController();
  final gmailOfFatherStudent = TextEditingController();
  final passwordFatherStudent = TextEditingController();
  final phoneFatherStudent = TextEditingController();
  final telephoneFatherStudent = TextEditingController();
  final _dateFatherStudent = TextEditingController();

  final studentModel = StudentModel();
  final fatherModel = UserModel();
  final _connectivity = Connectivity().checkConnectivity();
  bool _isProcessingExcel = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // user is manager of school
      studentModel.schoolId = widget.user?.schoolID;
      print(
          "School ID into Student in AddStudent Page : ${studentModel.schoolId}");
      studentModel.firstName = firstNameController.text;
      studentModel.middleName = middleNameController.text;
      studentModel.grandfatherName = grandfatherNameController.text;
      studentModel.lastName = lastNameController.text;

      // بيانات ولي الامر
      fatherModel.schoolID = widget.user!.schoolID;
      fatherModel.first_name = middleNameController.text;
      fatherModel.middle_name = grandfatherNameController.text;
      fatherModel.grandfather_name = grandFatherNameForFatherStudent.text;
      fatherModel.last_name = lastNameController.text;
      fatherModel.email = gmailOfFatherStudent.text;
      fatherModel.phone_number = int.tryParse(phoneFatherStudent.text);
      fatherModel.date = _dateFatherStudent.text;
      fatherModel.telephone_number = int.tryParse(telephoneFatherStudent.text);
      fatherModel.password = 12345678; //defualt Just for fathers
      fatherModel.roleID = 3; // 3 means fathers in display later
      fatherModel.schoolID = widget.user!.schoolID;
      print(
          "School ID into Father in AddStudent Page : : ${fatherModel.schoolID}");
      fatherModel.isActivate = 0; // not actinates

      // firebasehelper.addStudent(studentModel);
      fatherModel.user_id = await fathersController
          .addFather(fatherModel); // first add father to init userID
      print("Father ID in AddStudent Page : ${fatherModel.user_id}");
      studentModel.userID =
          fatherModel.user_id; // assign userID to studentModel
      print("Student ID in AddStudent Page : ${studentModel.userID}");
      await studentController.addStudent(studentModel); // then add student

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الطالب بنجاح'),
          backgroundColor: Colors.green,
        ),
        //  setState(() {});
      );
      Navigator.pop(context);
    }
  }

/// export excel file and handling it
  Future<void> _pickAndProcessExcel() async {
    // طلب إذن التخزين
    if (await Permission.storage.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى منح إذن الوصول إلى التخزين'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
  
    setState(() => _isProcessingExcel = true);// بدء عملية المعالجة

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles( // اختيار ملف
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {// التحقق من اختيار ملف
        // إظهار رسالة خطأ إذا لم يتم اختيار ملف
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لم يتم اختيار ملف'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isProcessingExcel = false);// إنهاء عملية المعالجة
        return;
      }

      String? fileName = result.files.first.name; //
      if (fileName == null || (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الملف المختار ليس ملف Excel (.xlsx أو .xls)'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isProcessingExcel = false);
        return;
      }

      Uint8List? fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في قراءة محتوى الملف'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isProcessingExcel = false);
        return;
      }

      var excel = Excel.decodeBytes(fileBytes);
      bool dataAdded = false;

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        // افتراض أن الصف الأول يحتوي على رؤوس الأعمدة
        List<String> headers = sheet.rows[0].map((cell) => cell?.value?.toString() ?? '').toList();
        print("Headers: $headers");

        // تحقق من وجود الأعمدة المتوقعة
        List<String> expectedHeaders = [
          'StudentID',
          'FirstName',
          'MiddleName',
          'GrandfatherName',
          'LastName',
          'FatherFirstName',
          'FatherMiddleName',
          'FatherGrandfatherName',
          'FatherLastName',
          'FatherEmail',
          'FatherPhone',
          'FatherTelephone',
          'FatherDateOfBirth'
        ];

        bool isValidFormat = expectedHeaders.every((header) => headers.contains(header));
        if (!isValidFormat) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تنسيق ملف Excel غير صحيح. تحقق من أسماء الأعمدة.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() => _isProcessingExcel = false);
          return;
        }

        // معالجة الصفوف (تخطي رأس الجدول)
        for (var row in sheet.rows.skip(1)) {
          if (row.isEmpty) continue;

          try {
            // استخراج بيانات الطالب
            StudentModel student = StudentModel(
              studentID: int.tryParse(row[headers.indexOf('StudentID')]?.value?.toString() ?? ''),
              firstName: row[headers.indexOf('FirstName')]?.value?.toString(),
              middleName: row[headers.indexOf('MiddleName')]?.value?.toString(),
              grandfatherName: row[headers.indexOf('GrandfatherName')]?.value?.toString(),
              lastName: row[headers.indexOf('LastName')]?.value?.toString(),
              schoolId: widget.user!.schoolID,
            );

            // استخراج بيانات الأب
            UserModel father = UserModel(
              first_name: row[headers.indexOf('FatherFirstName')]?.value?.toString(),
              middle_name: row[headers.indexOf('FatherMiddleName')]?.value?.toString(),
              grandfather_name: row[headers.indexOf('FatherGrandfatherName')]?.value?.toString(),
              last_name: row[headers.indexOf('FatherLastName')]?.value?.toString(),
              email: row[headers.indexOf('FatherEmail')]?.value?.toString(),
              phone_number: int.tryParse(row[headers.indexOf('FatherPhone')]?.value?.toString() ?? ''),
              telephone_number: int.tryParse(row[headers.indexOf('FatherTelephone')]?.value?.toString() ?? ''),
              date: row[headers.indexOf('FatherDateOfBirth')]?.value?.toString(),
              password: 12345678,
              roleID: 3,
              schoolID: widget.user!.schoolID,
              isActivate: 0,
            );

            // التحقق من صحة البيانات
            if (student.studentID == null ||
                student.firstName == null ||
                student.lastName == null ||
                father.first_name == null ||
                father.last_name == null ||
                father.email == null) {
              print("Skipping invalid row: $row");
              continue;
            }

            // إضافة الأب
            father.user_id = await fathersController.addFather(father);
            student.userID = father.user_id;

            // إضافة الطالب
            await studentController.addStudent(student);
            dataAdded = true;
            print("Added student: ${student.firstName}, Father: ${father.first_name}");
          } catch (e) {
            print("Error processing row: $row, Error: $e");
            continue;
          }
        }
      }

      setState(() => _isProcessingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dataAdded ? 'تمت إضافة الطلاب من ملف Excel بنجاح' : 'لم يتم إضافة أي بيانات من الملف'),
          backgroundColor: dataAdded ? Colors.green : Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("Error processing Excel file: $e");
      setState(() => _isProcessingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في معالجة ملف Excel: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _schoolId = widget.user?.schoolID;
    return Scaffold(
      appBar: AppBar(title: Text('إضافة طالب')),
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
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // await _submit2(_schoolId, context);
                          _submitForm();
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
                        onPressed: () async {
                          /// export excel file
                          
                        },
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
        controller: _dateFatherStudent,
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
              _dateFatherStudent.text = formattedDate;
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
}
