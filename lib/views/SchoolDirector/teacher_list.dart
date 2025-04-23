import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';

class TeacherList extends StatefulWidget {
  const TeacherList({super.key});

  @override
  State<TeacherList> createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> with UserDataMixin {
  String _searchQuery = '';
  List<UserModel> _filteredTeachers = [];
  bool _isSearching = false;
  bool _isRefreshing = false; // Local loading state for refresh operations
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTeachers();
  }

  Future<void> _initializeTeachers() async {
    print("TeacherList: _initializeTeachers started");
    await fetchUserData();

    // If UserDataMixin didn't load teachers properly, load them directly
    if (teacherController.teachers.isEmpty && schoolID != null) {
      print(
          "TeacherList: No teachers found after mixin initialization, fetching directly");
      await _directFetchTeachers();
    } else {
      print(
          "TeacherList: ${teacherController.teachers.length} teachers found after mixin initialization");
      _updateFilteredTeachers();
    }

    _hasInitialized = true;
    setState(() {});
    print("TeacherList: _initializeTeachers completed");
  }

  // Direct fetch method that doesn't rely on the mixin
  Future<void> _directFetchTeachers() async {
    if (schoolID == null) {
      print("TeacherList: _directFetchTeachers - schoolID is null");
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    print("TeacherList: Directly fetching teachers for schoolID: $schoolID");
    try {
      await teacherController.getTeachersBySchoolID(schoolID!);
      _updateFilteredTeachers();
      print(
          "TeacherList: Direct fetch complete, found ${_filteredTeachers.length} teachers");
    } catch (e) {
      print("TeacherList: Error in direct fetch - $e");
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _updateFilteredTeachers() {
    if (_searchQuery.isEmpty) {
      _filteredTeachers = List.from(teacherController.teachers);
    } else {
      _filteredTeachers = teacherController.teachers.where((teacher) {
        final fullName =
            '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
                .toLowerCase();
        return fullName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    // Debug print
    print("Filtered teachers updated - count: ${_filteredTeachers.length}");
    setState(() {});
  }

  Future<void> _refreshTeachers() async {
    if (schoolID != null) {
      print("Refreshing teachers for schoolID: $schoolID");
      setState(() {
        _isRefreshing = true;
      });

      try {
        await teacherController.getTeachersBySchoolID(schoolID!);
        print(
            "Teachers refreshed - count: ${teacherController.teachers.length}");
        _updateFilteredTeachers();
      } catch (e) {
        print("Error refreshing teachers: $e");
      } finally {
        setState(() {
          _isRefreshing = false;
        });
      }
    } else {
      print("Cannot refresh - schoolID is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug prints
    print(
        "TeacherList build - isLoading: $isLoading, _isRefreshing: $_isRefreshing");
    print(
        "TeacherList build - _filteredTeachers count: ${_filteredTeachers.length}");

    if (!_hasInitialized &&
        !isLoading &&
        !_isRefreshing &&
        teacherController.teachers.isEmpty &&
        schoolID != null) {
      // If we've loaded but have no teachers, try to fetch them directly
      Future.microtask(() => _directFetchTeachers());
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),
          if (!isLoading && !_isRefreshing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'عدد المعلمين: ${_filteredTeachers.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshTeachers,
                    tooltip: 'تحديث البيانات',
                    color: const Color.fromARGB(255, 1, 117, 70),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading || _isRefreshing
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color.fromARGB(255, 1, 117, 70),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل بيانات المعلمين...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredTeachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'لا يوجد معلمين بهذا الاسم'
                                  : 'لا يوجد معلمين في هذه المدرسة',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _isSearching = false;
                                    _updateFilteredTeachers();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 1, 117, 70),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('إظهار جميع المعلمين'),
                              ),
                            ],
                            // Add a refresh button when no teachers are found
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _directFetchTeachers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('تحديث البيانات'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 1, 117, 70),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshTeachers,
                        color: const Color.fromARGB(255, 1, 117, 70),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = _filteredTeachers[index];
                            return _buildTeacherCard(teacher);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'بحث عن معلم...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _isSearching
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                    _updateFilteredTeachers();
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 1, 117, 70), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _isSearching = value.isNotEmpty;
          _updateFilteredTeachers();
        });
      },
    );
  }

  Widget _buildTeacherCard(UserModel teacher) {
    final fullName =
        '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
            .trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(255, 1, 117, 70),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (teacher.email != null && teacher.email!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            teacher.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildContactInfo(teacher),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // View teacher details
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('عرض التفاصيل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 1, 117, 70),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 1, 117, 70)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Edit teacher
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 117, 70),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(UserModel teacher) {
    return Column(
      children: [
        if (teacher.phone_number != null && teacher.phone_number != 0)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.phone, color: Color.fromARGB(255, 1, 117, 70)),
            title: const Text('رقم الجوال'),
            subtitle: Text(teacher.phone_number.toString()),
            dense: true,
          ),
        if (teacher.telephone_number != null && teacher.telephone_number != 0)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_in_talk,
                color: Color.fromARGB(255, 1, 117, 70)),
            title: const Text('رقم الهاتف'),
            subtitle: Text(teacher.telephone_number.toString()),
            dense: true,
          ),
      ],
    );
  }
}
