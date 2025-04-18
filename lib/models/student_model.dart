import 'package:al_furqan/views/SchoolDirector/TeachersAttendance.dart';

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
      'StudentID': studentID,
      'ElhalagatID': elhalaqaID,
      'SchoolID': SchoolId,
      'FirstName': firstName,
      'MiddleName': middleName,
      'grandfatherName': grandfatherName,
      'LastName': lastName,
      'AttendanceDays': AttendanceDays,
      'AbsenceDays': AbsenceDays,
      'Excuse': Excuse,
      'ReasonAbsence': ReasonAbsence
    };
  }

   factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentID: json['StudentID'],
      elhalaqaID: json['ElhalagatID'],
      SchoolId: json['SchoolID'],
      firstName: json['FirstName'],
      middleName: json['MiddleName'],
      grandfatherName: json['grandfatherName'],
      lastName: json['LastName'],
      AttendanceDays: json['AttendanceDays'],
      AbsenceDays: json['AbsenceDays'],
      Excuse: json['Excuse'],
      ReasonAbsence: json['ReasonAbsence']
    );
  }
}
