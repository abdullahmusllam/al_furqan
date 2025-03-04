import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';

class UserController {
  final List<UserModel> _users = [];
  final List<UserModel> _requests = [];
  final SqlDb _sqlDb = SqlDb();

  List<UserModel> get users => _users;
  List<UserModel> get requests => _requests;

  get_data() async {
    List<Map> response = await _sqlDb.readData("SELECT * FROM 'USERS'");
    List<Map> requestResponse =
        await _sqlDb.readData("SELECT * FROM 'REQUESTS'");
    _users.clear();
    _requests.clear();
    for (var i = 0; i < response.length; i++) {
      _users.add(UserModel(
        user_id: response[i]['user_id'] as int?, // تأكد من أن user_id هو int
        first_name: response[i]['first_name'],
        middle_name: response[i]['middle_name'],
        grandfather_name: response[i]['grandfather_name'],
        last_name: response[i]['last_name'],
        phone_number: response[i]['phone_number'],
        telephone_number: response[i]['telephone_number'],
        email: response[i]['email'],
        password: response[i]['password'],
        role_id: response[i]['role_id'] as int?, // تأكد من أن role_id هو int
        date: response[i]['date'],
        isActivate: response[i]['isActivate'],
      ));
    }
    for (var i = 0; i < requestResponse.length; i++) {
      _requests.add(UserModel(
        user_id:
            requestResponse[i]['user_id'] as int?, // تأكد من أن user_id هو int
        first_name: requestResponse[i]['first_name'],
        middle_name: requestResponse[i]['middle_name'],
        grandfather_name: requestResponse[i]['grandfather_name'],
        last_name: requestResponse[i]['last_name'],
        phone_number: requestResponse[i]['phone_number'],
        telephone_number: requestResponse[i]['telephone_number'],
        email: requestResponse[i]['email'],
        password: requestResponse[i]['password'],
        role_id:
            requestResponse[i]['role_id'] as int?, // تأكد من أن role_id هو int
        date: requestResponse[i]['date'],
        isActivate: requestResponse[i]['isActivate'],
      ));
    }
    print("${_users.isEmpty}");
  }

  add_user(UserModel usermodel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, role_id, date, isActivate)
    VALUES ('${usermodel.first_name}', '${usermodel.middle_name}', '${usermodel.grandfather_name}', '${usermodel.last_name}', '${usermodel.password}', '${usermodel.email}', '${usermodel.phone_number}', '${usermodel.telephone_number}', ${usermodel.role_id}, '${usermodel.date}', ${usermodel.isActivate});
    ''');
    print(response);
  }

  delete_user(int userId) async {
    int response =
        await _sqlDb.deleteData("DELETE FROM USERS WHERE user_id = $userId");
  }

  activate_user(int userId) async {
    await _sqlDb
        .updateData("UPDATE USERS SET isActivate = 1 WHERE user_id = $userId");
    await _sqlDb.deleteData("DELETE FROM REQUESTS WHERE user_id = $userId");
    await get_data();
  }

  delete_request(int userId) async {
    await _sqlDb.deleteData("DELETE FROM REQUESTS WHERE user_id = $userId");
    await get_data();
  }

  update_user(UserModel usermodel) async {
    int response = await _sqlDb.updateData('''
    UPDATE USERS SET
      first_name = '${usermodel.first_name}',
      middle_name = '${usermodel.middle_name}',
      grandfather_name = '${usermodel.grandfather_name}',
      last_name = '${usermodel.last_name}',
      password = '${usermodel.password}',
      email = '${usermodel.email}',
      phone_number = '${usermodel.phone_number}',
      telephone_number = '${usermodel.telephone_number}',
      role_id = ${usermodel.role_id},
      date = '${usermodel.date}',
      isActivate = ${usermodel.isActivate}
    WHERE user_id = ${usermodel.user_id}
    ''');
    print(response);
  }
}

UserController userController = UserController();
