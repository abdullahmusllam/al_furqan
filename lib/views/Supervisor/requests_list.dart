import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import '../../controllers/school_controller.dart';
import '../../models/schools_model.dart';

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
    await userController.getDataRequests();
    await schoolController.getData();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.schoolID,
                child: Text(school.school_name!),
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userController.requests.isEmpty
          ? Center(
              child: Text("لا يوجد طلبات")) // Display message if no requests
          : ListView.builder(
              itemCount: userController.requests.length,
              itemBuilder: (context, index) {
                // Determine role name based on roleID
                String? roleName;
                switch (userController.requests[index].roleID) {
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

                // Find the school associated with the request
                final school = schoolController.schools.firstWhere(
                    (school) =>
                        school.schoolID ==
                        userController.requests[index].schoolID,
                    orElse: () => SchoolModel(school_name: "المكتب"));

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  title: Text(
                    "${userController.requests[index].first_name!} ${userController.requests[index].middle_name!} ${userController.requests[index].last_name!}",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text("$roleName"),
                      Text(school.school_name!),
                      Text("طلب تفعيل الحساب"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      _showMaterialBottomSheet(
                          context, index); // Call Material bottom sheet
                    },
                  ),
                );
              },
            ),
    );
  }

  // Function to show Material Bottom Sheet
  void _showMaterialBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('قبول الطلب'),
                onTap: () {
                  acceptRequest(index, context); // Accept request action
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text('تفاصيل الطلب'),
                onTap: () async {
                  try {
                    print("Attempting to show details for index: $index");
                    await showDialogDetailsRequest(
                        context, index); // Show request details
                    Navigator.pop(context); // Close bottom sheet after dialog
                  } catch (e) {
                    print("Error in showDialogDetailsRequest: $e");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.redAccent),
                title: Text('حذف الطلب'),
                onTap: () async {
                  await showDialogDeleteRequest(
                      context, index); // Delete request
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.grey),
                title: Text('إلغاء'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Function to accept a request and refresh data
  void acceptRequest(int index, BuildContext context) async {
    await userController.activateUser(userController.requests[index].user_id!);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("تم تنشيط الحساب"),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
  }

  // Function to show a dialog for deleting a request
  Future<dynamic> showDialogDeleteRequest(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تأكيد الحذف"),
          content: Text("هل تريد حذف الطلب؟"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: Text("إلغاء"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "حذف",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                userController
                    .deleteRequest(userController.requests[index].user_id!);
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
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog with request details
  Future<dynamic> showDialogDetailsRequest(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تفاصيل الطلب"),
          content: Text(
            "تفاصيل الطلب الخاصة بالمستخدم \n${userController.requests[index].first_name!} ${userController.requests[index].middle_name!} ${userController.requests[index].last_name!}\nرقم الجوال : ${userController.requests[index].phone_number}",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
