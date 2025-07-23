import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import '../../controllers/fathers_controller.dart';
import '../halaga_model.dart';

class StudentProvider with ChangeNotifier {
  List<StudentModel> students = [];
  List<UserModel> fathers = [];
  Map<String?, String> halaqaNames = {}; // أسماء الحلقات حسب ID
  List<HalagaModel> halaqat = [];

  get studentCount => students.length;

  int? schoolID = perf.getInt('schoolId');

  StudentProvider() {
    loadStudents();
  }

  Future<void> loadStudentFromFirebase() async {
    await studentController.addToLocalOfFirebase(schoolID!);
    await loadStudents();
  }

  Future<void> loadStudents() async {
    debugPrint("=== بداية تحميل بيانات الطلاب ===");
    debugPrint("معرف المدرسة: $schoolID");

    // تفريغ القوائم قبل تحميل بيانات جديدة
    students.clear();
    fathers.clear();
    halaqaNames.clear();
    halaqat.clear();

    await _loadHalaqaNames(schoolID!);

    debugPrint("جاري تحميل البيانات من قاعدة البيانات المحلية...");
    List<StudentModel>? loadedStudent =
        await studentController.getSchoolStudents(schoolID!);

    debugPrint(
        "تم تحميل ${loadedStudent.length} طالب من قاعدة البيانات المحلية");

    students = loadedStudent;

    debugPrint("تم تحديث واجهة المستخدم بـ ${students.length} طالب");

    await _loadFathersStudents();

    debugPrint("=== انتهاء تحميل بيانات الطلاب ===");

    notifyListeners();
  }

  Future<void> _loadHalaqaNames(int schoolID) async {
    try {
      halaqat = await halagaController.getData(schoolID);
      debugPrint("تم جلب ${halaqat.length} حلقة من المدرسة $schoolID");

      Map<String?, String> names = {};
      for (var halqa in halaqat) {
        if (halqa.halagaID != null) {
          names[halqa.halagaID] = halqa.Name ?? 'حلقة بدون اسم';
          debugPrint("إضافة حلقة: ${halqa.halagaID} -> ${halqa.Name}");
        }
      }
      halaqaNames = names;
      print(halaqaNames);
      debugPrint("تم تحميل ${halaqaNames.length} حلقة في القاموس");
    } catch (e) {
      debugPrint("خطأ في تحميل أسماء الحلقات: $e");
    }
  }

  Future<void> _loadFathersStudents() async {
    List<UserModel> temp = [];
    debugPrint("==> بداية تحميل آباء الطلاب <==");

    for (var i = 0; i < students.length; i++) {
      if (students[i].userID != null) {
        final dad = await fathersController.getFatherByID(students[i].userID!);
        temp.add(dad);
      } else {
        debugPrint("لا يوجد userID للطالب ${students[i].studentID}");
        temp.add(UserModel()); // إضافة عنصر فارغ لتفادي الفجوة في الفهرسة
      }
    }

    fathers = temp;
  }
}
