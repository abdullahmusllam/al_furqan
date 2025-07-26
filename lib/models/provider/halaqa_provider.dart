import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../helper/sqldb.dart';

class HalaqaProvider with ChangeNotifier {
  List<HalagaModel> halaqat = [];

  int get halaqatCount => halaqat.length;
  List<HalagaModel> get halaqatList => halaqat;

  HalaqaProvider() {
    loadedHalaqatFromLocal();
  }
  Future<bool> connected() async {
    bool conn = await InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  loadHalaqatFromFirebase() async {
    int? schoolID = perf.getInt('schoolId');
    if (await connected()) {
      await halagaController.getHalagatFromFirebaseByID(schoolID!, 'SchoolID');
      await loadedHalaqatFromLocal();
    } else {
      // print('لا يوجد اتصال بالانتلرنت');
      await loadedHalaqatFromLocal();
    }
  }

  Future<void> loadedHalaqatFromLocal() async {
    final db = await sqlDb.database;
    final List<Map<String, dynamic>> request = await db.query('Elhalagat');
    List<HalagaModel> halaqatList =
        request.map((j) => HalagaModel.fromJson(j)).toList();
    halaqat.clear();
    halaqat.addAll(halaqatList);
    // print('$halaqatList 000000000000000000000000000000');
    // print('${CurrentUser.user!.first_name}00000000000000000000000');
    notifyListeners();
    print(halaqat);
  }
}
