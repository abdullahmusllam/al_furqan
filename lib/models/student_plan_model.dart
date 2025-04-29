class StudentPlanModel {
  int? planId;
  int? studentId;
  int? halagaId;

  // خطة الحفظ
  String? conservationStartSurah; // سورة البداية للحفظ
  String? conservationEndSurah; // سورة النهاية للحفظ
  int? conservationStartVerse; // رقم آية البداية للحفظ
  int? conservationEndVerse; // رقم آية النهاية للحفظ

  // ما تم إنجازه من الحفظ
  String? executedConservationStartSurah; // سورة البداية المنفذة للحفظ
  String? executedConservationEndSurah; // سورة النهاية المنفذة للحفظ
  int? executedConservationStartVerse; // رقم آية البداية المنفذة للحفظ
  int? executedConservationEndVerse; // رقم آية النهاية المنفذة للحفظ

  // خطة التلاوة
  String? recitationStartSurah; // سورة البداية للتلاوة
  String? recitationEndSurah; // سورة النهاية للتلاوة
  int? recitationStartVerse; // رقم آية البداية للتلاوة
  int? recitationEndVerse; // رقم آية النهاية للتلاوة

  // ما تم إنجازه من التلاوة
  String? executedRecitationStartSurah; // سورة البداية المنفذة للتلاوة
  String? executedRecitationEndSurah; // سورة النهاية المنفذة للتلاوة
  int? executedRecitationStartVerse; // رقم آية البداية المنفذة للتلاوة
  int? executedRecitationEndVerse; // رقم آية النهاية المنفذة للتلاوة

  // نسب الإنجاز
  double? conservationCompletionRate; // نسبة إنجاز الحفظ
  double? recitationCompletionRate; // نسبة إنجاز التلاوة

  // تاريخ آخر تحديث
  String? lastUpdated;

  // ملاحظات المعلم
  String? teacherNotes;

  StudentPlanModel({
    this.planId,
    this.studentId,
    this.halagaId,
    this.conservationStartSurah,
    this.conservationEndSurah,
    this.conservationStartVerse,
    this.conservationEndVerse,
    this.executedConservationStartSurah,
    this.executedConservationEndSurah,
    this.executedConservationStartVerse,
    this.executedConservationEndVerse,
    this.recitationStartSurah,
    this.recitationEndSurah,
    this.recitationStartVerse,
    this.recitationEndVerse,
    this.executedRecitationStartSurah,
    this.executedRecitationEndSurah,
    this.executedRecitationStartVerse,
    this.executedRecitationEndVerse,
    this.conservationCompletionRate,
    this.recitationCompletionRate,
    this.lastUpdated,
    this.teacherNotes,
  });

  // تحويل النموذج إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'studentId': studentId,
      'halagaId': halagaId,
      'conservationStartSurah': conservationStartSurah,
      'conservationEndSurah': conservationEndSurah,
      'conservationStartVerse': conservationStartVerse,
      'conservationEndVerse': conservationEndVerse,
      'executedConservationStartSurah': executedConservationStartSurah,
      'executedConservationEndSurah': executedConservationEndSurah,
      'executedConservationStartVerse': executedConservationStartVerse,
      'executedConservationEndVerse': executedConservationEndVerse,
      'recitationStartSurah': recitationStartSurah,
      'recitationEndSurah': recitationEndSurah,
      'recitationStartVerse': recitationStartVerse,
      'recitationEndVerse': recitationEndVerse,
      'executedRecitationStartSurah': executedRecitationStartSurah,
      'executedRecitationEndSurah': executedRecitationEndSurah,
      'executedRecitationStartVerse': executedRecitationStartVerse,
      'executedRecitationEndVerse': executedRecitationEndVerse,
      'conservationCompletionRate': conservationCompletionRate,
      'recitationCompletionRate': recitationCompletionRate,
      'lastUpdated': lastUpdated,
      'teacherNotes': teacherNotes,
    };
  }

  // إنشاء نموذج من Map من قاعدة البيانات
  factory StudentPlanModel.fromMap(Map<String, dynamic> map) {
    return StudentPlanModel(
      planId: map['planId'] as int?,
      studentId: map['studentId'] as int?,
      halagaId: map['halagaId'] as int?,
      conservationStartSurah: map['conservationStartSurah'] as String?,
      conservationEndSurah: map['conservationEndSurah'] as String?,
      conservationStartVerse: map['conservationStartVerse'] as int?,
      conservationEndVerse: map['conservationEndVerse'] as int?,
      executedConservationStartSurah:
          map['executedConservationStartSurah'] as String?,
      executedConservationEndSurah:
          map['executedConservationEndSurah'] as String?,
      executedConservationStartVerse:
          map['executedConservationStartVerse'] as int?,
      executedConservationEndVerse: map['executedConservationEndVerse'] as int?,
      recitationStartSurah: map['recitationStartSurah'] as String?,
      recitationEndSurah: map['recitationEndSurah'] as String?,
      recitationStartVerse: map['recitationStartVerse'] as int?,
      recitationEndVerse: map['recitationEndVerse'] as int?,
      executedRecitationStartSurah:
          map['executedRecitationStartSurah'] as String?,
      executedRecitationEndSurah: map['executedRecitationEndSurah'] as String?,
      executedRecitationStartVerse: map['executedRecitationStartVerse'] as int?,
      executedRecitationEndVerse: map['executedRecitationEndVerse'] as int?,
      conservationCompletionRate: map['conservationCompletionRate'] as double?,
      recitationCompletionRate: map['recitationCompletionRate'] as double?,
      lastUpdated: map['lastUpdated'] as String?,
      teacherNotes: map['teacherNotes'] as String?,
    );
  }

  // حساب نسبة إنجاز الحفظ
  void calculateConservationRate() {
    if (conservationStartSurah == null ||
        conservationEndSurah == null ||
        executedConservationStartSurah == null ||
        executedConservationEndSurah == null) {
      conservationCompletionRate = 0.0;
      return;
    }

    // هنا يمكن إضافة حساب أكثر دقة للنسبة اعتماداً على أرقام السور والآيات
    // كمثال بسيط: إذا وصل الطالب إلى نهاية السورة المستهدفة، تكون النسبة 100%
    if (executedConservationEndSurah == conservationEndSurah &&
        (executedConservationEndVerse ?? 0) >= (conservationEndVerse ?? 0)) {
      conservationCompletionRate = 100.0;
    } else {
      // حساب تقريبي بناءً على أسماء السور (يمكن تحسينه باستخدام فهرس السور)
      // هذا مجرد مثال بسيط
      conservationCompletionRate = 50.0;
    }
  }

  // حساب نسبة إنجاز التلاوة
  void calculateRecitationRate() {
    if (recitationStartSurah == null ||
        recitationEndSurah == null ||
        executedRecitationStartSurah == null ||
        executedRecitationEndSurah == null) {
      recitationCompletionRate = 0.0;
      return;
    }

    // مبدأ مشابه لحساب نسبة الحفظ
    if (executedRecitationEndSurah == recitationEndSurah &&
        (executedRecitationEndVerse ?? 0) >= (recitationEndVerse ?? 0)) {
      recitationCompletionRate = 100.0;
    } else {
      // حساب تقريبي
      recitationCompletionRate = 50.0;
    }
  }
}
