import 'package:al_furqan/views/Teacher/HalagaPlansScreen.dart';
import 'package:al_furqan/views/Teacher/student_plan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/StudentPlansController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/student_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/controllers/HalagaController.dart';

class StudentPlansListScreen extends StatefulWidget {
  final int halagaId;
  final String halagaName;

  const StudentPlansListScreen({
    Key? key,
    required this.halagaId,
    required this.halagaName,
  }) : super(key: key);

  @override
  _StudentPlansListScreenState createState() => _StudentPlansListScreenState();
}

class _StudentPlansListScreenState extends State<StudentPlansListScreen> {
  List<StudentModel> students = [];
  Map<int, StudentPlanModel?> studentsPlans = {};
  bool isLoading = true;
  String? errorMessage;
  HalagaModel? halagaData;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadHalagaData();
  }

  Future<void> _loadHalagaData() async {
    try {
      // جلب بيانات الحلقة
      HalagaModel? halaga =
          await halagaController.getHalqaDetails(widget.halagaId);

      if (mounted) {
        setState(() {
          halagaData = halaga;
        });
      }
    } catch (e) {
      print("خطأ في جلب بيانات الحلقة: $e");
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // إنشاء جدول خطط الطلاب إذا لم يكن موجوداً
      await studentPlansController.createTableIfNotExists();

      // جلب قائمة الطلاب في الحلقة
      students = await studentController.getStudents(widget.halagaId);

      // جلب خطط الطلاب
      for (var student in students) {
        if (student.studentID != null) {
          StudentPlanModel? plan =
              await studentPlansController.getStudentPlan(student.studentID!);
          studentsPlans[student.studentID!] = plan;
        }
      }
    } catch (e) {
      errorMessage = "حدث خطأ أثناء تحميل البيانات: $e";
      print(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطط طلاب حلقة ${widget.halagaName}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 50, color: Colors.red),
                      SizedBox(height: 16),
                      Text(errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'لا يوجد طلاب في هذه الحلقة',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: students.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final fullName =
                              '${student.firstName} ${student.middleName} ${student.lastName}';
                          final plan = student.studentID != null
                              ? studentsPlans[student.studentID]
                              : null;

                          double conservationProgress =
                              plan?.conservationCompletionRate ?? 0;
                          double recitationProgress =
                              plan?.recitationCompletionRate ?? 0;

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentPlanDetailScreen(
                                      studentId: student.studentID!,
                                      studentName: fullName,
                                      halagaId: widget.halagaId,
                                      plan: plan,
                                    ),
                                  ),
                                ).then((_) => _loadData());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          child: Text(
                                            fullName.characters.first,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fullName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                plan == null
                                                    ? 'لم يتم إنشاء خطة بعد'
                                                    : 'آخر تحديث: ${plan.lastUpdated ?? "غير معروف"}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 16, color: Colors.grey),
                                      ],
                                    ),
                                    if (plan != null) ...[
                                      SizedBox(height: 16),
                                      _buildProgressSection(
                                          context,
                                          'الحفظ',
                                          conservationProgress,
                                          'من ${plan.conservationStartSurah ?? ""} إلى ${plan.conservationEndSurah ?? ""}'),
                                      SizedBox(height: 12),
                                      _buildProgressSection(
                                          context,
                                          'التلاوة',
                                          recitationProgress,
                                          'من ${plan.recitationStartSurah ?? ""} إلى ${plan.recitationEndSurah ?? ""}'),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // التحقق من وجود بيانات الحلقة
          if (halagaData == null) {
            // محاولة تحميل بيانات الحلقة إذا كانت غير متوفرة
            await _loadHalagaData();

            // التحقق مرة أخرى بعد محاولة التحميل
            if (halagaData == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'جاري تحميل بيانات الحلقة، يرجى المحاولة مرة أخرى')),
              );
              return;
            }
          }

          // الانتقال إلى شاشة خطط الحلقة
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalagaPlansScreen(
                halaga: halagaData!,
              ),
            ),
          ).then((value) {
            // إعادة تحميل البيانات عند العودة
            if (value == true) {
              _loadData();
              _loadHalagaData();
            }
          });
        },
        child: Icon(Icons.add),
        tooltip: 'إنشاء خطة جماعية',
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context, String title, double progress, String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: progress >= 80
                    ? Colors.green
                    : progress >= 50
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 80
                ? Colors.green
                : progress >= 50
                    ? Colors.orange
                    : Colors.red,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        SizedBox(height: 4),
        Text(
          details,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
