import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/users_controller.dart';

class RequestsList extends StatelessWidget {
  const RequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    return userController.requests.isEmpty
        ? Center(child: Text("لا يوجد طلبات"))
        : ListView.builder(
            itemCount: userController.requests.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(userController.requests[index].first_name!),
                subtitle: Text("طلب تفعيل الحساب"),
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
                        },
                      ),
                      IconButton(
                        color: Colors.redAccent,
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          userController.delete_request(
                              userController.requests[index].user_id!);
                          // Refresh data callback should be passed from parent
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
