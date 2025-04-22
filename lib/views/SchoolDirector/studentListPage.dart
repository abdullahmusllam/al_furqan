import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/AddStuden.dart';
import 'package:al_furqan/views/SchoolDirector/updateStudent.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class StudentsListPage extends StatefulWidget {
  final UserModel? user;
  StudentsListPage({super.key, this.user});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  final sqlDb = SqlDb();
  final halagaController = HalagaController();
  List<StudentModel> students = [];
  Map<int?, String> halaqaNames = {}; // To store halaqat names by ID

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadHalaqaNames(int schoolID) async {
    try {
      List<HalagaModel> halaqat = await halagaController.getData(schoolID);
      print("تم جلب ${halaqat.length} حلقة من المدرسة $schoolID");

      Map<int?, String> names = {};

      for (var halqa in halaqat) {
        if (halqa.halagaID != null) {
          names[halqa.halagaID] = halqa.Name ?? 'حلقة بدون اسم';
          print("إضافة حلقة: ${halqa.halagaID} -> ${halqa.Name}");
        }
      }

      setState(() {
        halaqaNames = names;
      });

      print("تم تحميل ${halaqaNames.length} حلقة في القاموس");
    } catch (e) {
      print("خطأ في تحميل أسماء الحلقات: $e");
    }
  }

  Future<void> _loadStudent() async {
    print("=== بداية تحميل بيانات الطلاب ===");
    int schoolID = widget.user!.schoolID!;
    print("معرف المدرسة: $schoolID");

    if (schoolID != null) {
      // Load halaqat names first
      print("جاري تحميل أسماء الحلقات...");
      await _loadHalaqaNames(schoolID);

      var connectivityResult = await Connectivity().checkConnectivity();
      print("حالة الاتصال: $connectivityResult");

      if (connectivityResult != ConnectivityResult.none) {
        // جلب بيانات الطلاب من Firebase
        print("جاري جلب بيانات الطلاب من Firebase...");
        List<Map<String, dynamic>> studentsList =
            await firebasehelper.getStudentData(schoolID);
        print("تم جلب ${studentsList.length} طالب من Firebase");
        print("بيانات الطلاب من Firebase: $studentsList");

        for (var studentData in studentsList) {
          // تحويل البيانات إلى StudentModel
          print("جاري معالجة بيانات الطالب: $studentData");
          StudentModel student = StudentModel.fromJson(studentData);
          print(
              "تم تحويل البيانات إلى نموذج الطالب: ${student.firstName}, ID: ${student.studentID}, حلقة: ${student.elhalaqaID}");

          // التحقق إذا كان الطالب موجودًا في قاعدة البيانات المحلية
          if (student.studentID == null) {
            print("تخطي الطالب لأن studentID هو null");
            continue;
          }

          bool exists = await sqlDb.checkIfitemExists(
              "Students", student.studentID!, 'StudentID');
          print("هل الطالب موجود في قاعدة البيانات المحلية؟ $exists");

          if (exists) {
            // إذا كان موجودًا، يتم التحديث
            await studentController.updateStudent(student, student.studentID!);
            print("تم تحديث بيانات الطالب ${student.firstName}");
          } else {
            // إذا لم يكن موجودًا، يتم إضافته
            await studentController.addStudentToLocal(student);
            print(" : تم إضافة بيانات الطالب ${student.firstName}");
          }
        }

        // تحميل البيانات من القاعدة المحلية
        print("جاري تحميل البيانات من قاعدة البيانات المحلية...");
        List<StudentModel>? loadedStudent =
            await studentController.getSchoolStudents(schoolID);
        print(
            "تم تحميل ${loadedStudent?.length ?? 0} طالب من قاعدة البيانات المحلية");

        setState(() {
          students = loadedStudent ?? [];
          print("تم تحديث واجهة المستخدم بـ ${students.length} طالب");
        });
      } else {
        // إذا لم يكن هناك اتصال بالإنترنت، يتم تحميل البيانات من القاعدة المحلية فقط
        print(
            "لا يوجد اتصال بالإنترنت، جاري تحميل البيانات من قاعدة البيانات المحلية فقط...");
        List<StudentModel>? loadedStudent =
            await studentController.getSchoolStudents(schoolID);
        print(
            "تم تحميل ${loadedStudent?.length ?? 0} طالب من قاعدة البيانات المحلية");

        setState(() {
          students = loadedStudent ?? [];
          print("تم تحديث واجهة المستخدم بـ ${students.length} طالب");
        });
      }
    } else {
      print("معرف المدرسة غير متوفر!");
    }
    print("=== انتهاء تحميل بيانات الطلاب ===");
  }

  String getHalaqaName(int? halaqaId) {
    if (halaqaId == null) {
      print("الطالب بدون حلقة (معرف الحلقة: null)");
      return 'بدون حلقة';
    }

    String halaqaName = halaqaNames[halaqaId] ?? 'بدون حلقة';
    print(
        "معرف الحلقة: $halaqaId، اسم الحلقة: $halaqaName، القاموس يحتوي على: ${halaqaNames.keys.toList()}");

    return halaqaName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('طلاب المدرسة',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => _loadStudent(), icon: Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Text('لا يوجد طلاب', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final halaqaName = getHalaqaName(student.elhalaqaID);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text("${index + 1}"),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${student.firstName ?? ''} ${student.lastName ?? ''}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.group,
                                      size: 16, color: Colors.teal),
                                  SizedBox(width: 4),
                                  Text(
                                    "الحلقة: $halaqaName",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: student.elhalaqaID == null
                                          ? Colors.red
                                          : Colors.grey[800],
                                      fontWeight: student.elhalaqaID == null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                              onPressed: () async {},
                              icon: Icon(Icons.delete),
                              color: Colors.redAccent),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditStudentScreen(student: student)),
                            ).then((_) => _loadStudent());
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddStudentScreen(user: widget.user)),
          ).then((_) => _loadStudent());
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
