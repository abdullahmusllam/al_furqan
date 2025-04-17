import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/views/Supervisor/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Supervisor/user_details.dart';
import '../../models/schools_model.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String _searchQuery = '';
  String? _selectedRole;
  int? _selectedSchoolId;
  final List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    super.initState();
    userController.getData();
    schoolController.get_data();

    /// تحميل المدارس علشان ما يعطي نل
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

  List _filterUsers() {
    return userController.users.where((user) {
      bool matchesSearchQuery = _searchQuery.isEmpty ||
          user.first_name?.contains(_searchQuery) == true ||
          user.middle_name?.contains(_searchQuery) == true ||
          user.last_name?.contains(_searchQuery) == true;
      bool matchesRole = _selectedRole == null ||
          (_selectedRole == "مشرف" && user.roleID == 0) ||
          (_selectedRole == "مدير" && user.roleID == 1) ||
          (_selectedRole == "معلم" && user.roleID == 2);
      bool matchesSchool =
          _selectedSchoolId == null || user.schoolID == _selectedSchoolId;
      return matchesSearchQuery && matchesRole && matchesSchool;
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildUserList(List filteredUsers) {
    return filteredUsers.isEmpty
        ? Center(child: Text("لا يوجد مستخدمين"))
        : ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              String? roleName;
              switch (filteredUsers[index].roleID) {
                case 0:
                  roleName = "مشرف";
                  break;
                case 1:
                  roleName = "مدير";
                  break;
                case 2:
                  roleName = "معلم";
                  break;
              }

              final school = schoolController.schools.firstWhere(
                  (school) => school.schoolID == filteredUsers[index].schoolID,
                  orElse: () => SchoolModel(school_name: "المكتب"));

              return ListTile(
                title: Text(
                    "${filteredUsers[index].first_name ?? ''} ${filteredUsers[index].middle_name ?? ''} ${filteredUsers[index].last_name ?? ''}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roleName!),
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
                              builder: (context) =>
                                  UserDetails(user: filteredUsers[index])));
                        },
                      ),
                      IconButton(
                        color: Colors.redAccent,
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          if (userController.users[index].roleID == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("لا تملك صلاحية حذف مشرف !!"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            setState(() {
                              userController
                                  .deleteUser(filteredUsers[index].user_id!);
                              userController.getData();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    List filteredUsers = _filterUsers();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildUserList(filteredUsers),
        ),
      ],
    );
  }
}
