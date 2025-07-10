class Student {
  final String studentID; // معرف الطالب
  final String firstName; // الاسم الأول
  final String middleName; // الاسم الأوسط
  final String lastName; // الاسم الأخير
  final String grandfatherName; // اسم الجد
  final int? schoolID; // معرف المدرسة
  final int? elhalagatID; // معرف الحلقة
  final int? attendanceDays; // أيام الحضور
  final int? absenceDays; // أيام الغياب
  final String excuse; // عذر الغياب
  final String reasonAbsence; // سبب الغياب
  final int isSync; // حالة المزامنة
  final String userID; // معرف المستخدم (ولي الأمر)

  // الحصول على الاسم الكامل للطالب
  String get fullName => '$firstName $middleName $lastName';

  Student({
    required this.studentID,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.grandfatherName,
    this.schoolID,
    this.elhalagatID,
    this.attendanceDays,
    this.absenceDays,
    required this.excuse,
    required this.reasonAbsence,
    required this.isSync,
    required this.userID,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentID: map['StudentID'] ?? '',
      firstName: map['FirstName'] ?? '',
      middleName: map['MiddleName'] ?? '',
      lastName: map['LastName'] ?? '',
      grandfatherName: map['grandfatherName'] ?? '',
      schoolID: map['SchoolID'],
      elhalagatID: map['ElhalagatID'],
      attendanceDays: map['AttendanceDays'],
      absenceDays: map['AbsenceDays'],
      excuse: map['Excuse'] ?? '',
      reasonAbsence: map['ReasonAbsence'] ?? '',
      isSync: map['isSync'] ?? 0,
      userID: map['userID'] ?? '',
    );
  }

  // تحويل الكائن إلى Map للتخزين في Firestore
  Map<String, dynamic> toMap() {
    return {
      'StudentID': studentID,
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'grandfatherName': grandfatherName,
      'SchoolID': schoolID,
      'ElhalagatID': elhalagatID,
      'AttendanceDays': attendanceDays,
      'AbsenceDays': absenceDays,
      'Excuse': excuse,
      'ReasonAbsence': reasonAbsence,
      'isSync': isSync,
      'userID': userID,
    };
  }
}
