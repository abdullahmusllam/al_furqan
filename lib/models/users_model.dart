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
  int? roleID;
  int? schoolID;
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
    this.roleID,
    this.schoolID,
    this.date,
    this.isActivate = 0,
  });

  // تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'first_name': first_name,
      'middle_name': middle_name,
      'grandfather_name': grandfather_name,
      'last_name': last_name,
      'phone_number': phone_number,
      'telephone_number': telephone_number,
      'email': email,
      'password': password,
      'roleID': roleID,
      'schoolID': schoolID,
      'date': date,
      'isActivate': isActivate,
    };
  }

  // تحويل Map إلى كائن UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      user_id: map['user_id'] as int?,
      first_name: map['first_name'] as String?,
      middle_name: map['middle_name'] as String?,
      grandfather_name: map['grandfather_name'] as String?,
      last_name: map['last_name'] as String?,
      phone_number: map['phone_number'] as int?,
      telephone_number: map['telephone_number'] as int?,
      email: map['email'] as String?,
      password: map['password'] as int?,
      roleID: map['roleID'] as int?,
      schoolID: map['schoolID'] as int?,
      date: map['date'] as String?,
      isActivate: map['isActivate'] as int?,
    );
  }

  int get userID => null!;
}

// UserModel userModel = UserModel();
