import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/views/SchoolDirector/EditHalaga.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/views/SchoolDirector/add_students_to_halqa_screen.dart';

class HalqaDetailsPage extends StatefulWidget {
  final HalagaModel halqa;
  const HalqaDetailsPage({super.key, required this.halqa});

  @override
  _HalqaDetailsPageState createState() => _HalqaDetailsPageState();
}

class _HalqaDetailsPageState extends State<HalqaDetailsPage> {
  List<StudentModel> students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final int? halagaID = widget.halqa.halagaID;
    if (halagaID == null) {
      print("halagaID is null");
      if (mounted) {
        setState(() => students = []);
      }
      return;
    }

    try {
      if (mounted) setState(() => _isLoading = true);
      final loadedStudents =
          await studentController.getStudents(halagaID) ?? [];
      if (mounted) {
        setState(() {
          students = loadedStudents;
          _isLoading = false;
          print("Loaded students: ${students.length}");
        });
      }
    } catch (e) {
      print("Error loading students: $e");
      if (mounted) {
        setState(() {
          students = [];
          _isLoading = false;
        });
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
        backgroundColor: Colors.teal,
        title: const Text(
          'تفاصيل الحلقة',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHalagaScreen(halga: widget.halqa),
                ),
              ).then((_) => _loadStudents());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.school, color: Colors.white),
              ),
              title: Text(
                widget.halqa.Name ?? 'اسم الحلقة غير متوفر',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تفاصيل الحلقة:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'اسم المعلم: ${widget.halqa.TeacherName ?? 'غير متوفر'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              'عدد الطلاب: ${widget.halqa.NumberStudent ?? 0}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddStudentsToHalqaScreen(
                                    halqaID: widget.halqa.halagaID,
                                    schoolID: widget.halqa
                                        .SchoolID, // افتراض أن HalagaModel يحتوي على schoolId
                                  ),
                                ),
                              ).then((_) => _loadStudents());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'إضافة طلاب إلى الحلقة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return ListTile(
                              title: Text(
                                '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}'
                                    .trim(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: const Icon(Icons.person),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
