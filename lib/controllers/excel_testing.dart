import 'dart:io';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/controllers/validation_from_excelfile.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // For dynamic file paths

class ExcelTesting {
  int? schoolID;
  ExcelTesting({required this.schoolID});
  var excel = Excel.createExcel();
  List<Map<String, dynamic>> dataList = []; // قائمة لتخزين البيانات
  bool _isProcessingExcel = false;

  void createExcelFile(BuildContext context) async {
    Sheet _sheet = excel["sheet2"];

    var firstName = _sheet.cell(CellIndex.indexByString('A1'));
    var fatherName = _sheet.cell(CellIndex.indexByString('B1'));
    var grandFathername = _sheet.cell(CellIndex.indexByString('C1'));
    var grandFatheFathername = _sheet.cell(CellIndex.indexByString('D1'));
    var lastName = _sheet.cell(CellIndex.indexByString('E1'));
    var gmail = _sheet.cell(CellIndex.indexByString('F1'));
    var phone = _sheet.cell(CellIndex.indexByString('G1'));
    var telephone = _sheet.cell(CellIndex.indexByString('H1'));

    firstName.value = "الاسم الاول";
    fatherName.value = 'اسم الأب';
    grandFathername.value = 'اسم الجد';
    grandFatheFathername.value = 'اسم جد الأب';
    lastName.value = 'اسم العائلة';
    telephone.value = 'رقم الهاتف';
    phone.value = 'رقم الجوال';
    gmail.value = 'البريد الالكتروني';

    // _sheet.appendRow(data);
    try {
      await saveExcelFile();
    } catch (e) {
      print("the is exit already : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حصل خطأ $e"),
        ),
      );
    }
  }

  saveExcelFile() async {
    var _per = await Permission.storage.request();
    if (_per.isGranted) {
      var _fileByte = excel.save();
      if (_fileByte != null) {
        File(join(
            '/storage/emulated/0/Download/تطبيق الفرقان/اسماء الطلاب.xlsx'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(_fileByte);
        print(
            "Doneeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee!!");
      }
    } else {
      print('Permission Denied!');
    }
  }

  Future<void> readExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم اختيار ملف')),
      );
      return;
    }

    final errors = <Map<String, dynamic>>[];
    final validStudents = <StudentModel>[];
    final validFathers = <UserModel>[];

    try {
      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        // التأكد من أسماء الأعمدة
        final headers =
            sheet.rows[0].map((cell) => cell!.value.toString().trim()).toList();

        // طباعة الأعمدة للتحقق
        print("Headers: $headers");

        for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
          final row = sheet.rows[rowIndex];
          final rowData = <String, dynamic>{};

          // التحقق من عدد الأعمدة
          if (row.length != headers.length) {
            errors.add({
              'row': rowData,
              'errors': {'general': 'عدد الأعمدة غير متطابق'},
              'rowNumber': rowIndex + 1,
            });
            continue;
          }

          // تعبئة rowData
          for (int colIndex = 0; colIndex < headers.length; colIndex++) {
            rowData[headers[colIndex]] =
                row[colIndex]?.value?.toString().trim();
            print("Column ${headers[colIndex]}: ${rowData[headers[colIndex]]}");
          }

          // التحقق من صحة الصف
          final validation = ExcelDataValidator.validateRow(rowData);
          if (!validation['isValid']) {
            errors.add({
              'row': rowData,
              'errors': validation['errors'],
              'rowNumber': rowIndex + 1,
            });
            continue;
          }

          // إنشاء موديلات البيانات الصالحة
          final student = StudentModel(
            firstName: rowData['الاسم الاول']?.toString() ?? '',
            middleName: rowData['اسم الأب']?.toString() ?? '',
            grandfatherName: rowData['اسم الجد']?.toString() ?? '',
            lastName: rowData['اسم العائلة']?.toString() ?? '',
            schoolId: schoolID,
          );

          final father = UserModel(
            first_name: rowData['اسم الأب']?.toString() ?? '',
            middle_name: rowData['اسم الجد']?.toString() ?? '',
            grandfather_name: rowData['اسم جد الأب']?.toString() ?? '',
            last_name: rowData['اسم العائلة']?.toString() ?? '',
            email: validation['validated']['email'],
            phone_number: validation['validated']['phone'],
            telephone_number: validation['validated']['telephone'],
            password: '12345678',
            roleID: 3,
            isActivate: 0,
          );

          validStudents.add(student);
          validFathers.add(father);
        }
      }

      // إدخال البيانات الصالحة إلى قاعدة البيانات
      await _insertValidData(context, validStudents, validFathers);

      // عرض الأخطاء إذا وجدت
      if (errors.isNotEmpty) {
        _showValidationErrors(context, errors);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
      print("-------------the error is $e");
    }
  }

