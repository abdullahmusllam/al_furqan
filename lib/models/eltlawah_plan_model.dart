import 'package:cloud_firestore/cloud_firestore.dart';

class EltlawahPlanModel {
  int? eltlawahPlanId;
  int? elhalagatId;
  int? studentId;
  String? plannedStartSurah;
  int? plannedStartAya;
  String? plannedEndSurah;
  int? plannedEndAya;
  String? executedStartSurah;
  int? executedStartAya;
  String? executedEndSurah;
  int? executedEndAya;
  double? executedRate;

  /// الشهر المرتبط بالخطة بتنسيق "YYYY-MM"
  String? planMonth;
  int? isSync;

  /// إنشاء نموذج خطة تلاوة جديد
  EltlawahPlanModel(
      {this.eltlawahPlanId,
      required this.elhalagatId,
      required this.studentId,
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
      'StudentID': studentId,
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
        studentId: map['StudentID'],
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
}
