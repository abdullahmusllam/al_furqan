import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:flutter/cupertino.dart';

class StudentProvider with ChangeNotifier {
  List<StudentModel> student = [];
  get studentCount => student.length;

  int? schoolID = perf.getInt('schoolId');

  Future<void> loadStudents() async {
    student = await studentController.getSchoolStudents(schoolID!);
    notifyListeners();
  }

  Future<void> loadStudentFromFirebase() async {
    await studentController.addToLocalOfFirebase(schoolID!);
    await loadStudents();
  }
}
