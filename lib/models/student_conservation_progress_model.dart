import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج لتتبع تقدم الطالب في خطة الحفظ
/// 
/// يستخدم لتمثيل تقدم الطلاب في الحفظ المخزن في جدول StudentConservationProgress
/// ويدعم التحويل من/إلى SQLite وFirestore
class StudentConservationProgressModel {
  /// معرف تقدم الطالب الفريد
  final int? studentProgressId;
  
  /// معرف الطالب
  final int studentId;
  
  /// معرف خطة الحفظ
  final int conservationPlanId;
  
  /// الآية التي بدأ الطالب الحفظ منها (نص مثل "1:1" للسورة 1 الآية 1)
  final String executedStart;
  
  /// الآية التي انتهى الطالب من حفظها (نص مثل "1:7" للسورة 1 الآية 7)
  final String executedEnd;
  
  /// نسبة التنفيذ المحسوبة (بين 0.0 و 1.0)
  final double executedRate;
  
  /// الشهر المرتبط بالتقدم بتنسيق "YYYY-MM"
  final String planMonth;

  /// إنشاء نموذج تقدم حفظ جديد للطالب
  const StudentConservationProgressModel({
    this.studentProgressId,
    required this.studentId,
    required this.conservationPlanId,
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
      'ConservationPlanID': conservationPlanId,
      'ExecutedStart': executedStart,
      'ExecutedEnd': executedEnd,
      'ExecutedRate': executedRate,
      'PlanMonth': planMonth,
    };
  }

  /// إنشاء نموذج من Map من قاعدة بيانات SQLite
  factory StudentConservationProgressModel.fromMap(Map<String, dynamic> map) {
    return StudentConservationProgressModel(
      studentProgressId: map['StudentProgressID'],
      studentId: map['StudentID'],
      conservationPlanId: map['ConservationPlanID'],
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
      'conservationPlanId': conservationPlanId,
      'executedStart': executedStart,
      'executedEnd': executedEnd,
      'executedRate': executedRate,
      'planMonth': planMonth,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// إنشاء نموذج من DocumentSnapshot من Firestore
  factory StudentConservationProgressModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return StudentConservationProgressModel(
      studentProgressId: data['studentProgressId'],
      studentId: data['studentId'],
      conservationPlanId: data['conservationPlanId'],
      executedStart: data['executedStart'] ?? '',
      executedEnd: data['executedEnd'] ?? '',
      executedRate: data['executedRate'] ?? 0.0,
      planMonth: data['planMonth'] ?? '',
    );
  }

  /// نسخة من النموذج مع تحديث بعض الخصائص
  StudentConservationProgressModel copyWith({
    int? studentProgressId,
    int? studentId,
    int? conservationPlanId,
    String? executedStart,
    String? executedEnd,
    double? executedRate,
    String? planMonth,
  }) {
    return StudentConservationProgressModel(
      studentProgressId: studentProgressId ?? this.studentProgressId,
      studentId: studentId ?? this.studentId,
      conservationPlanId: conservationPlanId ?? this.conservationPlanId,
      executedStart: executedStart ?? this.executedStart,
      executedEnd: executedEnd ?? this.executedEnd,
      executedRate: executedRate ?? this.executedRate,
      planMonth: planMonth ?? this.planMonth,
    );
  }

  @override
  String toString() {
    return 'StudentConservationProgressModel(studentProgressId: $studentProgressId, studentId: $studentId, conservationPlanId: $conservationPlanId, executedStart: $executedStart, executedEnd: $executedEnd, executedRate: $executedRate, planMonth: $planMonth)';
  }
}
