import 'package:cloud_firestore/cloud_firestore.dart';

class EltlawahPlanModel {
  final int? eltlawahPlanId;
  final int? elhalagatId;
  final String? plannedStartSurah;
  final int? plannedStartAya;
  final String? plannedEndSurah;
  final int? plannedEndAya;
  final String? executedStartSurah;
  final int? executedStartAya;
  final String? executedEndSurah;
  final int? executedEndAya;
  final double? executedRate;

  /// الشهر المرتبط بالخطة بتنسيق "YYYY-MM"
  final String? planMonth;
  final int? isSync;

  /// إنشاء نموذج خطة تلاوة جديد
  const EltlawahPlanModel(
      {this.eltlawahPlanId,
      required this.elhalagatId,
      required this.plannedStartSurah,
      required this.plannedStartAya,
      required this.plannedEndSurah,
      required this.plannedEndAya,
      this.executedStartSurah,
      this.executedStartAya,
      this.executedEndSurah,
      this.executedEndAya,
      this.executedRate,
      this.planMonth,
      this.isSync});

  /// تحويل النموذج إلى Map للحفظ في قاعدة بيانات SQLite
  Map<String, dynamic> toMap() {
    return {
      'EltlawahPlanID': eltlawahPlanId,
      'ElhalagatID': elhalagatId,
      'PlannedStartSurah': plannedStartSurah,
      'PlannedStartAya': plannedStartAya,
      'PlannedEndSurah': plannedEndSurah,
      'PlannedEndAya': plannedEndAya,
      'ExecuteStartSurah': executedStartSurah,
      'ExecuteStartAya': executedStartAya,
      'ExecuteEndSurah': executedEndSurah,
      'ExecuteEndAya': executedEndAya,
      'ExecutedRate': executedRate,
      'PlanMonth': planMonth,
      'isSync': isSync,
    };
  }

  /// إنشاء نموذج من Map من قاعدة بيانات SQLite
  factory EltlawahPlanModel.fromMap(Map<String, dynamic> map) {
    return EltlawahPlanModel(
        eltlawahPlanId: map['EltlawahPlanID'],
        elhalagatId: map['ElhalagatID'],
        plannedStartSurah: map['PlannedStartSurah'],
        plannedStartAya: map['PlannedStartAya'],
        plannedEndSurah: map['PlannedEndSurah'],
        plannedEndAya: map['PlannedEndAya'],
        executedStartSurah: map['ExecutedStartSurah'],
        executedStartAya: map['ExecutedStartAya'],
        executedEndSurah: map['ExecutedEndSurah'],
        executedEndAya: map['ExecutedEndAya'],
        executedRate: map['ExecutedRate'] != null
            ? (map['ExecutedRate'] as num).toDouble()
            : null,
        planMonth: map['PlanMonth'],
        isSync: map['isSync']);
  }

  /// تحويل النموذج إلى Map للحفظ في Firestore
  Map<String, dynamic> toJson() {
    return {
      'eltlawahPlanId': eltlawahPlanId,
      'elhalagatId': elhalagatId,
      'PlannedStartSurah': plannedStartSurah,
      'PlannedStartAya': plannedStartAya,
      'PlannedEndSurah': plannedEndSurah,
      'PlannedEndAya': plannedEndAya,
      'ExecuteStartSurah': executedStartSurah,
      'ExecuteStartAya': executedStartAya,
      'ExecuteEndSurah': executedEndSurah,
      'ExecuteEndAya': executedEndAya,
      'executedRate': executedRate,
      'planMonth': planMonth,
      'lastUpdated': FieldValue.serverTimestamp(),
      'isSync': isSync,
    };
  }

  /// إنشاء نموذج من DocumentSnapshot من Firestore
  // factory EltlawahPlanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  //   final data = doc.data()!;
  //
  //   return EltlawahPlanModel(
  //     eltlawahPlanId: data['eltlawahPlanId'],
  //     elhalagatId: data['elhalagatId'],
  //     plannedStart: data['plannedStart'],
  //     plannedEnd: data['plannedEnd'],
  //     executedStart: data['executedStart'],
  //     executedEnd: data['executedEnd'],
  //     executedRate: data['executedRate'],
  //     planMonth: data['planMonth'],
  //   );
  // }
}
