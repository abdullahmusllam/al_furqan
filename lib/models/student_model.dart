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

}
