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
  // List to hold dropdown menu items for schools
  List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    // Initialize state and refresh data
    super.initState();
    _refreshData();
  }

  // Function to refresh data from controllers
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
        ? Center(child: Text("لا يوجد طلبات")) // Display message if no requests
        : ListView.builder(
            itemCount: userController.requests.length,
            itemBuilder: (context, index) {
              // Determine role name based on role_id
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

              // Find the school associated with the request
              final school = schoolController.schools.firstWhere(
                  (school) =>
                      school.school_id ==
                      userController.requests[index].school_id,
                  orElse: () => SchoolModel(school_name: "المكتب"));

              return ListTile(
                leading: CircleAvatar(
                  child: Text("${index + 1}"), // Display index in avatar
                ),
                title: Text(
                    "${userController.requests[index].first_name!} ${userController.requests[index].middle_name!} ${userController.requests[index].last_name!}"), // Display user name
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$role_name"), // Display role name
                    Text(school.school_name!), // Display school name
                    Text("طلب تفعيل الحساب"), // Display request type
                  ],
                ),
                trailing: PopupMenuButton(onSelected: (newValue) {
                  // Handle popup menu selection
                  // if (newValue == "accept") {
                  //   // Accept the request
                  //   // userController
                  //   //     .activate_user(userController.requests[index].user_id!);
                  //   // _refreshData();
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //     content: Text("تم تنشيط الحساب"),
                  //     duration: Duration(seconds: 1),
                  //     backgroundColor: Colors.green,
                  //   ));
                  // } else if (newValue == "delete") {
                  //   // Reject the request
                  //   showDialogDeleteRequest(context, index);
                  // } else
                  switch (newValue) {
                    case "accept":
                      acceptRequest(index, context);
                      break;
                    case "details":
                      showDialogDetailsRequest(context, index);
                      break;
                    case "delete":
                      showDialogDeleteRequest(context, index);
                  }
                }, itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(value: "accept", child: Text("قبول الطلب")),
                    PopupMenuItem(
                        value: "details", child: Text("تفاصيل الطلب")),
                    PopupMenuItem(value: "delete", child: Text("حذف الطلب")),
                  ];
                }),
              );
            },
          );
  }

  void acceptRequest(int index, BuildContext context) {
    userController.activate_user(
        userController.requests[index].user_id!);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("تم تنشيط الحساب"),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
  }

  Future<dynamic> showDialogDeleteRequest(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("تأكيد الحذف"),
              content: Text("هل تريد حذف الطلب؟"),
              actions: [
                TextButton(
                  onPressed: () {
                    userController.delete_request(
                        userController.requests[index].user_id!);
                    _refreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("تم حذف الطلب"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text("حذف"),
                )
              ]);
        });
  }

  Column testDropButton(BuildContext context, int index) {
    return Column(
      children: [
        MaterialButton(
          child: Text("تفاصيل"),
          onPressed: () {
            // Show request details in a dialog
            showDialogDetailsRequest(context, index);
          },
        ),
        MaterialButton(
          child: Text("رفع طلب"),
          onPressed: () {
            // Activate user and refresh data
          },
        ),
        MaterialButton(
          child: Text("حذف"),
          onPressed: () {
            // Delete request and refresh data
            userController
                .delete_request(userController.requests[index].user_id!);
            _refreshData();
          },
        ),
      ],
    );
  }

  Future<dynamic> showDialogDetailsRequest(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تفاصيل الطلب"),
          content: Text(
              "تفاصيل الطلب الخاصة بالمستخدم \n${userController.requests[index].first_name!} ${userController.requests[index].middle_name!} ${userController.requests[index].last_name!}\nرقم الجوال : ${userController.requests[index].phone_number}"),
          actions: [
            TextButton(
              child: Text("إغلاق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
