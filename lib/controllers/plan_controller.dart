import 'package:al_furqan/helper/new_id2.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

class PlanController {
  final SqlDb sqlDb = SqlDb();
  final FirebaseHelper firebasehelper = FirebaseHelper();

  // قوائم لتخزين الخطط
  List<ConservationPlanModel> conservationPlans = [];
  List<EltlawahPlanModel> eltlawahPlans = [];
  List<IslamicStudiesModel> islamicStudyPlans = [];

  Future<int> addConservationPlan2(ConservationPlanModel plan) async {
    try {
      plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
      int newConservationPlanID = await newId2('ConservationPlans', 'ConservationPlanID');
      plan.conservationPlanId = newConservationPlanID;

      print("----------> studentId for ConservationPlans is :${plan.studentId}");

      bool hasConnection = await InternetConnectionChecker().hasConnection;
      final Map<String, dynamic> planMap = plan.toMap();
      int result = await sqlDb.insertData2('ConservationPlans', planMap);
      print("------------------> Add ConservationPlan is : ${result > 0 ? 'Done' : 'Failed'}");

      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        await firebasehelper.addConservationPlan(plan, newConservationPlanID);
        await sqlDb.updateData3(
          'ConservationPlans',
          {'isSync': 1},
          'ConservationPlanID = ?',
          [newConservationPlanID],
        );
        print("------------------> isSync: Sync Done!");
      } else {
        plan.isSync = 0;
        print("------------------> isSync: not Sync");
      }

      return result;
    } catch (e) {
      print("------------------> Error in addConservationPlan in ((planController)) : $e");
      return -1;
    }
  }

  Future<int> addEltlawahPlan2(EltlawahPlanModel plan) async {
    try {
      plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
      int newEltlawahPlanID = await newId2('EltlawahPlans', 'EltlawahPlanID');
      plan.eltlawahPlanId = newEltlawahPlanID;

      print("----------> studentId for EltlawahPlans is :${plan.studentId}");

      bool hasConnection = await InternetConnectionChecker().hasConnection;
      final Map<String, dynamic> planMap = plan.toMap();
      int result = await sqlDb.insertData2('EltlawahPlans', planMap);
      print("------------------> Add EltlawahPlan is : ${result > 0 ? 'Done' : 'Failed'}");

      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        await firebasehelper.addEltlawahPlan(plan, newEltlawahPlanID);
        await sqlDb.updateData3(
          'EltlawahPlans',
          {'isSync': 1},
          'EltlawahPlanID = ?',
          [newEltlawahPlanID],
        );
        print("------------------> isSync: Sync Done!");
      } else {
        plan.isSync = 0;
        print("------------------> isSync: not Sync");
      }

      return result;
    } catch (e) {
      print("------------------> Error in addEltlawahPlan in ((planController)) : $e");
      return -1;
    }
  }

  Future<int> addIslamicStudies2(IslamicStudiesModel plan) async {
    try {
      plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
      int newIslamicStudiesID = await newId2('IslamicStudies', 'IslamicStudiesID');
      plan.islamicStudiesID = newIslamicStudiesID;

      print("----------> studentId for IslamicStudies is :${plan.studentID}");

      bool hasConnection = await InternetConnectionChecker().hasConnection;
      final Map<String, dynamic> planMap = plan.toMap();
      int result = await sqlDb.insertData2('IslamicStudies', planMap);
      print("------------------> Add IslamicStudy plan is : ${result > 0 ? 'Done' : 'Failed'}");

      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        await firebasehelper.addIslamicStudyplan(plan, newIslamicStudiesID);
        await sqlDb.updateData3(
          'IslamicStudies',
          {'isSync': 1},
          'IslamicStudiesID = ?',
          [newIslamicStudiesID],
        );
        print("------------------> isSync: Sync Done!");
      } else {
        plan.isSync = 0;
        print("------------------> isSync: not Sync");
      }

      return result;
    } catch (e) {
      print("------------------> Error in addIslamicStudies in ((planController)) : $e");
      return -1;
    }
  }

  Future<List<int>> getAllStudentsHalaga(int halagaId) async {
    final db = await sqlDb.database;
    final result = await db.query(
      'Students',
      columns: ['StudentID'],
      where: 'ElhalagatID = ?',
      whereArgs: [halagaId],
      orderBy: 'StudentID ASC',
    );
    print("-----> studentsID from DB: $result");
    return result.map((e) => e['StudentID'] as int).toList();
  }

  Future<void> clearAllPlans() async {
    try {
      await sqlDb.deleteData("DELETE FROM ConservationPlans");
      await sqlDb.deleteData("DELETE FROM EltlawahPlans");
      await sqlDb.deleteData("DELETE FROM IslamicStudies");
      print("All plans deleted successfully");
    } catch (e) {
      print("Error clearing plans: $e");
    }
  }

  Future<void> getPlans(int halagaId) async {
    try {
      final db = await sqlDb.database;

      // جلب خطط الحفظ
      final conservationResult = await db.query(
        'ConservationPlans',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
      );
      conservationPlans = conservationResult
          .map((e) => ConservationPlanModel.fromMap(e))
          .toList();

      // جلب خطط التلاوة
      final eltlawahResult = await db.query(
        'EltlawahPlans',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
      );
      eltlawahPlans = eltlawahResult
          .map((e) => EltlawahPlanModel.fromMap(e))
          .toList();

      // جلب خطط العلوم الشرعية
      final islamicResult = await db.query(
        'IslamicStudies',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
      );
      islamicStudyPlans = islamicResult
          .map((e) => IslamicStudiesModel.fromMap(e))
          .toList();

      print("-----> Loaded ${conservationPlans.length} Conservation Plans");
      print("-----> Loaded ${eltlawahPlans.length} Eltlawah Plans");
      print("-----> Loaded ${islamicStudyPlans.length} Islamic Studies Plans");
    } catch (e) {
      print("Error loading plans: $e");
      throw Exception("Failed to load plans: $e");
    }
  }

  Future<void> deletePlan(int planId, String table, String column) async {
    try {
      int result = await sqlDb.deleteData2(table, column, planId);
      if (result > 0) {
        print("-----> Deleted plan $planId from $table");
        // إزالة الخطة من القائمة المحلية
        if (table == 'ConservationPlans') {
          conservationPlans.removeWhere((plan) => plan.conservationPlanId == planId);
        } else if (table == 'EltlawahPlans') {
          eltlawahPlans.removeWhere((plan) => plan.eltlawahPlanId == planId);
        } else if (table == 'IslamicStudies') {
          islamicStudyPlans.removeWhere((plan) => plan.islamicStudiesID == planId);
        }
        // حذف من Firebase إذا كان متزامن
        bool hasConnection = await InternetConnectionChecker().hasConnection;
        if (hasConnection) {
          // await firebasehelper.deletePlan(planId.toString(), table);
        }
      } else {
        print("-----> No plan found with $column = $planId in $table");
      }
    } catch (e) {
      print("Error deleting plan from $table: $e");
      throw Exception("Failed to delete plan: $e");
    }
  }
}

PlanController planController = PlanController();