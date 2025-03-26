import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/views/SchoolDirector/EditHalaga.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';

// صفحة تفاصيل الحلقة الدراسية
class HalqaDetailsPage extends StatefulWidget {
  final HalagaModel halqa; // بيانات الحلقة التي سيتم عرضها
  HalqaDetailsPage({required this.halqa});

  @override
  _HalqaDetailsPageState createState() => _HalqaDetailsPageState();
}

class _HalqaDetailsPageState extends State<HalqaDetailsPage> {
  List<StudentModel> students = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadeStudent();
  }

  void _loadeStudent() async {
    int? halagaID = widget.halqa.halagaID;

    if (halagaID != null) {
      List<StudentModel> loadeStudent =
          await studentController.getStudents(halagaID);

      setState(() {
        if (loadeStudent.isNotEmpty) {
          students = loadeStudent;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('تفاصيل الحلقة',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // الانتقال إلى صفحة تعديل بيانات الحلقة
              Navigator.push(context, MaterialPageRoute(builder: (context)=> EditHalagaScreen(halga: widget.halqa)));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  title: Text(
                    widget.halqa.Name ?? 'اسم الحلقة غير متوفر',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'تفاصيل الحلقة:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'اسم المعلم: ${widget.halqa.TeacherName ?? 'غير متوفر'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Text(
                  'عدد الطلاب: ${widget.halqa.NumberStudent}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: students.isEmpty
                      ? Center(
                          child: Text(
                            'لا يوجد طلاب في هذه الحلقة.',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return ListTile(
                              title: Text(
                                  '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}'
                                      .trim()),
                              // subtitle: Text('الصف: ${student.grade}'),
                              trailing: Icon(Icons.person),
                            );
                          },
                        ),
                )

                // SizedBox(height: 10),
                // يمكن إضافة المزيد من التفاصيل هنا حسب الحاجة
              ],
            ),
          ),
        ),
      ),
    );
  }
}
