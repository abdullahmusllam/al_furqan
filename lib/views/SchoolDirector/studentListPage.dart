import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/AddStuden.dart';
import 'package:al_furqan/views/SchoolDirector/updateStudent.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class StudentsListPage extends StatefulWidget {
  final UserModel? user;
  StudentsListPage({super.key, required this.user});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  List<StudentModel> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudent(); // استدعاء دالة جلب الطلاب عند تهيئة الصفحة
  }

//  Future<void> _loadStudent() async {
//   int? schoolID = widget.user?.schoolID;

//   if (schoolID != null) {
//     try {
//       // 1. التحقق من الاتصال بالإنترنت
//       var connectivityResult = await Connectivity().checkConnectivity();

//       if (connectivityResult != ConnectivityResult.none) {
//         // يوجد اتصال بالإنترنت - جلب البيانات من Firebase
//         List<Map<String, dynamic>?> rawData =
//             await firebasehelper.getPrivateData('students', schoolID, 'schoolId');

//         // تحويل البيانات إلى قائمة من StudentModel
//         List<StudentModel> studentsData = rawData
//             .where((e) => e != null)
//             .map((e) => StudentModel.fromJson(e!))
//             .toList();

//         // 2. التحقق إذا كانت البيانات موجودة في قاعدة البيانات المحلية لكل طالب
//         for (var student in studentsData) {
//           // تحقق إذا كان الطالب موجودًا في القاعدة المحلية باستخدام studentID
//           bool exists = await sqlDb.checkIfitemExists('Students', student.studentID!);

//           if (exists) {
//             // إذا كان الطالب موجودًا، قم بتحديثه في القاعدة المحلية
//             await studentController.updateStudent(student, student.studentID!);
//             print("تم تحديث بيانات الطالب ${student.firstName}");
//           } else {
//             // إذا لم يكن الطالب موجودًا، قم بإضافته إلى القاعدة المحلية
//             await studentController.addStudentToLocal(student);
//             print("تم إضافة بيانات الطالب ${student.firstName}");
//           }
//         }
//       } else {
//         print("📴 لا يوجد اتصال بالإنترنت، سيتم تحميل البيانات من القاعدة المحلية.");
//       }

//       // 3. تحميل البيانات من قاعدة البيانات المحلية بعد التحديث
//       List<StudentModel>? loadedStudent =
//           await studentController.getSchoolStudents(schoolID);

//       setState(() {
//         students = loadedStudent ?? [];
//       });
//     } catch (e) {
//       print("حدث خطأ أثناء تحميل الطلاب: $e");

//       // محاولة التحميل من القاعدة المحلية في حال حدوث خطأ
//       List<StudentModel>? fallbackStudents =
//           await studentController.getSchoolStudents(schoolID);

//       setState(() {
//         students = fallbackStudents ?? [];
//       });
//     }
//   } else {
//     print("schoolID is null");
//   }
// }

 Future<void> _loadStudent() async {
  int schoolID = widget.user!.schoolID!;

  if (schoolID != null) {
    var connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult != ConnectivityResult.none) {
      // جلب بيانات الطلاب من Firebase
      List<Map<String, dynamic>> studentsList = await firebasehelper.getStudentData(schoolID);

      for (var studentData in studentsList) {
        // تحويل البيانات إلى StudentModel
        StudentModel student = StudentModel.fromJson(studentData);

        // التحقق إذا كان الطالب موجودًا في قاعدة البيانات المحلية
        bool exists = await sqlDb.checkIfitemExists("Students", student.studentID!, 'StudentID');

        if (exists) {
          // إذا كان موجودًا، يتم التحديث
          await studentController.updateStudent(student, student.studentID!);
          print("تم تحديث بيانات الطالب ${student.firstName}");
        } else {
          // إذا لم يكن موجودًا، يتم إضافته
          await studentController.addStudentToLocal(student);
          print("تم إضافة بيانات الطالب ${student.firstName}");
        }
      }

      // تحميل البيانات من القاعدة المحلية
      List<StudentModel>? loadedStudent = await studentController.getSchoolStudents(schoolID);

      setState(() {
        students = loadedStudent ?? [];
      });

    } else {
      // إذا لم يكن هناك اتصال بالإنترنت، يتم تحميل البيانات من القاعدة المحلية فقط
      List<StudentModel>? loadedStudent = await studentController.getSchoolStudents(schoolID);
      setState(() {
        students = loadedStudent ?? [];
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('طلاب المدرسة',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              student.firstName ?? '',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              student.lastName ?? '',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.teal),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditStudentScreen(student: student),
                                ),
                              );
                            },
                          ),
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
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
