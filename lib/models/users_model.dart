class UserModel {
  int? user_id;
  String? first_name;
  String? middle_name;
  String? grandfather_name;
  String? last_name;
  int? phone_number;
  int? telephone_number;
  String? email;
  int? password;
  int? role_id;
  String? date; // إضافة حقل تاريخ الميلاد
  int? isActivate; // إضافة حقل تفعيل المستخدم

  UserModel({
    this.user_id,
    this.first_name,
    this.middle_name,
    this.grandfather_name,
    this.last_name,
    this.phone_number,
    this.telephone_number,
    this.email,
    this.password,
    this.role_id,
    this.date,
    this.isActivate,
  });
}

// UserModel userModel = UserModel();
