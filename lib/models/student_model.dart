class StudentModel {
  int? studentID;
  int? elhalaqaID;
  int? SchoolId;
  String? firstName;
  String? middleName;
  String? grandfatherName;
  String? lastName;
  int? AttendanceDays;
  int? AbsenceDays;
  String? Excuse;
  String? ReasonAbsence;

  StudentModel(
      {this.studentID,
      this.elhalaqaID,
      this.SchoolId,
      this.firstName,
      this.middleName,
      this.grandfatherName,
      this.lastName,
      this.AttendanceDays,
      this.AbsenceDays,
      this.Excuse,
      this.ReasonAbsence});

       Map<String, dynamic> toMap() {
    return {
      'SchoolID': SchoolId,
      'FirstName': firstName,
      'MiddleName': middleName,
      'grandfatherName': grandfatherName,
      'LastName': lastName,
    };
  }
}
