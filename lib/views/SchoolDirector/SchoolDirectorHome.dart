import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddHalaga.dart';
import 'package:al_furqan/views/SchoolDirector/DrawerSchoolDirector.dart';
import 'package:al_furqan/views/SchoolDirector/ElhalagatList.dart';
import 'package:al_furqan/views/SchoolDirector/add_teacher.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_list.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_management.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';

class SchoolManagerScreen extends StatefulWidget {
  const SchoolManagerScreen({super.key});

  @override
  State<SchoolManagerScreen> createState() => _SchoolManagerScreenState();
}

class _SchoolManagerScreenState extends State<SchoolManagerScreen>
    with UserDataMixin, WidgetsBindingObserver {
  final teachers = teacherController.teachers;
  // final students = studentController.students;
  List<HalagaModel> _halaqatList = [];
  bool _isLoading = true;
  int _teacherCount = 0;
  int _studentCount = 0;
  int _halqatCount = 0;
  int _unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    // إضافة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.addObserver(this);

    initializeDateFormatting('ar', null).then((_) {
      _loadData();
    });
    loadMessages();
  }

  @override
  void dispose() {
    // إزالة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // تحديث عدد الإشعارات عند العودة للتطبيق
    if (state == AppLifecycleState.resumed) {
      updateNotificationCount();
    }
  }

  // تحميل الرسائل
  Future<void> loadMessages() async {
    // تحديث عدد الإشعارات
    await updateNotificationCount();
  }

  // تحديث عدد الإشعارات
  Future<void> updateNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    String? Id = prefs.getString('user_id');
    if (Id != null) {
      print("User ID ==============> $Id");
      _unreadMessagesCount = await messageController.getUnreadMessagesCount(Id);
      setState(() {}); // تحديث واجهة المستخدم
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      await fetchUserData();
      await _fetchCounts();
      // No longer calling _generateRecentActivities() as it's not needed
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchCounts() async {
    try {
      if (user != null && user!.schoolID != null) {
        List<StudentModel> studentsList =
            await studentController.getSchoolStudents(user!.schoolID!);
        _studentCount = studentsList.length;

        _teacherCount = teachers.length;

        _halaqatList = await halagaController.getData(user!.schoolID!);
        _halqatCount = _halaqatList.length;
      }
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  // Method removed as it's no longer needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: isLoading || user == null
            ? Text("جاري التحميل...",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            : Text(
                '${user!.first_name} ${user!.last_name}',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            onPressed: () {
              _loadData();
              halagaController.getHalagatFromFirebase();
              updateNotificationCount(); // تحديث عدد الإشعارات عند الضغط على زر التحديث
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: user == null ? null : DrawerSchoolDirector(user: user),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "جاري تحميل البيانات...",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        "فشل في جلب بيانات المستخدم",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        _buildWelcomeSection(),
                        SizedBox(height: 16),

                        // Stats overview
                        _buildStatisticsSection(),
                        SizedBox(height: 24),

                        // Distribution chart
                        _buildDistributionChart(),
                        SizedBox(height: 24),

                        // Recent activity
                        _buildRecentActivitySection(),
                        SizedBox(height: 24),

                        // Teachers list
                        _buildTeachersSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = "صباح الخير";
    } else if (now.hour < 18) {
      greeting = "مساء الخير";
    } else {
      greeting = "مساء الخير";
    }

    // Format date with proper Arabic locale
    final dateFormatter = DateFormat.yMMMd('ar');
    final dayFormatter = DateFormat.EEEE('ar');

    String formattedDate = dateFormatter.format(now);
    String dayName = dayFormatter.format(now);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(
                Icons.person,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting، ${user?.first_name ?? 'مدير المدرسة'}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "لديك $_unreadMessagesCount رسائل جديدة",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: Text(
            "إحصائيات المدرسة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'المعلمين',
                '$_teacherCount',
                Icons.person,
                Colors.blue.shade700,
                Colors.blue.shade100,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'الطلاب',
                '$_studentCount',
                Icons.school,
                Colors.green.shade700,
                Colors.green.shade100,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'الحلقات',
                '$_halqatCount',
                Icons.menu_book,
                Colors.purple.shade700,
                Colors.purple.shade100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistributionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "توزيع الطلاب والمعلمين",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: _studentCount > 0 || _teacherCount > 0
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _studentCount > 0 ? _studentCount * 1.2 : 10,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text = '';
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'المعلمين';
                                    break;
                                  case 1:
                                    text = 'الطلاب';
                                    break;
                                  case 2:
                                    text = 'الحلقات';
                                    break;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) {
                                  return const SizedBox();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: _teacherCount.toDouble(),
                                color: Colors.blue.shade700,
                                width: 25,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: _studentCount.toDouble(),
                                color: Colors.green.shade700,
                                width: 25,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: _halqatCount.toDouble(),
                                color: Colors.purple.shade700,
                                width: 25,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        "لا توجد بيانات كافية لعرض الرسم البياني",
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "قائمة الحلقات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to full halaqat list
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HalqatListPage()));
              },
              icon: Icon(Icons.menu_book, size: 18),
              label: Text("عرض الكل"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: _halaqatList.isEmpty
                ? SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined,
                              size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "لا توجد حلقات متاحة",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to add halaqat
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddHalaqaScreen()));
                            },
                            icon: Icon(Icons.add),
                            label: Text("إضافة حلقة"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:
                        _halaqatList.length > 3 ? 3 : _halaqatList.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: Icon(Icons.menu_book,
                              color: Colors.purple.shade700),
                        ),
                        title: Text(
                          _halaqatList[index].Name ?? 'حلقة بدون اسم',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                            'عدد الطلاب: ${_halaqatList[index].NumberStudent ?? 0}'),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     IconButton(
                        //       icon: Icon(Icons.info, color: Colors.blue),
                        //       onPressed: () {
                        //         // عرض تفاصيل الحلقة
                        //       },
                        //     ),
                        //     IconButton(
                        //       icon: Icon(Icons.edit, color: Colors.orange),
                        //       onPressed: () {
                        //         // تعديل بيانات الحلقة
                        //       },
                        //     ),
                        //   ],
                        // ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "قائمة المعلمين",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to full teachers list
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TeacherManagement()));
              },
              icon: Icon(Icons.people, size: 18),
              label: Text("عرض الكل"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: teachers.isEmpty
                ? SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "لا يوجد معلمين متاحين",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to add teacher
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddTeacher()));
                            },
                            icon: Icon(Icons.add),
                            label: Text("إضافة معلم"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: teachers.length > 3 ? 3 : teachers.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child:
                              Icon(Icons.person, color: Colors.blue.shade700),
                        ),
                        title: Text(
                          "${teachers[index].first_name ?? ''} ${teachers[index].middle_name ?? ''} ${teachers[index].last_name ?? ''}"
                              .trim(),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        // subtitle: Text('المدرس - حلقة ${index + 1}'),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     IconButton(
                        //       icon: Icon(Icons.info, color: Colors.blue),
                        //       onPressed: () {
                        //         // عرض تفاصيل المعلم
                        //       },
                        //     ),
                        //     IconButton(
                        //       icon: Icon(Icons.edit, color: Colors.orange),
                        //       onPressed: () {
                        //         // تعديل بيانات المعلم
                        //       },
                        //     ),
                        //   ],
                        // ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, Color bgColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: bgColor,
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Method removed as it's no longer used
}
