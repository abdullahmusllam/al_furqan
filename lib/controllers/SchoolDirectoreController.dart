import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/login/login.dart';

class SchoolDirectorController {
  final SqlDb _sqlDb = SqlDb();
  final List<UserModel> userData = [];
  get_data_users(String phoneNumber) async {
    List<Map> Data = await _sqlDb.readData(
        "SELECT * FROM 'USERS' WHERE phone_number = '${id}'");
    userData.clear();
    for (var i = 0; i < Data.length; i++) {
      userData.add(UserModel(
        user_id: Data[i]['user_id'] as int?, // تأكد من أن user_id هو int
        first_name: Data[i]['first_name'],
        middle_name: Data[i]['middle_name'],
        grandfather_name: Data[i]['grandfather_name'],
        last_name: Data[i]['last_name'],
        phone_number:
            int.tryParse(Data[i]['phone_number'].toString()), // تحويل إلى int
        telephone_number: int.tryParse(
            Data[i]['telephone_number'].toString()), // تحويل إلى int
        email: Data[i]['email'],
        password: Data[i]['password'],
        role_id: Data[i]['role_id'] as int?, // تأكد من أن role_id هو int
        school_id: Data[i]['school_id'] as int?,
        date: Data[i]['date'],
        // isActivate: response[i]['isActivate'] as int?, // تأكد من أن isActivate هو int
      ));
    }
    // users.forEach((element) {
    //   print(
    //       "USER ID : ${element.user_id}\nUSER NAME : ${element.first_name}\nSCHOOL ID : ${element.school_id}\n____________________________________________________________________________");
    // });
    print("${userData.isEmpty}");
  }
}

SchoolDirectorController schoolDirectorController = SchoolDirectorController();
