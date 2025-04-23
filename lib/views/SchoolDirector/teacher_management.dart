import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_list.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_request.dart';
// import 'package:al_furqan/views/Supervisor/add_teacher.dart';
import 'package:al_furqan/views/Supervisor/requests_list.dart';
import 'package:al_furqan/views/Supervisor/user_list.dart';
import 'package:flutter/material.dart';

class TeacherManagement extends StatefulWidget {
  const TeacherManagement({super.key});

  @override
  State<TeacherManagement> createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    print("TeacherManagement refreshing data...");
    try {
      await teacherController.getTeachers();
      print(
          "TeacherManagement: Teachers fetched - count: ${teacherController.teachers.length}");
    } catch (e) {
      print("TeacherManagement: Error fetching teachers - $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("TeacherManagement: Loading state set to false");
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'إدارة المعلمين',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 1, 117, 70),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'تحديث البيانات',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(
            text: 'المعلمين',
            icon: Icon(Icons.people),
          ),
          Tab(
            text: 'الطلبات',
            icon: Icon(Icons.assignment),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => const AddTeacher()))
        //     .then((_) {
        //   _refreshData();
        // });
      },
      tooltip: 'إضافة معلم جديد',
      icon: const Icon(Icons.add),
      label: const Text('إضافة معلم'),
      backgroundColor: const Color.fromARGB(255, 1, 117, 70),
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 1, 117, 70),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: const [
                TeacherList(),
                TeacherRequest(),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
