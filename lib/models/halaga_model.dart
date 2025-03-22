import 'dart:ffi';

class HalagaModel {
  int? halagaID;
  int? SchoolID;
  String? Name;
  int? NumberStudent;
  Double? AttendanceRate;
  String? TeacherName;

  HalagaModel(
      {this.halagaID,
      this.SchoolID,
      this.Name,
      this.NumberStudent,
      this.AttendanceRate,
      this.TeacherName});
}
