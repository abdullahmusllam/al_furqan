import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';

class UserController {
  final List<UserModel> _users = [];
  final List<UserModel> _requests = [];
  final SqlDb _sqlDb = SqlDb();

  List<UserModel> get users => _users;
  List<UserModel> get requests => _requests;

  // Method to get all data
  Future<void> getData() async {
    await getDataUsers();
    await getDataRequests();
  }

  // Method to get active users data
  Future<void> getDataUsers() async {
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 1");
    _users.clear();
    _users.addAll(_mapResponseToUserModel(response));
    print("Users List : ${_users.isEmpty}");
  }

  // Method to get requests data
  Future<void> getDataRequests() async {
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 0");
    _requests.clear();
    _requests.addAll(_mapResponseToUserModel(response));
    print("Request List : ${_requests.isEmpty}");
  }

  // Method to add a new user
  Future<void> addUser(UserModel userModel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, role_id, school_id, date, isActivate)
    VALUES ('${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.password}', '${userModel.email}', '${userModel.phone_number}', '${userModel.telephone_number}', ${userModel.role_id}, ${userModel.school_id}, '${userModel.date}', '${userModel.isActivate}');
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
      role_id = ${userModel.role_id},
      school_id = ${userModel.school_id},
      date = '${userModel.date}',
      isActivate = ${userModel.isActivate}
    WHERE user_id = ${userModel.user_id}
    ''');
    print("response = $response");
  }

  // Method to add a new request
  Future<void> addRequest(UserModel userModel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, phone_number, telephone_number, email, password, role_id, school_id, date, isActivate)
    VALUES ('${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.phone_number}', '${userModel.telephone_number}', '${userModel.email}', '${userModel.password}', ${userModel.role_id}, ${userModel.school_id}, '${userModel.date}', 0);
    ''');
    print("request school id : ${userModel.school_id}");
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
        role_id: data['role_id'] as int?,
        school_id: data['school_id'] as int?,
        date: data['date'],
        isActivate: data['isActivate'] as int?,
      );
    }).toList();
  }
}

UserController userController = UserController();
