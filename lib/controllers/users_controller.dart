import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserController {
  final List<UserModel> _users = [];
  final List<UserModel> _requests = [];
  final SqlDb _sqlDb = SqlDb();

  List<UserModel> get users => _users;
  List<UserModel> get requests => _requests;

  // Method to get all data
  Future<void> getData() async {
    await getDataUsers();
    // await getDataRequests();
  }

  // Method to get active users data
  // Future<void> getDataUsers() async {
  //   List<Map> response =
  //       await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 1");
  //   if (!(ConnectivityResult == ConnectivityResult.none)) {
  //     var responseFirebase = await firebasehelper.getUsers("manager&admin");
  //   }
  //   _users.clear();
  //   _users.addAll(_mapResponseToUserModel(response));
  //   print("Users List : ${_users.isEmpty}");
  // }
  Future<void> getDataUsers() async {
    // 1. جلب البيانات من قاعدة البيانات المحلية (SQLite) أولاً
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 1");
    _users.clear();
    _users.addAll(_mapResponseToUserModel(response));
    print("Users List (Local): ${_users.isEmpty}");

    // 2. محاولة جلب البيانات من Firebase
    // try {
    //   // جلب البيانات من Firebase
    //   List<UserModel> responseFirebase = await firebasehelper.getUsers();

    //   // 3. التحقق إن responseFirebase مش null ومش فاضية
    //   if (responseFirebase.isNotEmpty) {
    //     // مسح البيانات القديمة من الجدول (النشطين فقط)
    //     await _sqlDb.deleteData("DELETE FROM USERS WHERE isActivate = 1");

    //     // إضافة البيانات الجديدة من Firebase
    //     for (var user in responseFirebase) {
    //       if (user.user_id != null) {
    //         await _sqlDb.insertData('''
    //         INSERT INTO USERS (user_id, first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, roleID, schoolID, date, isActivate)
    //         VALUES (${user.user_id}, '${user.first_name ?? ''}', '${user.middle_name ?? ''}', '${user.grandfather_name ?? ''}', '${user.last_name ?? ''}', '${user.password ?? 0}', '${user.email ?? ''}', ${user.phone_number ?? 0}, ${user.telephone_number ?? 0}, ${user.roleID ?? 0}, ${user.schoolID ?? 0}, '${user.date ?? ''}', 1)
    //       ''');
    //       }
    //     }

    //     // 4. إعادة جلب البيانات من SQLite بعد التحديث
    //     response =
    //         await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 1");
    //     _users.clear();
    //     _users.addAll(_mapResponseToUserModel(response));
    //     print("Users List (After Firebase Sync): ${_users.isEmpty}");
    //   } else {
    //     print("لا توجد بيانات من Firebase لتحديث قاعدة البيانات المحلية");
    //   }
    // } catch (e) {
    //   print("خطأ أثناء مزامنة البيانات من Firebase: $e");
    //   // لو حصل خطأ (مثل ما فيه إنترنت أو مشكلة في Firestore)، بنعتمد على البيانات المحلية
    // }
  }

  // Method to get requests data
  // Future<void> getDataRequests() async {
  //   List<Map> response =
  //       await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 0");
  //   _requests.clear();
  //   _requests.addAll(_mapResponseToUserModel(response));
  //   print("Request List : ${_requests.isEmpty}");
  // }
  Future<void> getDataRequests() async {
    // 1. جلب البيانات من قاعدة البيانات المحلية (SQLite) أولاً
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 0");
    _requests.clear();
    _requests.addAll(_mapResponseToUserModel(response));
    print("_requests List (Local): ${_requests.isEmpty}");

    // 2. محاولة جلب البيانات من Firebase
    // try {
    //   // جلب البيانات من Firebase
    //   List<UserModel> responseFirebase = await firebasehelper.getUsers();

    //   // 3. التحقق إن responseFirebase مش null ومش فاضية
    //   if (responseFirebase.isNotEmpty) {
    //     // مسح البيانات القديمة من الجدول (الغبر مفعلين فقط)
    //     await _sqlDb.deleteData("DELETE FROM USERS WHERE isActivate = 0");

    //     // إضافة البيانات الجديدة من Firebase
    //     for (var user in responseFirebase) {
    //       if (user.user_id != null) {
    //         await _sqlDb.insertData('''
    //         INSERT INTO USERS (user_id, first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, roleID, schoolID, date, isActivate)
    //         VALUES (${user.user_id}, '${user.first_name ?? ''}', '${user.middle_name ?? ''}', '${user.grandfather_name ?? ''}', '${user.last_name ?? ''}', '${user.password ?? 0}', '${user.email ?? ''}', ${user.phone_number ?? 0}, ${user.telephone_number ?? 0}, ${user.roleID ?? 0}, ${user.schoolID ?? 0}, '${user.date ?? ''}', 0)
    //       ''');
    //       }
    //     }

    //     // 4. إعادة جلب البيانات من SQLite بعد التحديث
    //     response =
    //         await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 0");
    //     _users.clear();
    //     _users.addAll(_mapResponseToUserModel(response));
    //     print("Users List (After Firebase Sync): ${_users.isEmpty}");
    //   } else {
    //     print("لا توجد بيانات من Firebase لتحديث قاعدة البيانات المحلية");
    //   }
    // } catch (e) {
    //   print("خطأ أثناء مزامنة البيانات من Firebase: $e");
    //   // لو حصل خطأ (مثل ما فيه إنترنت أو مشكلة في Firestore)، بنعتمد على البيانات المحلية
    // }
  }

  // Method to add a new user
  Future<void> addUser(UserModel userModel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, roleID, schoolID, date, isActivate)
    VALUES ('${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.password}', '${userModel.email}', '${userModel.phone_number}', '${userModel.telephone_number}', ${userModel.roleID}, ${userModel.schoolID}, '${userModel.date}', '${userModel.isActivate}');
    ''');
    print("response = $response, isActivate = ${userModel.isActivate}");
  }

  // Method to delete a user
  Future<void> deleteUser(int userId) async {
    int response =
        await _sqlDb.deleteData("DELETE FROM USERS WHERE user_id = $userId");
    print(response);
  }

  // Method to activate a user
  Future<void> activateUser(int userId) async {
    await _sqlDb.updateData('''
    UPDATE USERS SET isActivate = 1 WHERE user_id = $userId
    ''');
    await getData();
  }

  // Method to delete a request
  Future<void> deleteRequest(int userId) async {
    await _sqlDb.deleteData(
        "DELETE FROM USERS WHERE user_id = $userId AND isActivate = 0");
    await getDataRequests();
  }

  // Method to update a user
  Future<void> updateUser(UserModel userModel) async {
    print("Hi from updateUser method");
    int response = await _sqlDb.updateData('''
    UPDATE USERS SET
      first_name = '${userModel.first_name}',
      middle_name = '${userModel.middle_name}',
      grandfather_name = '${userModel.grandfather_name}',
      last_name = '${userModel.last_name}',
      password = '${userModel.password}',
      email = '${userModel.email}',
      phone_number = '${userModel.phone_number}',
      telephone_number = '${userModel.telephone_number}',
      roleID = ${userModel.roleID},
      schoolID = ${userModel.schoolID},
      date = '${userModel.date}',
      isActivate = ${userModel.isActivate}
    WHERE user_id = ${userModel.user_id}
    ''');
    print("Update response: $response");
    if (response == 0) {
      throw Exception("Failed to update user ${userModel.user_id}");
    }
  }

  // Method to add a new request
  Future<void> addRequest(UserModel userModel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, phone_number, telephone_number, email, password, roleID, schoolID, date, isActivate)
    VALUES ('${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.phone_number}', '${userModel.telephone_number}', '${userModel.email}', '${userModel.password}', ${userModel.roleID}, ${userModel.schoolID}, '${userModel.date}', 0);
    ''');
    print("request school id : ${userModel.schoolID}");
    print("response = $response, isActivate = ${userModel.isActivate}");
  }

  // Helper method to map response to UserModel
  List<UserModel> _mapResponseToUserModel(List<Map> response) {
    return response.map((data) {
      return UserModel(
        user_id: data['user_id'] as int?,
        first_name: data['first_name'],
        middle_name: data['middle_name'],
        grandfather_name: data['grandfather_name'],
        last_name: data['last_name'],
        phone_number: int.tryParse(data['phone_number'].toString()),
        telephone_number: int.tryParse(data['telephone_number'].toString()),
        email: data['email'],
        password: data['password'] as int?, // Ensure password is a string
        roleID: data['roleID'] as int?,
        schoolID: data['schoolID'] as int?,
        date: data['date'],
        isActivate: data['isActivate'] as int?,
      );
    }).toList();
  }
}

UserController userController = UserController();
