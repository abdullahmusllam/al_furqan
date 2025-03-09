import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';

class UserController {
  final List<UserModel> _users = [];
  final List<UserModel> _requests = [];
  final SqlDb _sqlDb = SqlDb();

  List<UserModel> get users => _users;
  List<UserModel> get requests => _requests;

  get_data() async {
    await get_data_users();
    await get_data_requests();
  }

  get_data_users() async {
    List<Map> response = await _sqlDb.readData("SELECT * FROM 'USERS'");
    _users.clear();
    for (var i = 0; i < response.length; i++) {
      _users.add(UserModel(
        user_id: response[i]['user_id'] as int?, // تأكد من أن user_id هو int
        first_name: response[i]['first_name'],
        middle_name: response[i]['middle_name'],
        grandfather_name: response[i]['grandfather_name'],
        last_name: response[i]['last_name'],
        phone_number: int.tryParse(
            response[i]['phone_number'].toString()), // تحويل إلى int
        telephone_number: int.tryParse(
            response[i]['telephone_number'].toString()), // تحويل إلى int
        email: response[i]['email'],
        password: response[i]['password'],
        role_id: response[i]['role_id'] as int?, // تأكد من أن role_id هو int
        school_id: response[i]['school_id'] as int?,
        date: response[i]['date'],
        isActivate:
            response[i]['isActivate'] as int?, // تأكد من أن isActivate هو int
      ));
    }
    // users.forEach((element) {
    //   print(
    //       "USER ID : ${element.user_id}\nUSER NAME : ${element.first_name}\nSCHOOL ID : ${element.school_id}\n____________________________________________________________________________");
    // });
    print("${_users.isEmpty}");
  }

  get_data_requests() async {
    List<Map> requestResponse =
        await _sqlDb.readData("SELECT * FROM 'REQUESTS'");
    _requests.clear();
    for (var i = 0; i < requestResponse.length; i++) {
      _requests.add(UserModel(
        user_id:
            requestResponse[i]['user_id'] as int?, // تأكد من أن user_id هو int
        first_name: requestResponse[i]['first_name'],
        middle_name: requestResponse[i]['middle_name'],
        grandfather_name: requestResponse[i]['grandfather_name'],
        last_name: requestResponse[i]['last_name'],
        phone_number: int.tryParse(
            requestResponse[i]['phone_number'].toString()), // تحويل إلى int
        telephone_number: int.tryParse(
            requestResponse[i]['telephone_number'].toString()), // تحويل إلى int
        email: requestResponse[i]['email'],
        password: int.tryParse(requestResponse[i]['password'].toString()),
        role_id: requestResponse[i]['role_id'] as int?,
        school_id: requestResponse[i]['school_id']
            as int?, // تأكد من أن role_id هو int
        date: requestResponse[i]['date'],
        isActivate: requestResponse[i]['isActivate']
            as int?, // تأكد من أن isActivate هو int
      ));
    }
    requests.forEach((element) {
      print(
          "REQUEST ID : ${element.user_id}\nUSER NAME : ${element.first_name}\n SCHOOL ID:${element.school_id}\n____________________________________________________________________________");
    });
    print("${_requests.isEmpty}");
  }

  add_user(UserModel usermodel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, role_id, school_id, date, isActivate)
    VALUES ('${usermodel.first_name}', '${usermodel.middle_name}', '${usermodel.grandfather_name}', '${usermodel.last_name}', '${usermodel.password}', '${usermodel.email}', '${usermodel.phone_number}', '${usermodel.telephone_number}', ${usermodel.role_id}, ${usermodel.school_id}, '${usermodel.date}', ${usermodel.isActivate});
    ''');

    print(response);
  }

  delete_user(int userId) async {
    int response =
        await _sqlDb.deleteData("DELETE FROM USERS WHERE user_id = $userId");
    print(response);
  }

  activate_user(int userId) async {
    // نسخ جميع أعمدة الصف من جدول REQUESTS إلى جدول USERS
    await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, role_id, school_id, date, isActivate)
    SELECT first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, role_id, school_id, date, 1
    FROM REQUESTS WHERE user_id = $userId
    ''');
    // حذف الصف من جدول REQUESTS
    await _sqlDb.deleteData("DELETE FROM REQUESTS WHERE user_id = $userId");
    await get_data_users();
    await get_data_requests();
  }

  delete_request(int userId) async {
    await _sqlDb.deleteData("DELETE FROM REQUESTS WHERE user_id = $userId");
    await get_data_requests();
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

  add_request(UserModel usermodel) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO REQUESTS (first_name, middle_name, grandfather_name, last_name, phone_number, telephone_number, email, password,role_id ,school_id, date)
    VALUES ('${usermodel.first_name}', '${usermodel.middle_name}', '${usermodel.grandfather_name}', '${usermodel.last_name}', '${usermodel.phone_number}', '${usermodel.telephone_number}', '${usermodel.email}', '${usermodel.password}',${usermodel.role_id},${usermodel.school_id}, '${usermodel.date}');
    ''');
    print("request school id : ${usermodel.school_id}");
    print("response = $response");
  }
}

UserController userController = UserController();
