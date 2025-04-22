class StudentModel {
  int? studentID;
  int? elhalaqaID;
  int? schoolId;
  int? userID; // father
  String? firstName;
  String? middleName;
  String? grandfatherName;
  String? lastName;
  int? attendanceDays;
  int? absenceDays;
  String? excuse;
  String? reasonAbsence;

  StudentModel({
    this.studentID,
    this.elhalaqaID,
    this.schoolId,
    this.userID,
    this.firstName,
    this.middleName,
    this.grandfatherName,
    this.lastName,
    this.attendanceDays,
    this.absenceDays,
    this.excuse,
    this.reasonAbsence,
  });

  Map<String, dynamic> toMap() {
    return {
      'StudentID': studentID,
      'ElhalagatID': elhalaqaID,
      'SchoolID': schoolId,
      'userID': userID,
      'FirstName': firstName,
      'MiddleName': middleName,
      'grandfatherName': grandfatherName,
      'LastName': lastName,
      'AttendanceDays': attendanceDays,
      'AbsenceDays': absenceDays,
      'Excuse': excuse,
      'ReasonAbsence': reasonAbsence
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // معالجة ElhalagatID إذا كان نصاً
    int? elhalaqaID;
    if (json['ElhalagatID'] != null) {
      if (json['ElhalagatID'] is String) {
        elhalaqaID = int.tryParse(json['ElhalagatID']);
      } else {
        elhalaqaID = json['ElhalagatID'] as int?;
      }
    }

    return StudentModel(
      studentID: json['StudentID'] is String
          ? int.tryParse(json['StudentID'])
          : json['StudentID'] as int?,
      elhalaqaID: elhalaqaID,
      schoolId: json['SchoolID'] is String
          ? int.tryParse(json['SchoolID'])
          : json['SchoolID'] as int?,
      userID: json['userID'] is String
          ? int.tryParse(json['userID'])
          : json['userID'] as int?,
      firstName: json['FirstName'] as String?,
      middleName: json['MiddleName'] as String?,
      grandfatherName: json['grandfatherName'] as String?,
      lastName: json['LastName'] as String?,
      attendanceDays: json['AttendanceDays'] is String
          ? int.tryParse(json['AttendanceDays'])
          : json['AttendanceDays'] as int?,
      absenceDays: json['AbsenceDays'] is String
          ? int.tryParse(json['AbsenceDays'])
          : json['AbsenceDays'] as int?,
      excuse: json['Excuse'] as String?,
      reasonAbsence: json['ReasonAbsence'] as String?,
    );
  }
}
