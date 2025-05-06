import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/roles_model.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/services/message_sevice.dart';

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
          await firebasehelper.updateUser(user);

          await sqlDb.updateData(
              'update Users set isSync = 1 where user_id = ${user.user_id}');
          print('===== sync user (update) =====');

        } else {
          await firebasehelper.addUser(user);
          await sqlDb.updateData(
              'update Users set isSync = 1 where user_id = ${user.user_id}');

          print('===== sync user (add) =====');
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
          await firebasehelper.updateSchool(school);

          await sqlDb.updateData(
              'update Schools set isSync = 1 where SchoolID = ${school.schoolID}');
          print('===== sync school (update) =====');

        } else {
          await firebasehelper.addSchool(school);
          await sqlDb.updateData(
              'update Schools set isSync = 1 where SchoolID = ${school.schoolID}');

          print('===== sync school (add) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }

Future<void> syncMessage() async {
    print('===== sync Message =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("messages", 'sync', 0);
    if (map.isNotEmpty) {
      print('===== map.isNotEmpty =====');
      List<Message> messages = map.map((map) => Message.fromMap(map)).toList();
      for (var message in messages) {
        bool exists =
            await firebasehelper.checkDocumentExists('messages', message.id!);
        if (exists) {
          await firebaseHelper.updateMessage(message);

          await sqlDb.updateData(
              'update messages set sync = 1 where id = ${message.id}');
          print('===== sync message (update) =====');

        } else {
          await firebaseHelper.saveMessage(message);
          await sqlDb.updateData(
              'update messages set sync = 1 where id = ${message.id}');

          print('===== sync message (add) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }
// Future<void> syncActivities() async {
//     print('===== sync Activities =====');
//     List<Map<String, dynamic>> map =
//         await sqlDb.readDataID("Activities", 'isSync', 0);
//     if (map.isNotEmpty) {
//       print('===== map.isNotEmpty =====');
      // List<ActivitiesModel> Activities = map.map((map) => ActivitiesModel.fromJson(map)).toList();
      // for (var Activitie in Activities) {
        // bool exists =
            // await firebasehelper.checkDocumentExists('Activities', Activitie.ActivityID!);
        // if (exists) {
          // await firebasehelper.updateActivitie(Activitie, Activitie.ActivityID!);

        //   await sqlDb.updateData(
        //       'update Activities set isSync = 1 where ActivityID = ${Activitie.ActivityID}');
        //   print('===== sync Activitie (update) =====');

        // } else {
          // await firebasehelper.addActivitie(Activities, Activitie.ActivityID!);
          // await sqlDb.updateData(
              // 'update Activities set isSync = 1 where ActivityID = ${Activitie.ActivityID}');

          // print('===== sync school (add) =====');
        // }
  //     }
  //   } else {
  //     print('===== map.isEmpty =====');
  //   }
  // }


Future<void> syncElhalagat() async {
    print('===== sync Elhalagat =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Elhalagat", 'isSync', 0);
    if (map.isNotEmpty) {
      print('===== map.isNotEmpty =====');
      List<HalagaModel> halagas = map.map((map) => HalagaModel.fromJson(map)).toList();
      for (var halaga in halagas) {
        bool exists =
            await firebasehelper.checkDocumentExists('Elhalagat', halaga.halagaID!);
        if (exists) {
          // await firebaseHelper.updateMessage(message);

          await sqlDb.updateData(
              'update Elhalagat set isSync = 1 where halagaID = ${halaga.halagaID}');
          print('===== sync Elhalagat (update) =====');

        } else {
          // await firebaseHelper.saveMessage(message);
          await sqlDb.updateData(
              'update Elhalagat set isSync = 1 where halagaID = ${halaga.halagaID}');

          print('===== sync Elhalagat (add) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }

  // Future<void> syncIslamicStudies() async {
  //   print('===== sync IslamicStudies =====');
  //   List<Map<String, dynamic>> map =
  //       await sqlDb.readDataID("IslamicStudies", 'isSync', 0);
  //   if (map.isNotEmpty) {
  //     print('===== map.isNotEmpty =====');
  //     // List<HalagaModel> halagas = map.map((map) => HalagaModel.fromJson(map)).toList();
      // for (var halaga in halagas) {
        // bool exists =
            // await firebasehelper.checkDocumentExists('IslamicStudies', halaga.halagaID!);
        // if (exists) {
          // await firebaseHelper.updateMessage(message);

  //         await sqlDb.updateData(
  //             'update IslamicStudies set isSync = 1 where IslamicStudiesID = ${halaga.halagaID}');
  //         print('===== sync IslamicStudies (update) =====');

  //       } else {
  //         // await firebaseHelper.saveMessage(message);
  //         await sqlDb.updateData(
  //             'update IslamicStudies set isSync = 1 where IslamicStudiesID = ${halaga.halagaID}');

  //         print('===== sync IslamicStudies (add) =====');
  //       }
  //     }
  //   } else {
  //     print('===== map.isEmpty =====');
  //   }
  // }

  Future<void> syncStudents() async {
    print('===== sync Students =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Students", 'isSync', 0);
    if (map.isNotEmpty) {
      print('===== map.isNotEmpty =====');
      List<StudentModel> students = map.map((map) => StudentModel.fromJson(map)).toList();
      for (var student in students) {
        bool exists =
            await firebasehelper.checkDocumentExists('Students', student.studentID!);
        if (exists) {
           await firebasehelper.updateStudentData(student);

          await sqlDb.updateData(
              'update Students set isSync = 1 where StudentID = ${student.studentID}');
          print('===== sync Student (update) =====');

        } else {
           await firebasehelper.addStudent(student, student.schoolId!);
          await sqlDb.updateData(
              'update Students set isSync = 1 where StudentID = ${student.studentID}');

          print('===== sync Student (add) =====');
        }
      }
    } else {
      print('===== map.isEmpty =====');
    }
  }

  // Future<void> syncActivityTypes() async {
  //   print('===== sync ActivityTypes =====');
  //   List<Map<String, dynamic>> map =
  //       await sqlDb.readDataID("ActivityTypes", 'isSync', 0);
  //   if (map.isNotEmpty) {
  //     print('===== map.isNotEmpty =====');
  //     // List<StudentModel> students = map.map((map) => StudentModel.fromJson(map)).toList();
  //     // for (var student in students) {
  //       // bool exists =
  //           // await firebasehelper.checkDocumentExists('Students', student.studentID!);
  //       // if (exists) {
  //         //  await firebasehelper.updateStudentData(student);

  //         // await sqlDb.updateData(
  //         //     'update Students set isSync = 1 where StudentID = ${student.studentID}');
  //         // print('===== sync Student (update) =====');

  //       } else {
  //          await firebasehelper.addStudent(student, student.schoolId!);
  //         await sqlDb.updateData(
  //             'update Students set isSync = 1 where StudentID = ${student.studentID}');

  //         print('===== sync Student (add) =====');
  //       }
  //     }
  //   } else {
  //     print('===== map.isEmpty =====');
  //   }
  // }

}

Sync sync = Sync();
