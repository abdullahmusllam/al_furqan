
class HalagaModel {
  int? halagaID;
  int? SchoolID;
  String? Name;
  int? NumberStudent;
  double? AttendanceRate;
  String? TeacherName;

  HalagaModel({
    this.halagaID,
    this.SchoolID,
    this.Name,
    this.NumberStudent,
    this.AttendanceRate,
    this.TeacherName,
  });

  factory HalagaModel.fromJson(Map<String, dynamic> json) {
    return HalagaModel(
      halagaID: json['halagaID'],
      SchoolID: json['SchoolID'],
      Name: json['Name'],
      NumberStudent: json['NumberStudent'],
      AttendanceRate: json['AttendanceRate'],
      TeacherName: json['TeacherName'],
    );
  }
}
