import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddStuden.dart';
import 'package:al_furqan/views/SchoolDirector/updateStudent.dart';
import 'package:flutter/material.dart';
// import 'package:al_furqan/views/Teacher/StudentDataPage.dart';

class StudentsListPage extends StatefulWidget {
  final UserModel? user;
  StudentsListPage({super.key, this.user});

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
  Future<void> _loadStudent() async {
    final int? schoolID = widget.user?.schoolID;

    if (schoolID == null) {
      print("schoolID is null");
      if (mounted) {
        setState(() => students = []);
      }
      return;
    }

    try {
      final List<StudentModel> loadedStudents =
          await studentController.getSchoolStudents(schoolID) ?? [];
      if (mounted) {
        setState(() {
          students = loadedStudents;
          print("Loaded students: ${students.length}");
        });
      }
    } catch (e) {
      print("Error loading students: $e");
      if (mounted) {
        setState(() => students = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب الطلاب: $e')),
        );
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            "${student.firstName!} ${student.middleName} ${student.lastName}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "اسم الحلقة اللي هو فيها",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                              onPressed: () async {
                                print("${student.studentID}");
                                await studentController
                                    .delete(student.studentID!);
                                await _loadStudent();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("delelted!"),
                                  duration: Duration(milliseconds: 10),
                                ));
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.redAccent),
                          onTap: () {
                            print(student.grandfatherName);
                            print(student.lastName);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditStudentScreen(student: student),
                              ),
                            );
                          },
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
          ).then((_) => _loadStudent());
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
