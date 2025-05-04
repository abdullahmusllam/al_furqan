import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج لخطة التلاوة
/// 
/// يستخدم لتمثيل خطط التلاوة المخزنة في جدول EltlawahPlans
/// ويدعم التحويل من/إلى SQLite وFirestore
class EltlawahPlanModel {
  /// معرف خطة التلاوة الفريد
  final int? eltlawahPlanId;
  
  /// معرف الحلقة المرتبطة بالخطة
  final int? elhalagatId;
  
  /// آية البداية المخططة للتلاوة (نص مثل "1:1" للسورة 1 الآية 1)
  final String? plannedStart;
  
  /// آية النهاية المخططة للتلاوة (نص مثل "1:7" للسورة 1 الآية 7)
  final String? plannedEnd;
  
  /// آية البداية المنفذة للتلاوة
  final String? executedStart;
  
  /// آية النهاية المنفذة للتلاوة
  final String? executedEnd;
  
  /// نسبة تنفيذ الخطة (بين 0.0 و 1.0)
  final double? executedRate;
  
  /// الشهر المرتبط بالخطة بتنسيق "YYYY-MM"
  final String? planMonth;

  /// إنشاء نموذج خطة تلاوة جديد
  const EltlawahPlanModel({
    this.eltlawahPlanId,
    required this.elhalagatId,
    required this.plannedStart,
    required this.plannedEnd,
    this.executedStart,
    this.executedEnd,
    this.executedRate,
    this.planMonth,
  });

  /// تحويل النموذج إلى Map للحفظ في قاعدة بيانات SQLite
  Map<String, dynamic> toMap() {
    return {
      'EltlawahPlanID': eltlawahPlanId,
      'ElhalagatID': elhalagatId,
      'StartAya': plannedStart,
      'EndAya': plannedEnd,
      'ExecutedStart': executedStart,
      'ExecutedEnd': executedEnd,
      'ExecutedRate': executedRate,
      'PlanMonth': planMonth,
    };
  }

  /// إنشاء نموذج من Map من قاعدة بيانات SQLite
  factory EltlawahPlanModel.fromMap(Map<String, dynamic> map) {
    return EltlawahPlanModel(
      eltlawahPlanId: map['EltlawahPlanID'],
      elhalagatId: map['ElhalagatID'],
      plannedStart: map['StartAya'],
      plannedEnd: map['EndAya'],
      executedStart: map['ExecutedStart'],
      executedEnd: map['ExecutedEnd'],
      executedRate: map['ExecutedRate'] != null ? (map['ExecutedRate'] as num).toDouble() : null,
      planMonth: map['PlanMonth'],
    );
  }

  /// تحويل النموذج إلى Map للحفظ في Firestore
  Map<String, dynamic> toJson() {
    return {
      'eltlawahPlanId': eltlawahPlanId,
      'elhalagatId': elhalagatId,
      'plannedStart': plannedStart,
      'plannedEnd': plannedEnd,
      'executedStart': executedStart,
      'executedEnd': executedEnd,
      'executedRate': executedRate,
      'planMonth': planMonth,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// إنشاء نموذج من DocumentSnapshot من Firestore
  factory EltlawahPlanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return EltlawahPlanModel(
      eltlawahPlanId: data['eltlawahPlanId'],
      elhalagatId: data['elhalagatId'],
      plannedStart: data['plannedStart'],
      plannedEnd: data['plannedEnd'],
      executedStart: data['executedStart'],
      executedEnd: data['executedEnd'],
      executedRate: data['executedRate'],
      planMonth: data['planMonth'],
    );
  }

  /// نسخة من النموذج مع تحديث بعض الخصائص
  EltlawahPlanModel copyWith({
    int? eltlawahPlanId,
    int? elhalagatId,
    String? plannedStart,
    String? plannedEnd,
    String? executedStart,
    String? executedEnd,
    double? executedRate,
    String? planMonth,
  }) {
    return EltlawahPlanModel(
      eltlawahPlanId: eltlawahPlanId ?? this.eltlawahPlanId,
      elhalagatId: elhalagatId ?? this.elhalagatId,
      plannedStart: plannedStart ?? this.plannedStart,
      plannedEnd: plannedEnd ?? this.plannedEnd,
      executedStart: executedStart ?? this.executedStart,
      executedEnd: executedEnd ?? this.executedEnd,
      executedRate: executedRate ?? this.executedRate,
      planMonth: planMonth ?? this.planMonth,
    );
  }

  @override
  String toString() {
    return 'EltlawahPlanModel(eltlawahPlanId: $eltlawahPlanId, elhalagatId: $elhalagatId, plannedStart: $plannedStart, plannedEnd: $plannedEnd, executedStart: $executedStart, executedEnd: $executedEnd, executedRate: $executedRate, planMonth: $planMonth)';
  }
}
