import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج لخطة الحفظ
/// 
/// يستخدم لتمثيل خطط الحفظ المخزنة في جدول ConservationPlans
/// ويدعم التحويل من/إلى SQLite وFirestore
class ConservationPlanModel {
  /// معرف خطة الحفظ الفريد
  final int? conservationPlanId;
  
  /// معرف الحلقة المرتبطة بالخطة
  final int? elhalagatId;
  
  /// آية البداية المخططة للحفظ (نص مثل "1:1" للسورة 1 الآية 1)
  final String? plannedStart;
  
  /// آية النهاية المخططة للحفظ (نص مثل "1:7" للسورة 1 الآية 7)
  final String? plannedEnd;
  
  /// آية البداية المنفذة للحفظ
  final String? executedStart;
  
  /// آية النهاية المنفذة للحفظ
  final String? executedEnd;
  
  /// نسبة تنفيذ الخطة (بين 0.0 و 1.0)
  final double? executedRate;
  
  /// الشهر المرتبط بالخطة بتنسيق "YYYY-MM"
  final String? planMonth;

  /// إنشاء نموذج خطة حفظ جديد
  const ConservationPlanModel({
    this.conservationPlanId,
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
      'ConservationPlanID': conservationPlanId,
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
  factory ConservationPlanModel.fromMap(Map<String, dynamic> map) {
    return ConservationPlanModel(
      conservationPlanId: map['ConservationPlanID'],
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
      'conservationPlanId': conservationPlanId,
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
  factory ConservationPlanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return ConservationPlanModel(
      conservationPlanId: data['conservationPlanId'],
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
  ConservationPlanModel copyWith({
    int? conservationPlanId,
    int? elhalagatId,
    String? plannedStart,
    String? plannedEnd,
    String? executedStart,
    String? executedEnd,
    double? executedRate,
    String? planMonth,
  }) {
    return ConservationPlanModel(
      conservationPlanId: conservationPlanId ?? this.conservationPlanId,
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
    return 'ConservationPlanModel(conservationPlanId: $conservationPlanId, elhalagatId: $elhalagatId, plannedStart: $plannedStart, plannedEnd: $plannedEnd, executedStart: $executedStart, executedEnd: $executedEnd, executedRate: $executedRate, planMonth: $planMonth)';
  }
}
