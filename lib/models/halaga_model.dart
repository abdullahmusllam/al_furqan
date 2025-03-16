import 'dart:ffi';

class HalagaModel {
  int? halagaID;
  int? SchoolID;
  String? Name;
  int? NumberStudent;
  Double? AttendanceRate;

  HalagaModel(
      {this.halagaID,
      this.SchoolID,
      this.Name,
      this.NumberStudent,
      this.AttendanceRate});
}
