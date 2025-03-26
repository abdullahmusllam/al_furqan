import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddStuden.dart';
import 'package:al_furqan/views/SchoolDirector/updateStudent.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Teacher/StudentDataPage.dart';

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

  // دالة لجلب الطلاب من قاعدة البيانات
  void _loadStudent() async {
    int? schoolID = widget.user?.schoolID;

    if (schoolID != null) {
      // التأكد من أن القيمة التي تُرجعها getSchoolStudents ليست null
      List<StudentModel>? loadedStudent =
          await studentController.getSchoolStudents(schoolID);

      setState(() {
        if (loadedStudent != null && loadedStudent.isNotEmpty) {
          students = loadedStudent;
          print(students);
        } else {
          // عرض رسالة توضيحية عندما تكون القائمة فارغة أو null
          students = [];
          print("لا يوجد طلاب");
        }
      });
    } else {
      print("schoolID is null");
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
                    child: Text(
                      'لا يوجد طلاب',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
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
                              student.firstName!,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              student.lastName!,
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
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.red,
          //         padding: EdgeInsets.symmetric(vertical: 16),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //       ),
          //       child: Text(
          //         'إلغاء',
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // هنا يمكنك تنفيذ عملية الإضافة مثل الانتقال لصفحة إضافة طالب جديد
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
