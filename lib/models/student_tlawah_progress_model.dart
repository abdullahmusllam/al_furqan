import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج لتتبع تقدم الطالب في خطة التلاوة
/// 
/// يستخدم لتمثيل تقدم الطلاب في التلاوة المخزن في جدول StudentTlawahProgress
/// ويدعم التحويل من/إلى SQLite وFirestore
class StudentTlawahProgressModel {
  /// معرف تقدم الطالب الفريد
  final int? studentProgressId;
  
  /// معرف الطالب
  final int studentId;
  
  /// معرف خطة التلاوة
  final int eltlawahPlanId;
  
  /// الآية التي بدأ الطالب التلاوة منها (نص مثل "1:1" للسورة 1 الآية 1)
  final String executedStart;
  
  /// الآية التي انتهى الطالب من تلاوتها (نص مثل "1:7" للسورة 1 الآية 7)
  final String executedEnd;
  
  /// نسبة التنفيذ المحسوبة (بين 0.0 و 1.0)
  final double executedRate;
  
  /// الشهر المرتبط بالتقدم بتنسيق "YYYY-MM"
  final String planMonth;

  /// إنشاء نموذج تقدم تلاوة جديد للطالب
  const StudentTlawahProgressModel({
    this.studentProgressId,
    required this.studentId,
    required this.eltlawahPlanId,
    required this.executedStart,
    required this.executedEnd,
    required this.executedRate,
    required this.planMonth,
  });

  /// تحويل النموذج إلى Map للحفظ في قاعدة بيانات SQLite
  Map<String, dynamic> toMap() {
    return {
      'StudentProgressID': studentProgressId,
      'StudentID': studentId,
      'EltlawahPlanID': eltlawahPlanId,
      'ExecutedStart': executedStart,
      'ExecutedEnd': executedEnd,
      'ExecutedRate': executedRate,
      'PlanMonth': planMonth,
    };
  }

  /// إنشاء نموذج من Map من قاعدة بيانات SQLite
  factory StudentTlawahProgressModel.fromMap(Map<String, dynamic> map) {
    return StudentTlawahProgressModel(
      studentProgressId: map['StudentProgressID'],
      studentId: map['StudentID'],
      eltlawahPlanId: map['EltlawahPlanID'],
      executedStart: map['ExecutedStart'] ?? '',
      executedEnd: map['ExecutedEnd'] ?? '',
      executedRate: map['ExecutedRate'] != null ? (map['ExecutedRate'] as num).toDouble() : 0.0,
      planMonth: map['PlanMonth'] ?? '',
    );
  }

  /// تحويل النموذج إلى Map للحفظ في Firestore
  Map<String, dynamic> toJson() {
    return {
      'studentProgressId': studentProgressId,
      'studentId': studentId,
      'eltlawahPlanId': eltlawahPlanId,
      'executedStart': executedStart,
      'executedEnd': executedEnd,
      'executedRate': executedRate,
      'planMonth': planMonth,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// إنشاء نموذج من DocumentSnapshot من Firestore
  factory StudentTlawahProgressModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return StudentTlawahProgressModel(
      studentProgressId: data['studentProgressId'],
      studentId: data['studentId'],
      eltlawahPlanId: data['eltlawahPlanId'],
      executedStart: data['executedStart'] ?? '',
      executedEnd: data['executedEnd'] ?? '',
      executedRate: data['executedRate'] ?? 0.0,
      planMonth: data['planMonth'] ?? '',
    );
  }

  /// نسخة من النموذج مع تحديث بعض الخصائص
  StudentTlawahProgressModel copyWith({
    int? studentProgressId,
    int? studentId,
    int? eltlawahPlanId,
    String? executedStart,
    String? executedEnd,
    double? executedRate,
    String? planMonth,
  }) {
    return StudentTlawahProgressModel(
      studentProgressId: studentProgressId ?? this.studentProgressId,
      studentId: studentId ?? this.studentId,
      eltlawahPlanId: eltlawahPlanId ?? this.eltlawahPlanId,
      executedStart: executedStart ?? this.executedStart,
      executedEnd: executedEnd ?? this.executedEnd,
      executedRate: executedRate ?? this.executedRate,
      planMonth: planMonth ?? this.planMonth,
    );
  }

  @override
  String toString() {
    return 'StudentTlawahProgressModel(studentProgressId: $studentProgressId, studentId: $studentId, eltlawahPlanId: $eltlawahPlanId, executedStart: $executedStart, executedEnd: $executedEnd, executedRate: $executedRate, planMonth: $planMonth)';
  }
}