// دالة لعرض الأخطاء
  void _showValidationErrors(
      BuildContext context, List<Map<String, dynamic>> errors) {
    final message = errors.map((error) {
      return '➊ الصف ${error['rowNumber']}\n'
          '➋ الأخطاء: ${(error['errors'] as Map).entries.join(', ')}';
    }).join('\n\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أخطاء في البيانات'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

// إدخال البيانات الصالحة
//   Future<void> _insertValidData(
//     BuildContext context,
//     List<StudentModel> students,
//     List<UserModel> fathers,
//   ) async {
//     bool isExist;
//     await fathersController.getFathersStudents(schoolID!);
//     for (int i = 0; i < students.length; i++) {
//       print("------------- i = $i");
//       try {
//         for (int f = 0; f < fathersController.fathers.length; f++) {
//           print("------------- f = $f");
//           int fatherID = fathersController.fathers[f].user_id!;
//           isExist =
//               await SqlDb().checkIfitemExists("Users", fatherID, "user_id");
//           if (isExist) {
//             for (int s = 0; s < studentController.students.length; s++) {
//               print("------------- s = $s");
//               isExist = await SqlDb().checkIfitemExists("Students",
//                   studentController.students[s].studentID!, "StudentID");
//               if (isExist) {
//                 // throw Exception(
//                 //     "the student is exist ${studentController.students[s].studentID}, s : $s");
//                 print(
//                     "the student is exist ${studentController.students[s].firstName}, s : $s,");
//                 continue;
//               } else {
//                 print("is not exist: $isExist");
//                 students[i].userID = fatherID;
//                 await studentController.addStudent(students[i]);
//                 print("ID : ${studentController.students.last.studentID}");
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('تم إدخال ${students.length} طالب بنجاح'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               }
//             }
//           } else {
//             print("father is not exist");
//             final fatherId = await fathersController.addFather(fathers[i]);
//             students[i].userID = fatherId;
//             await studentController.addStudent(students[i]);
//             print("ID : ${studentController.students.last.studentID}");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('تم إدخال ${students.length} طالب بنجاح'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text('فشل إدخال البيانات: $e')),
//         // );
//         print("-------- Error : $e");
//       }
//     }
//   }
  Future<void> _insertValidData(
    BuildContext context,
    List<StudentModel> students,
      List<UserModel>fathers
  ) async {
    int successfulInserts = 0;

    for (int i = 0; i < students.length; i++) {
      // تنظيف الأسماء
      String firstName = students[i].firstName?.trim() ?? '';
      String lastName = students[i].lastName?.trim() ?? '';

      // التحقق من وجود الطالب
      bool studentExists = await SqlDb().checkIfitemExistsForExcel("Students", {
        "firstName": firstName,
        "lastName": lastName,
      });
      print("Student $firstName $lastName exists: $studentExists");

      if (!studentExists) {
        // إضافة الطالب إذا لم يكن موجودًا
        final studentId = await studentController.addStudent(students[i]);
        print("Added student with ID: $studentId");
        successfulInserts++;
      } else {
        print("Student $firstName $lastName already exists, skipping...");
      }
    }

    // عرض رسالة النجاح
    if (successfulInserts > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إدخال $successfulInserts طالب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ExcelTesting excelTesting = ExcelTesting();
