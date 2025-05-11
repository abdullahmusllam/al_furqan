import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

class PlanController {
  List<ConservationPlanModel> conservationPlans = [];
  List<EltlawahPlanModel> eltlawahPlans = [];
  List<int> studentsID=[];
  bool? connection;
  // getPlans();
  // getPlansByMonth(String month);
  Future<List<int>>getAllStudentsHalaga(int idHalaga) async {
    List<Map<String, dynamic>> studentsID =
        await sqlDb.readData("SELECT StudentID FROM Students\n"
            " WHERE ElhalagatID = ${idHalaga}");
    return studentsID.map((row) => row['StudentID'] as int).toList();
  }

  /// ====================== add new plan for EltlawahPlan , ConservationPlan & IslamicStudiesPlan Start ================================
  /// ====================== add new plan for ConservationPlan Start ================================
  Future<void> addConservationPlan(ConservationPlanModel plan) async {
    plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
    plan.conservationPlanId =
        await someController.newId("ConservationPlans", "ConservationPlanID");
    connection = await InternetConnectionChecker().hasConnection;
    try {
      // لتجتب عندما يكون الـ ( connection ) = null
      bool response = await sqlDb.checkIfitemExists(
          // check if the plan is exist
          "ConservationPlans",
          plan.conservationPlanId!,
          "ConservationPlanID");
      print(
          "------------------> ${response ? "The ConservationPlan is exist" : "checkIfitemExists Done!"}");
      if (response == false) {
        if (connection!) {
          plan.isSync = 1;

          int response =
              await sqlDb.insertData2('ConservationPlans', plan.toMap());
          print(
              "------------------> Add ConservationPlan is : ${response == 0 ? 'Failed' : 'Done'}");
          if (response > 0) {
            await firebasehelper.addConservationPlan(
                plan, plan.conservationPlanId!);
          }
          return;
        }
        plan.isSync = 0;
        int response =
            await sqlDb.insertData2('ConservationPlans', plan.toMap());
        print(
            "------------------> Add ConservationPlan is : ${response == 0 ? 'Failed' : 'Done!'}\n"
            "------------------> isSync: ${plan.isSync == 0 ? 'not Sync' : 'Sync Done!'}");
        return;
      }
      return;
    } catch (e) {
      print(
          "------------------> Error in addConservationPlan in ((planController)) : $e");
    }
  }

  /// ====================== add new plan for EltlawahPlan Start ================================
  Future<void> addEltlawahPlan(EltlawahPlanModel plan) async {
    plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
    plan.eltlawahPlanId =
        await someController.newId("EltlawahPlans", "EltlawahPlanID");
    connection = await InternetConnectionChecker().hasConnection;
    try {
      // لتجتب عندما يكون الـ ( connection ) = null
      bool response = await sqlDb.checkIfitemExists(
          "EltlawahPlans", plan.eltlawahPlanId!, "EltlawahPlanID");
      print(
          "------------------> ${response ? "The EltlawahPlan is exist" : "checkIfitemExists Done!"}");
      if (response == false) {
        if (connection!) {
          plan.isSync = 1;
          int response = await sqlDb.insertData2('EltlawahPlans', plan.toMap());
          print(
              "------------------> Add EltlawahPlan is : ${response == 0 ? 'Failed' : 'Done!'}");
          if (response > 0) {
            await firebasehelper.addEltlawahPlan(plan, plan.eltlawahPlanId!);
          }
          return;
        }
        plan.isSync = 0;
        int response = await sqlDb.insertData2('EltlawahPlans', plan.toMap());
        print(
            "------------------> Add EltlawahPlan is : ${response == 0 ? 'Failed' : 'Done!'}\n"
            "------------------> isSync: ${plan.isSync == 0 ? 'not Sync' : 'Sync Done!'}");
        return;
      }
      return;
    } catch (e) {
      print(
          "------------------> Error in addEltlawahPlan in ((planController)) : $e");
    }
  }

  /// ====================== add new plan for IslamicStudiesPlan Start ================================
  Future<void> addIslamicStudies(IslamicStudiesModel plan) async {
    plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
    plan.islamicStudiesID =
        await someController.newId("IslamicStudies", "IslamicStudiesID");
    connection = await InternetConnectionChecker().hasConnection;
    try {
      if (connection!) {
        plan.isSync = 1;
        int response = await sqlDb.insertData2('IslamicStudies', plan.toMap());
        print(
            "------------------> Add IslamicStudy plan is : ${response == 0 ? 'Failed' : 'Done!'}");
        if (response > 0) {
          await firebasehelper.addIslamicStudyplan(
              plan, plan.islamicStudiesID!);
        }
        return;
      }
      plan.isSync = 0;
      int response = await sqlDb.insertData2('IslamicStudies', plan.toMap());
      print(
          "------------------> Add EltlawahPlan is : ${response == 0 ? 'Failed' : 'Done!'}\n"
          "------------------> isSync: ${plan.isSync == 0 ? 'not Sync' : 'Sync Done!'}");
      return;
    } catch (e) {
      print(
          "------------------> Error in addEltlawahPlan in ((planController)) : $e");
    }
  }

  /// ====================== add new plan for EltlawahPlan , ConservationPlan & IslamicStudiesPlan End ================================
}

PlanController planController = PlanController();
