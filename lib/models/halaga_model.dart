import 'dart:ffi';

class HalagaModel {
  int? halagaID;
  int? SchoolID;
  String? Name;
  int? NumberStudent;
  Double? AttendanceRate;
  String? TeacherName;

  // خطة الحفظ
  String? conservationPlanStart; // تاريخ البداية
  String? conservationPlanEnd; // تاريخ النهاية
  String? conservationStartSurah; // سورة البداية للحفظ
  String? conservationEndSurah; // سورة النهاية للحفظ
  int? conservationStartVerse; // رقم آية البداية للحفظ
  int? conservationEndVerse; // رقم آية النهاية للحفظ

  // خطة التلاوة
  String? recitationPlanStart; // تاريخ البداية
  String? recitationPlanEnd; // تاريخ النهاية
  String? recitationStartSurah; // سورة البداية للتلاوة
  String? recitationEndSurah; // سورة النهاية للتلاوة
  int? recitationStartVerse; // رقم آية البداية للتلاوة
  int? recitationEndVerse; // رقم آية النهاية للتلاوة

  // منفذ التلاوة
  String? executedStartSurah; // سورة البداية للتلاوة المنفذة
  String? executedEndSurah; // سورة النهاية للتلاوة المنفذة
  int? executedStartVerse; // رقم آية البداية للتلاوة المنفذة
  int? executedEndVerse; // رقم آية النهاية للتلاوة المنفذة

  // العلوم الشرعية
  String?
      islamicStudiesSubject; // المقرر (التفسير، الحديث، القصص، السيرة النبوية)
  String? islamicStudiesContent; // المحتوى المخطط
  String? executedIslamicContent; // المحتوى المنفذ
  String? islamicExecutionReason; // أسباب التأخير المنهاج

  HalagaModel({
    this.halagaID,
    this.SchoolID,
    this.Name,
    this.NumberStudent,
    this.AttendanceRate,
    this.TeacherName,
    this.conservationPlanStart,
    this.conservationPlanEnd,
    this.conservationStartSurah,
    this.conservationEndSurah,
    this.conservationStartVerse,
    this.conservationEndVerse,
    this.recitationPlanStart,
    this.recitationPlanEnd,
    this.recitationStartSurah,
    this.recitationEndSurah,
    this.recitationStartVerse,
    this.recitationEndVerse,
    this.executedStartSurah,
    this.executedEndSurah,
    this.executedStartVerse,
    this.executedEndVerse,
    this.islamicStudiesSubject,
    this.islamicStudiesContent,
    this.executedIslamicContent,
    this.islamicExecutionReason,
  });
}
