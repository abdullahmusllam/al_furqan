import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import '../controllers/school_controller.dart';
import '../models/schools_model.dart';

class RequestsList extends StatefulWidget {
  const RequestsList({super.key});

  @override
  _RequestsListState createState() => _RequestsListState();
}

class _RequestsListState extends State<RequestsList> {
  List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    await userController.get_data_requests();
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

  @override
  Widget build(BuildContext context) {
    return userController.requests.isEmpty
        ? Center(child: Text("لا يوجد طلبات"))
        : ListView.builder(
            itemCount: userController.requests.length,
            itemBuilder: (context, index) {
              String? role_name;
              switch (userController.requests[index].role_id) {
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
                      school.school_id ==
                      userController.requests[index].school_id,
                  orElse: () => SchoolModel(school_name: "المكتب"));

              return ListTile(
                leading: CircleAvatar(
                  child: Text("$index"),
                ),
                title: Text(
                    "${userController.requests[index].first_name!} ${userController.requests[index].middle_name!} ${userController.requests[index].last_name!}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$role_name"),
                    Text(school.school_name!),
                    Text("طلب تفعيل الحساب"),
                  ],
                ),
                trailing: SizedBox(
                  width: 98,
                  child: Row(
                    children: [
                      IconButton(
                        color: Colors.green,
                        icon: Icon(Icons.check),
                        onPressed: () {
                          userController.activate_user(
                              userController.requests[index].user_id!);
                          // Refresh data callback should be passed from parent
                          setState(() {});
                        },
                      ),
                      IconButton(
                        color: Colors.redAccent,
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          userController.delete_request(
                              userController.requests[index].user_id!);
                          _refreshData(); // Refresh data callback should be passed from parent
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
