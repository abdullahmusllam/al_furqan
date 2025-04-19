class StudentModel {
  int? studentID;
  int? elhalaqaID;
  int? schoolId;
  int? userID;
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
      this.userID,
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
    return StudentModel(
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
        reasonAbsence: json['ReasonAbsence']);
  }
}
