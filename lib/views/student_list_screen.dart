import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../service/fierbase_service.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({Key? key}) : super(key: key);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> _students = [];
  bool _isLoading = true;
  Map<int?, String> _schoolNames = {};
  Map<int?, String> _halagaNames = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  // تحميل بيانات الطلاب المرتبطين بولي الأمر
  Future<void> _loadStudents() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // الحصول على معرف ولي الأمر من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        // استخدام معرف ولي الأمر لجلب بيانات الطلاب المرتبطين به
        final students = await firestoreService.getStudentsByParentId(userId);
        
        // جلب أسماء المدارس والحلقات
        Map<int?, String> schoolNames = {};
        Map<int?, String> halagaNames = {};
        
        for (var student in students) {
          if (student.schoolID != null && !schoolNames.containsKey(student.schoolID)) {
            schoolNames[student.schoolID] = await firestoreService.getSchoolName(student.schoolID);
          }
          
          if (student.elhalagatID != null && !halagaNames.containsKey(student.elhalagatID)) {
            halagaNames[student.elhalagatID] = await firestoreService.getHalagaName(student.elhalagatID);
          }
        }
        
        if (mounted) {
          setState(() {
            _students = students;
            _schoolNames = schoolNames;
            _halagaNames = halagaNames;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('خطأ في تحميل بيانات الطلاب: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأبناء', style: TextStyle(fontFamily: 'RB', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF017546),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFE8F5F0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F0), Colors.white],
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF017546))))
          : _students.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_rounded, size: 80, color: Colors.amber.shade700),
                        const SizedBox(height: 24),
                        const Text(
                          'لا يوجد طلاب مرتبطين بحسابك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RB',
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'يرجى التواصل مع إدارة المدرسة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'RB',
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadStudents,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF017546),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'RB', fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          // الانتقال إلى صفحة تفاصيل الطالب
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailsScreen(
                                student: student,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Colors.white,
                                Color(0xFFE8F5F0),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF017546).withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Color(0xFF017546),
                                    child: Text(
                                      student.firstName.isNotEmpty ? student.firstName.substring(0, 1) : '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        fontFamily: 'RB',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          fontFamily: 'RB',
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Color(0xFFE8F5F0)),
                                        ),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.school, size: 16, color: Color(0xFF017546)),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${_schoolNames[student.schoolID] ?? "غير محدد"}',
                                                style: TextStyle(fontFamily: 'RB', color: Colors.grey.shade700, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Color(0xFFE8F5F0)),
                                        ),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.book, size: 16, color: Color(0xFF017546)),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${_halagaNames[student.elhalagatID] ?? "غير محدد"}',
                                                style: TextStyle(fontFamily: 'RB', color: Colors.grey.shade700, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE8F5F0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF017546)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
