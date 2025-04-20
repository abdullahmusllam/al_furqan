import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/StudentController.dart';
import '../../controllers/excel_testing.dart';
import '../../controllers/fathers_controller.dart';
import '../../models/student_model.dart';
import '../../models/users_model.dart';

class HandlingExcelFile extends StatefulWidget {
  int? schoolID;
  HandlingExcelFile({super.key, required this.schoolID});

  @override
  State<HandlingExcelFile> createState() =>
      _HandlingExcelFileState(schoolID: schoolID);
}

class _HandlingExcelFileState extends State<HandlingExcelFile> {
  int? schoolID;
  late ExcelTesting excelTesting;
  _HandlingExcelFileState({required this.schoolID}) {
    excelTesting = ExcelTesting(schoolID: schoolID);
  }
  bool _isProcessingExcel = false;

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

    setState(() => _isProcessingExcel = true); // بدء عملية المعالجة

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // اختيار ملف
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // التحقق من اختيار ملف
        // إظهار رسالة خطأ إذا لم يتم اختيار ملف
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لم يتم اختيار ملف'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isProcessingExcel = false); // إنهاء عملية المعالجة
        return;
      }

      String? fileName = result.files.first.name; // اسم الملف
      if (fileName == null ||
          (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls'))) {
        // التحقق من نوع الملف
        // إظهار رسالة خطأ إذا كان الملف ليس من نوع Excel
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

      Uint8List? fileBytes = result.files.first.bytes; // قراءة محتوى الملف
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

      var excel = Excel.decodeBytes(fileBytes); // فك تشفير محتوى الملف
      bool dataAdded = false;

      for (var table in excel.tables.keys) {
        // معالجة كل جدول في الملف
        var sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        // افتراض أن الصف الأول يحتوي على رؤوس الأعمدة
        List<String> headers = sheet.rows[0]
            .map((cell) => cell?.value?.toString() ?? '')
            .toList(); // استخراج رؤوس الأعمدة
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

        bool isValidFormat =
            expectedHeaders.every((header) => headers.contains(header));
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
      }

      setState(() => _isProcessingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dataAdded
              ? 'تمت إضافة الطلاب من ملف Excel بنجاح'
              : 'لم يتم إضافة أي بيانات من الملف'),
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

  Future<bool> handlingRow(
      Sheet sheet, List<String> headers, bool dataAdded) async {
    for (var row in sheet.rows.skip(1)) {
      if (row.isEmpty) continue;

      try {
        // استخراج بيانات الطالب
        StudentModel student = StudentModel(
          studentID: int.tryParse(
              row[headers.indexOf('StudentID')]?.value?.toString() ?? ''),
          firstName: row[headers.indexOf('FirstName')]?.value?.toString(),
          middleName: row[headers.indexOf('MiddleName')]?.value?.toString(),
          grandfatherName:
              row[headers.indexOf('GrandfatherName')]?.value?.toString(),
          lastName: row[headers.indexOf('LastName')]?.value?.toString(),
          // schoolId: widget.user!.schoolID,
        );

        // استخراج بيانات الأب
        UserModel father = UserModel(
          first_name:
              row[headers.indexOf('FatherFirstName')]?.value?.toString(),
          middle_name:
              row[headers.indexOf('FatherMiddleName')]?.value?.toString(),
          grandfather_name:
              row[headers.indexOf('FatherGrandfatherName')]?.value?.toString(),
          last_name: row[headers.indexOf('FatherLastName')]?.value?.toString(),
          email: row[headers.indexOf('FatherEmail')]?.value?.toString(),
          phone_number: int.tryParse(
              row[headers.indexOf('FatherPhone')]?.value?.toString() ?? ''),
          telephone_number: int.tryParse(
              row[headers.indexOf('FatherTelephone')]?.value?.toString() ?? ''),
          date: row[headers.indexOf('FatherDateOfBirth')]?.value?.toString(),
          password: 12345678,
          roleID: 3,
          // schoolID: widget.user!.schoolID,
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
        print(
            "Added student: ${student.firstName}, Father: ${father.first_name}");
      } catch (e) {
        print("Error processing row: $row, Error: $e");
        continue;
      }
    }
    return dataAdded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text("معالجة ملف الاكسل"),
        enableBackgroundFilterBlur: true,
        automaticBackgroundVisibility: false,
        backgroundColor: CupertinoColors.activeGreen.withOpacity(0.6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            excelTesting.dataList
                    .isEmpty // التحقق من أن قاعدة البيانات تحتوي بيانات
                ? const Center(
                    child: Text("No Data"),
                  )
                : ListView.builder(
                    itemCount: excelTesting.dataList
                        .length, // طول القائمة التي تحتوي البيانات أو عدد البيانات الموجودة في قاعدة البيانات
                    itemBuilder: (BuildContext, index) {
                      var data = excelTesting.dataList[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              "${data["الاسم الاول"]} ${data["اسم الأب"]} ${data["اسم العائلة"]} "),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "معلومات ولي الامر :",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "الاسم : ${data["اسم الأب"]} ${data["اسم الجد"]} ${data["اسم جد الأب"]} ${data["اسم العائلة"]}",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "رقم الجوال: ${data["رقم الجوال"]}",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "رقم الهاتف : ${data["رقم الهاتف"]}",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "البريد الالكتروني : ${data["البريد الالكتروني"]}",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          leading: CircleAvatar(
                            child: Text("${index + 1}"),
                          ),
                        ),
                      );
                    },
                  ),
            Positioned(
              top: 700,
              right: 40,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      excelTesting.dataList.clear();
                      await excelTesting.readExcelFile(context);
                      setState(() {}); // إعادة بناء الواجهة بعد جلب البيانات
                      // excelTesting.dataList.clear();
                    },
                    child: Text("Read Excel File"),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      var per = await Permission.storage.request();
                      if (per.isGranted) {
                        // PdfExport.generatePdf();
                        excelTesting.createExcelFile(context);
                        print("================================ Here");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم انشاء الاكسل"),
                            duration: Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    child: const Text("Create Excel File"),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 650,
                right: 139,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {},
                    child: Text(
                      "add to local",
                      style: TextStyle(color: Colors.white),
                    )))
          ],
        ),
      ),
    );
  }
}
