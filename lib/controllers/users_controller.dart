import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/password_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class UserController {
  final List<UserModel> _users = [];
  final List<UserModel> _requests = [];
  final SqlDb _sqlDb = SqlDb();
  final FirebaseHelper _service = FirebaseHelper();
  final PasswordResetModel _model = PasswordResetModel();
  // var db = sqlDb.database;
  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  List<UserModel> get users => _users;
  List<UserModel> get requests => _requests;
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
        password: data['password'] as String?, // Ensure password is a string
        roleID: data['roleID'] as int?,
        schoolID: data['schoolID'] as int?,
        date: data['date'],
        isActivate: data['isActivate'] as int?,
      );
    }).toList();
  }

  Future<void> addRequest(UserModel userModel) async {
    final db = await sqlDb.database;
    userModel.user_id = await someController.newId("Users", "user_id");
    userModel.isActivate = 0;
    if (await isConnected()) {
      userModel.isSync = 1;
      await firebasehelper.addRequest(userModel);
      await db.insert('Users', userModel.toMap());
    }
    userModel.isSync = 0;
    await db.insert('Users', userModel.toMap());
  }

  // Method to get all data
  Future<void> getData() async {
    await getDataUsers();
    // await getDataRequests();
  }

  Future<void> getDataUsers() async {
    // 1. جلب البيانات من قاعدة البيانات المحلية (SQLite) أولاً
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 1");
    _users.clear();
    _users.addAll(_mapResponseToUserModel(response));
    print("Users List (Local): ${_users.isEmpty}");
  }

  Future<void> getDataRequests() async {
    // 1. جلب البيانات من قاعدة البيانات المحلية (SQLite) أولاً
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 0");
    _requests.clear();
    _requests.addAll(_mapResponseToUserModel(response));
    print("_requests List (Local): ${_requests.isEmpty}");
  }

  // Method to add a new user
  Future<void> addUser(UserModel userModel, int type) async {
    final db = await sqlDb.database;
    if (type == 1) {
      userModel.user_id = await someController.newId("Users", "user_id");
      if (await isConnected()) {
        userModel.isSync = 1;
        await firebasehelper.addUser(userModel);
        await db.insert('Users', userModel.toMap());
      } else {
        userModel.isSync = 0;
        await db.insert('Users', userModel.toMap());
      }
    }
    await db.insert('Users', userModel.toMap());
  }

  // Method to delete a user
  Future<void> deleteUser(int userId) async {
    int response =
        await _sqlDb.deleteData("DELETE FROM USERS WHERE user_id = $userId");
    print(response);
    await getDataUsers();
    // await firebasehelper.deleteUser(userId);
  }

  // Method to activate a user
  Future<void> activateUser(int userId) async {
    try {
      if (await isConnected()) {
        await firebasehelper.activateUser(userId);
        await _sqlDb.updateData('''
    UPDATE USERS SET isActivate = 1 WHERE user_id = $userId
    ''');
        await getData();
      }
      await _sqlDb.updateData('''
    UPDATE USERS SET isActivate = 1, isSync = 0 WHERE user_id = $userId
    ''');
    } catch (e) {
      print('========$e=======');
    }
  }

  // Method to delete a request
  Future<void> deleteRequest(int userId) async {
    await _sqlDb.deleteData(
        "DELETE FROM USERS WHERE user_id = $userId AND isActivate = 0");
    await getDataRequests();
  }

  // Method to update a user
  Future<void> updateUser(UserModel userModel, int type) async {
    final db = await sqlDb.database;
    if (type == 1) {
      if (await isConnected()) {
        userModel.isSync = 1;
        await db.update('USERS', userModel.toMap(),
            where: 'user_id = ?', whereArgs: [userModel.user_id]);
        await firebasehelper.updateUser(userModel);
      } else {
        userModel.isSync = 0;
      await db.update('USERS', userModel.toMap(),
            where: 'user_id = ?', whereArgs: [userModel.user_id]);
      }
      await db.update('USERS', userModel.toMap(),
            where: 'user_id = ?', whereArgs: [userModel.user_id]);
    } 
      int response = await _sqlDb.updateData('''
    UPDATE USERS SET
      ActivityID = ${userModel.activityID},
      ElhalagatID = ${userModel.elhalagatID},
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
      print("response = $response");
    }

    // Method to add a new request

    // Helper method to map response to UserModel

    Future<void> addToLocalOfFirebase() async {
      var connection =
          await InternetConnectionChecker.createInstance().hasConnection;

      if (connection) {
        List<UserModel> responseFirebase = await firebasehelper.getUsers();
        print("responseFirebase = $responseFirebase");

        for (var user in responseFirebase) {
          UserModel userModel = UserModel.fromJson(user.toMap());
          bool exists = await _sqlDb.checkIfitemExists(
              "Users", userModel.user_id!, "user_id");
          if (exists) {
            await updateUser(userModel, 0);
          } else {
            await addUser(userModel, 0);
          }
        }
      } else {
        print("لا يوجد اتصال بالانترنت");
        await getDataUsers();
      }
    }
  

  // إرسال رمز التحقق
  Future<void> sendVerificationCode(int phoneNumber) async {
    _model.phoneNumber = phoneNumber;
    _model.generatedCode = await _service.sendWhatsAppVerification(phoneNumber);
    _model.codeSent = true;
  }

  // تغيير كلمة المرور
  Future<void> resetPassword() async {
    if (!_model.isValidCode) {
      throw 'رمز التحقق غير صحيح';
    }

    if (!_model.isValidNewPassword) {
      throw 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    await _service.updatePassword(
      _model.phoneNumber!,
      _model.newPassword!,
    );
  }

  // Getters للوصول إلى بيانات النموذج
  bool get codeSent => _model.codeSent;
  int? get phoneNumber => _model.phoneNumber;

  // Setters لتحديث بيانات النموذج
  set verificationCode(String code) => _model.verificationCode = code;
  set newPassword(String password) => _model.newPassword = password;

  // إضافة بيانات الأب إلى Firebase
  Future<void> addFatherToFirebase(UserModel fatherData, int schoolID) async {
    print("جاري إضافة ولي الأمر إلى Firebase - معرف المدرسة: $schoolID");
    // التحقق أولاً من وجود اتصال بالإنترنت
    bool hasConnection =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (!hasConnection) {
      print("لا يوجد اتصال بالإنترنت، لا يمكن إضافة ولي الأمر إلى Firebase");
      return;
    }

    if (fatherData.user_id == null) {
      print("تحذير: معرف ولي الأمر غير موجود (user_id = null)");
      return; // لا يمكن الإضافة إلى Firebase بدون معرف
    }

    try {
      // إرسال البيانات إلى Firebase
      await firebasehelper.addRequest(fatherData);
      print("تم إرسال بيانات ولي الأمر إلى Firebase بنجاح");
    } catch (e) {
      print("حدث خطأ أثناء إضافة ولي الأمر إلى Firebase: $e");
    }
  }
}

UserController userController = UserController();
