import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/views/Supervisor/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/widgets/user_details.dart';

import '../models/schools_model.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String _searchQuery = '';
  String? _selectedRole;
  int? _selectedSchoolId;
  List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    await userController.get_data();
    await schoolController.get_data();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.school_id,
                child: Text(school.school_name!),
              ))
          .toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          selectedRole: _selectedRole,
          selectedSchoolId: _selectedSchoolId,
          schoolItems: _schoolItems,
          onApply: (String? role, int? schoolId) {
            setState(() {
              _selectedRole = role;
              _selectedSchoolId = schoolId;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List filteredUsers = userController.users.where((user) {
      bool matchesSearchQuery = _searchQuery.isEmpty ||
          user.first_name?.contains(_searchQuery) == true ||
          user.middle_name?.contains(_searchQuery) == true ||
          user.last_name?.contains(_searchQuery) == true;
      bool matchesRole = _selectedRole == null ||
          (_selectedRole == "مشرف" && user.role_id == 0) ||
          (_selectedRole == "مدير" && user.role_id == 1) ||
          (_selectedRole == "معلم" && user.role_id == 2);
      bool matchesSchool =
          _selectedSchoolId == null || user.school_id == _selectedSchoolId;
      return matchesSearchQuery && matchesRole && matchesSchool;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'بحث',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(child: Text("لا يوجد مستخدمين"))
              : ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    String? role_name;
                    switch (filteredUsers[index].role_id) {
                      case 0:
                        role_name = "مشرف";
                        break;
                      case 1:
                        role_name = "مدير";
                        break;
                      case 2:
                        role_name = "معلم";
                        break;
                    }

                    final school = schoolController.schools.firstWhere(
                        (school) =>
                            school.school_id == filteredUsers[index].school_id,
                        orElse: () => SchoolModel(school_name: "المكتب"));

                    return ListTile(
                      title: Text(
                          "${filteredUsers[index].first_name ?? ''} ${filteredUsers[index].middle_name ?? ''} ${filteredUsers[index].last_name ?? ''}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role_name!),
                          Text(filteredUsers[index].isActivate == 1
                              ? "مفعل"
                              : "غير مفعل"),
                          Text("${filteredUsers[index].date ?? ''}"),
                          Text("${school.school_name}"),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 98,
                        child: Row(
                          children: [
                            IconButton(
                              color: Colors.blue,
                              icon: Icon(Icons.info),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UserDetails(
                                        user: filteredUsers[index])));
                              },
                            ),
                            IconButton(
                              color: Colors.redAccent,
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                userController
                                    .delete_user(filteredUsers[index].user_id!);
                                _refreshData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
