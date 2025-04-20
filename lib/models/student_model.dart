class StudentModel {
  int? studentID;
  int? elhalaqaID;
  int? schoolId;
<<<<<<< HEAD
=======
  int? userID;
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
  String? firstName;
  String? middleName;
  String? grandfatherName;
  String? lastName;
  int? attendanceDays;
  int? absenceDays;
  String? excuse;
  String? reasonAbsence;

<<<<<<< HEAD
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
=======
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
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
    return {
      'StudentID': studentID,
      'ElhalagatID': elhalaqaID,
      'SchoolID': schoolId,
<<<<<<< HEAD
=======
      'userID': userID,
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
      'FirstName': firstName,
      'MiddleName': middleName,
      'grandfatherName': grandfatherName,
      'LastName': lastName,
      'AttendanceDays': attendanceDays,
      'AbsenceDays': absenceDays,
      'Excuse': excuse,
<<<<<<< HEAD
      'ReasonAbsence': reasonAbsence
=======
      'ReasonAbsence': reasonAbsence,
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
<<<<<<< HEAD
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
=======
      studentID: json['StudentID'],
      elhalaqaID: json['ElhalagatID'],
      schoolId: json['SchoolID'],
      userID: json['userID'],
      firstName: json['FirstName'],
      middleName: json['MiddleName'],
      grandfatherName: json['grandfatherName'],
      lastName: json['LastName'],
      attendanceDays: json['AttendanceDays'],
      absenceDays: json['AbsenceDays'],
      excuse: json['Excuse'],
      reasonAbsence: json['ReasonAbsence'],
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
    );
  }
}
