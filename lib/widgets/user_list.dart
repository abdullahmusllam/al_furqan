import 'package:al_furqan/controllers/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/widgets/user_details.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    await userController.get_data();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return userController.users.isEmpty
        ? Center(child: Text("لا يوجد مستخدمين"))
        : ListView.builder(
            itemCount: userController.users.length,
            itemBuilder: (context, index) {
              String? role_name;
              switch (userController.users[index].role_id) {
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
              return ListTile(
                title: Text(
                    "${userController.users[index].first_name!} ${userController.users[index].middle_name!} ${userController.users[index].last_name!}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role_name!),
                    Text(userController.users[index].isActivate == 1
                        ? "مفعل"
                        : "غير مفعل"),
                    Text("${userController.users[index].date}")
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => UserDetails(
                          //         user: userController.users[index]),
                          //   ),
                          // );
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UserDetails(
                                  user: userController.users[index])));
                        },
                      ),
                      IconButton(
                        color: Colors.redAccent,
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          userController.delete_user(
                              userController.users[index].user_id!);
                          _refreshData();
                          // Call a method to refresh data if needed
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
