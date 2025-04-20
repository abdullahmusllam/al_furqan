class StudentModel {
  int? studentID;
  int? elhalaqaID;
  int? schoolId;
  String? firstName;
  String? middleName;
  String? grandfatherName;
  String? lastName;
  int? attendanceDays;
  int? absenceDays;
  String? excuse;
  String? reasonAbsence;

  StudentModel(
      {this.studentID,
      this.elhalaqaID,
      this.schoolId,
      this.firstName,
      this.middleName,
      this.grandfatherName,
      this.lastName,
      this.attendanceDays,
      this.absenceDays,
      this.excuse,
      this.reasonAbsence});
    Map<String, dynamic> toMap() {
    return {
      'StudentID': studentID,
      'ElhalagatID': elhalaqaID,
      'SchoolID': schoolId,
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
    return StudentModel(
      studentID: json['StudentID'] as int?,
      elhalaqaID: json['ElhalagatID'] as int?,
      schoolId: json['SchoolID'] as int?,
      firstName: json['FirstName'] as String?,
      middleName: json['MiddleName'] as String?,
      grandfatherName: json['grandfatherName'] as String?,
      lastName: json['LastName'] as String?,
      attendanceDays: json['AttendanceDays'] as int?,
      absenceDays: json['AbsenceDays'] as int?,
      excuse: json['Excuse'] as String?,
      reasonAbsence: json['ReasonAbsence'] as String?,
    );
  }
}
