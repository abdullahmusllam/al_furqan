import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';

Widget buildSaveButton({
  required GlobalKey<FormState> formKey,
  required UserModel user,
  required TextEditingController firstname,
  required TextEditingController fathername,
  required TextEditingController grandfathername,
  required TextEditingController lastname,
  required TextEditingController phone,
  required TextEditingController telephone,
  required TextEditingController email,
  required TextEditingController password,
  required TextEditingController date,
  required String? selectedRole,
  required bool isActivate,
  required Function() refreshData,
  required BuildContext context,
  required Function(bool) setEditable,
}) {
  return ElevatedButton(
    onPressed: () {
      if (formKey.currentState!.validate()) {
        // Handle form submission
        int phoneNumber = int.parse(phone.text);
        int telephoneNumber = int.parse(telephone.text);
        int passwordNumber = int.parse(password.text);
        int? roleId;
        int activate = isActivate ? 1 : 0;

        user.first_name = firstname.text;
        user.middle_name = fathername.text;
        user.grandfather_name = grandfathername.text;
        user.last_name = lastname.text;
        user.phone_number = phoneNumber;
        user.telephone_number = telephoneNumber;
        user.email = email.text;
        user.password = passwordNumber;
        user.date = date.text; // تعيين تاريخ الميلاد
        user.isActivate = activate; // تعيين حالة التفعيل

        switch (selectedRole) {
          case "مشرف":
            roleId = 0;
            break;
          case "مدير":
            roleId = 1;
            break;
          case "معلم":
            roleId = 2;
            break;
        }
        user.role_id = roleId;
        userController.update_user(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم حفظ التعديلات بنجاح"),
          ),
        );
        setEditable(false);
        refreshData();
        Navigator.of(context)
            .pop(true); // Return true to indicate that data was updated
      }
    },
    child: Text('حفظ التعديلات'),
  );
}
