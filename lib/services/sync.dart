import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';

class Sync {

  Future<void> syncUsers() async {
    print('===== sync Users =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Users", 'isSync', 0);
    if (map.isNotEmpty) {
      print('===== map.isNotEmpty =====');
      List<UserModel> users = map.map((map) => UserModel.fromMap(map)).toList();
      for (var user in users) {
        bool exists =
            await firebasehelper.checkDocumentExists('Users', user.user_id!);
        if (exists) {
          await firebasehelper.updateUser(user.user_id! ,user);

          await sqlDb.updateData(
              'update Users set isSync = 1 where id = ${user.user_id}');
          print('===== sync product (update) =====');

        } else {
          await firebasehelper.addUser(user.user_id!, user);
          await sqlDb.updateData(
              'update Users set isSync = 1 where id = ${user.user_id}');

          print('===== sync product (update) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }

  Future<void> syncSchool() async {
    print('===== sync School =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Schools", 'isSync', 0);
    if (map.isNotEmpty) {
      print('===== map.isNotEmpty =====');
      List<SchoolModel> schools = map.map((map) => SchoolModel.fromJson(map)).toList();
      for (var school in schools) {
        bool exists =
            await firebasehelper.checkDocumentExists('School', school.schoolID!);
        if (exists) {
          await firebasehelper.updateSchool(school, school.schoolID!);

          await sqlDb.updateData(
              'update Schools set isSync = 1 where id = ${school.schoolID}');
          print('===== sync product (update) =====');

        } else {
          await firebasehelper.addSchool(school, school.schoolID!);
          await sqlDb.updateData(
              'update Schools set isSync = 1 where id = ${school.schoolID}');

          print('===== sync product (update) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }



}

Sync sync = Sync();
