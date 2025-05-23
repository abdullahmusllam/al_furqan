import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';

class FathersController {
  final List<UserModel> fathers = [];
  var fatherByID = UserModel();
  final _sqlDb = SqlDb();

  /// get all fathers by school id
  Future<void> getFathersStudents(int schoolID) async {
    List<Map<String, dynamic>> response = await _sqlDb.readData(
        "SELECT * FROM USERS WHERE ROLEID = 3 AND schoolID = $schoolID");
    print("Reponse into getFathersStudents method : ${response.isEmpty}");
    fathers.clear();
    fathers.addAll(teacherController.mapResponseToUserModel(response));
    print("FathersList into getFathersStudents method : ${fathers.isEmpty}");
  }

  Future<UserModel> getFatherByID(int userID) async {
    // var fa = UserModel();
    List<Map<String, dynamic>> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE user_id = $userID");
    response.forEach((element) {
      fatherByID.user_id = element['user_id'];
      fatherByID.first_name = element['first_name'];
      fatherByID.middle_name = element['middle_name'];
      fatherByID.grandfather_name = element['grandfather_name'];
      fatherByID.last_name = element['last_name'];
      fatherByID.phone_number = element['phone_number'];
      fatherByID.telephone_number = element['telephone_number'];
      fatherByID.email = element['email'];
      fatherByID.password = element['password'];
      fatherByID.roleID = element['roleID'];
      fatherByID.schoolID = element['schoolID'];
      fatherByID.date = element['date'];
      fatherByID.isActivate = element['isActivate'];
    });
    return fatherByID;
  }

  /// get fathers by student id
  Future<void> getFathersStudentsByStudentID(
      int schoolID, int studentID) async {
    /// this's all for get user id into student
    List<Map<String, dynamic>> response = await _sqlDb
        .readData("SELECT * FROM Students WHERE StudentID = $studentID");
    print(
        "Response in getFathersStudentsByStudentID method : ${response.isEmpty}");
    response.forEach((e) {
      fatherByID.user_id = e['userID'];
      fatherByID.first_name = e['first_name'];
      fatherByID.middle_name = e['middle_name'];
      fatherByID.grandfather_name = e['grandfather_name'];
      fatherByID.last_name = e['last_name'];
      fatherByID.phone_number = e['phone_number'];
      fatherByID.telephone_number = e['telephone_number'];
      fatherByID.email = e['email'];
      fatherByID.password = e['password'];
      fatherByID.roleID = e['roleID'];
      fatherByID.schoolID = e['schoolID'];
      fatherByID.date = e['date'];
      fatherByID.isActivate = e['isActivate'];

      print("User Id in FatherController : ${fatherByID.user_id}");
    });
    try {
      fatherByID = await getFatherByID(fatherByID.user_id!);
    } catch (e) {
      print("Error In Father Controller : $e ");
    }
  }

  Future<int> addFather(UserModel father) async {
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, phone_number, telephone_number, email, password, roleID, schoolID, date, isActivate)
    VALUES ('${father.first_name}', '${father.middle_name}', '${father.grandfather_name}', '${father.last_name}', '${father.phone_number}', '${father.telephone_number}', '${father.email}', '${father.password}', ${father.roleID}, ${father.schoolID}, '${father.date}', 0);
    ''');
    father.user_id = response;
    print("Response into addFather method : $response");
    return father.user_id = response;
  }
}

FathersController fathersController = FathersController();
