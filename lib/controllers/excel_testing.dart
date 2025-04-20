import 'dart:io';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
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
  // int? schoolID;
  // ExcelTesting({required this.schoolID});
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

  readExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx', 'xls', 'csv']);
    var respone;
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
      _isProcessingExcel = false; // تحديث حالة المعالجة
      return;
    }

    String? fileName = result.files.first.name; // اسم الملف
    if (fileName == null ||
        (!fileName.endsWith('.xlsx') &&
            !fileName.endsWith('.xls') &&
            !fileName.endsWith('.csv'))) {
      // التحقق من نوع الملف
      // إظهار رسالة خطأ إذا كان الملف ليس من نوع Excel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الملف المختار ليس ملف Excel (.xlsx أو .xls)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      _isProcessingExcel = false;
      return;
    }

    /// here started Read file excel
    if (result != null) {
      File file = File(result.files.single.path!);
      print("Selected Path $file");
      var byte = file.readAsBytesSync();
      var excelRead = Excel.decodeBytes(byte);

      List<String> headers = []; // قائمة لحفظ أسماء الأعمدة

      for (var table in excelRead.tables.keys) {
        int i = 1;
        var sheet = excelRead.tables[table];
        if (sheet != null) {
          int rowIndex = 0;
          try {
            for (var row in sheet.rows) {
              if (rowIndex == 0) {
                // حفظ أسماء الأعمدة من أول صف
                headers =
                    row.map((cell) => cell?.value.toString() ?? "").toList();
              } else {
                // إنشاء ماب لكل صف بناءً على أسماء الأعمدة
                Map<String, dynamic> rowData = {};
                for (int colIndex = 0; colIndex < row.length; colIndex++) {
                  rowData[headers[colIndex]] = row[colIndex]?.value;
                }
                dataList.add(rowData);

                if (rowData.isEmpty) {
                  // إظهار رسالة خطأ إذا كان الصف فارغًا
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('الصف $rowIndex فارغ ولا يحتوي على بيانات'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _isProcessingExcel = false; // تحديث حالة المعالجة
                }

                /// Stednt Data
                StudentModel student = StudentModel(
                  firstName: rowData[headers[0]],
                  middleName: rowData[headers[1]],
                  grandfatherName: rowData[headers[2]],
                  lastName: rowData[headers[4]],
                );

                /// Father Data
                UserModel father = UserModel(
                  first_name: rowData[headers[1]],
                  middle_name: rowData[headers[2]],
                  grandfather_name: rowData[headers[3]],
                  last_name: rowData[headers[4]],
                  email: rowData[headers[5]],
                  phone_number: int.tryParse(rowData[headers[6]].toString()),
                  telephone_number:
                      int.tryParse(rowData[headers[7]].toString()),
                  password: 12345678,
                  roleID: 3,
                  isActivate: 0,
                );

                // التحقق من صحة البيانات
                if (student.studentID == null ||
                    student.firstName == null ||
                    student.lastName == null ||
                    father.first_name == null ||
                    father.last_name == null ||
                    father.email == null) {
                  print(
                      "Skipping invalid row-----------------------------------------------------------");
                  // continue;
                }

                // إضافة الأب
                father.user_id =
                    await fathersController.addFather(father).then((_) {
                  print(
                      "------------------------------here added father${father.user_id}----------------------------------");
                });
                student.userID = father.user_id;

                // إضافة الطالب
                print(
                    "student.userID = father.user_id ::::: ${student.userID},${father.user_id}");
                await studentController.addStudent(student);
                // dataAdded = true;
                print(
                    "=======Added student: ${student.firstName}, Father: ${father.user_id}");
              }
              rowIndex++;
            }
          } catch (e) {
            print("=======================================================$e");
            print("Error processing row: $rowIndex, Error: $e");
          }
        }
      }
    }
    return respone;
  }
}

ExcelTesting excelTesting = ExcelTesting();
