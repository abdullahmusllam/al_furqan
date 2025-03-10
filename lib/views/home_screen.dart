// import 'package:al_furqan/views/SchoolDirector/SchoolDirectorHome.dart';
// import 'package:al_furqan/views/SchoolDirector/TeachersAttendance.dart';
// import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
// import 'package:al_furqan/views/Teacher/AddIslamicStudiesPlanPage.dart';
// import 'package:al_furqan/views/Teacher/activitiesOfficer.dart';
// import 'package:al_furqan/views/Teacher/addStusentData.dart';
// import 'package:al_furqan/views/Teacher/mainTeacher.dart';
// import 'package:al_furqan/views/Teacher/privateActivity.dart';
// import 'package:al_furqan/views/Teacher/studentListPage.dart';
// import 'package:al_furqan/widgets/custom_button.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(" عشان التجربة واجهات جمعية الفرقان"),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment:
//                 MainAxisAlignment.center, // توسيط العناصر عموديًا
//             children: [
//               CustomButton(
//                 label: "قائمة الطلاب",
//                 destination: StudentsListPage(),
//                 color: Colors.blue,
//               ),
//               // CustomButton(
//               //   label: "تفاصيل الطالب",
//               //   destination: StudentDetailsPage(),
//               //   color: Colors.green,
//               // ),
//               CustomButton(
//                 label: "إضافة خطة إسلامية",
//                 destination: AddIslamicStudiesPlanPage(),
//                 color: Colors.teal,
//               ),
//               CustomButton(
//                 label: "الأستاذ",
//                 destination: TeacherDashboard(),
//                 color: Colors.orange,
//               ),
//               CustomButton(
//                 label: "إضافة بيانات طالب",
//                 destination: AddStudentPage(),
//                 color: Colors.red,
//               ),
//               CustomButton(
//                 label: "الانشطة",
//                 destination: ActivityListScreen(),
//                 color: Colors.red,
//               ),
//               CustomButton(
//                 label: "مسؤول الانشطة",
//                 destination: StatisticsScreen(),
//                 color: Colors.red,
//               ),
//               CustomButton(
//                 label: "المشرف",
//                 destination: DashboardScreen(),
//                 color: Colors.red,
//               ),
//               CustomButton(
//                 label: "مدير المدرسة",
//                 destination: SchoolManagerScreen(),
//                 color: Colors.red,
//               ),
//               CustomButton(
//                 label: "تحضير المعلمين",
//                 destination: AttendanceScreen(),
//                 color: Colors.red,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
