import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/schools_model.dart';

class ShowAllTeacher extends StatefulWidget {
  const ShowAllTeacher({super.key});

  @override
  State<ShowAllTeacher> createState() => _ShowAllTeacherState();
}

class _ShowAllTeacherState extends State<ShowAllTeacher> {
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Function to fetch teachers and schools data
  void _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await teacherController.getTeachers();
      await schoolController.get_data();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب البيانات: $e')),
      );
    }
  }

  // Filter teachers based on search query
  List<UserModel> _filterTeachers() {
    if (_searchQuery.isEmpty) return teacherController.teachers;
    return teacherController.teachers.where((teacher) {
      final fullName =
          '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
              .toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Find school name by schoolID
  String _getSchoolName(int? schoolID) {
    if (schoolID == null) return 'غير معروف';
    final school = schoolController.schools.firstWhere(
      (school) => school.schoolID == schoolID,
      orElse: () => SchoolModel(schoolID: -1, school_name: 'غير معروف'),
    );
    return school.school_name ?? 'غير معروف';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = _filterTeachers();

    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          "المدارس",
          style: TextStyle(fontFamily: 'RB'),
        ),
        backgroundColor: CupertinoColors.activeGreen.withOpacity(0.5),
        automaticBackgroundVisibility: false,
        enableBackgroundFilterBlur: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: 'بحث',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTeachers.isEmpty
                    ? const Center(child: Text('لا يوجد معلمين'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = filteredTeachers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).primaryColorLight,
                              child: Text(
                                '${index + 1}',
                              ),
                            ),
                            title: Text(
                              '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(_getSchoolName(teacher.schoolID)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
