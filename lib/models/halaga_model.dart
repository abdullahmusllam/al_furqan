class HalagaModel {
  int? halagaID;
  int? SchoolID;
  String? Name;
  int? NumberStudent;
  double? AttendanceRate;
  String? TeacherName;
  int? isSync;

  HalagaModel(
      {this.halagaID,
      this.SchoolID,
      this.Name,
      this.NumberStudent,
      this.AttendanceRate,
      this.TeacherName,
      this.isSync});

  factory HalagaModel.fromJson(Map<String, dynamic> json) {
    return HalagaModel(
      halagaID: json['halagaID'],
      SchoolID: json['SchoolID'],
      Name: json['Name'],
      NumberStudent: json['NumberStudent'],
      AttendanceRate: json['AttendanceRate'],
      TeacherName: json['TeacherName'],
      isSync: json['isSync'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'halagaID': halagaID,
      'SchoolID': SchoolID,
      'Name': Name,
      'NumberStudent': NumberStudent,
      'AttendanceRate': AttendanceRate,
      'TeacherName': TeacherName,
      'isSync': isSync,
    };
  }
}
