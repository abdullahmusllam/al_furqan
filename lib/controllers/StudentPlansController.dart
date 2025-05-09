// import 'package:al_furqan/helper/sqldb.dart';
// import 'package:al_furqan/models/student_plan_model.dart';
// import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';

// class StudentPlansController {
//   final SqlDb _sqlDb = SqlDb();
//   List<StudentPlanModel> studentPlans = [];

//   // جلب خطة طالب محدد
//   Future<StudentPlanModel?> getStudentPlan(int studentId) async {
//     try {
//       List<Map<String, dynamic>> response = await _sqlDb
//           .readData("SELECT * FROM StudentPlans WHERE studentId = $studentId");

//       if (response.isEmpty) {
//         print("لا توجد خطة للطالب رقم $studentId");
//         return null;
//       }

//       StudentPlanModel plan = StudentPlanModel.fromMap(response[0]);

//       // حساب نسب الإنجاز
//       plan.calculateConservationRate();
//       plan.calculateRecitationRate();

//       return plan;
//     } catch (e) {
//       print("خطأ في جلب خطة الطالب: $e");
//       return null;
//     }
//   }

//   // جلب خطط جميع طلاب حلقة معينة
//   Future<List<StudentPlanModel>> getHalagaStudentsPlans(int halagaId) async {
//     try {
//       List<Map<String, dynamic>> response = await _sqlDb
//           .readData("SELECT * FROM StudentPlans WHERE halagaId = $halagaId");

//       studentPlans =
//           response.map((plan) => StudentPlanModel.fromMap(plan)).toList();

//       // حساب نسب الإنجاز لجميع الخطط
//       for (var plan in studentPlans) {
//         plan.calculateConservationRate();
//         plan.calculateRecitationRate();
//       }

//       return studentPlans;
//     } catch (e) {
//       print("خطأ في جلب خطط طلاب الحلقة: $e");
//       return [];
//     }
//   }

//   // إضافة أو تحديث خطة لطالب
//   Future<bool> saveStudentPlan(StudentPlanModel plan) async {
//     try {
//       // تعيين تاريخ آخر تحديث
//       plan.lastUpdated =
//           DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

//       // حساب نسب الإنجاز
//       plan.calculateConservationRate();
//       plan.calculateRecitationRate();

//       // التحقق مما إذا كانت الخطة موجودة بالفعل
//       List<Map<String, dynamic>> check = await _sqlDb.readData(
//           "SELECT * FROM StudentPlans WHERE studentId = ${plan.studentId}");

//       if (check.isEmpty) {
//         // إنشاء خطة جديدة
//         int response = await _sqlDb.insertData('''
//           INSERT INTO StudentPlans (
//             studentId, halagaId, 
//             conservationStartSurah, conservationEndSurah, conservationStartVerse, conservationEndVerse,
//             executedConservationStartSurah, executedConservationEndSurah, executedConservationStartVerse, executedConservationEndVerse,
//             recitationStartSurah, recitationEndSurah, recitationStartVerse, recitationEndVerse,
//             executedRecitationStartSurah, executedRecitationEndSurah, executedRecitationStartVerse, executedRecitationEndVerse,
//             conservationCompletionRate, recitationCompletionRate, lastUpdated, teacherNotes
//           ) VALUES (
//             ${plan.studentId}, ${plan.halagaId},
//             '${plan.conservationStartSurah ?? ''}', '${plan.conservationEndSurah ?? ''}', ${plan.conservationStartVerse ?? 'NULL'}, ${plan.conservationEndVerse ?? 'NULL'},
//             '${plan.executedConservationStartSurah ?? ''}', '${plan.executedConservationEndSurah ?? ''}', ${plan.executedConservationStartVerse ?? 'NULL'}, ${plan.executedConservationEndVerse ?? 'NULL'},
//             '${plan.recitationStartSurah ?? ''}', '${plan.recitationEndSurah ?? ''}', ${plan.recitationStartVerse ?? 'NULL'}, ${plan.recitationEndVerse ?? 'NULL'},
//             '${plan.executedRecitationStartSurah ?? ''}', '${plan.executedRecitationEndSurah ?? ''}', ${plan.executedRecitationStartVerse ?? 'NULL'}, ${plan.executedRecitationEndVerse ?? 'NULL'},
//             ${plan.conservationCompletionRate ?? 0}, ${plan.recitationCompletionRate ?? 0}, '${plan.lastUpdated}', '${plan.teacherNotes ?? ''}'
//           )
//         ''');

//         plan.planId = response; // تعيين معرف الخطة المنشأة
//         return response > 0;
//       } else {
//         // تحديث خطة موجودة
//         int planId = check[0]['planId'] as int;
//         int response = await _sqlDb.updateData('''
//           UPDATE StudentPlans SET
//             halagaId = ${plan.halagaId},
//             conservationStartSurah = '${plan.conservationStartSurah ?? ''}',
//             conservationEndSurah = '${plan.conservationEndSurah ?? ''}',
//             conservationStartVerse = ${plan.conservationStartVerse ?? 'NULL'},
//             conservationEndVerse = ${plan.conservationEndVerse ?? 'NULL'},
//             executedConservationStartSurah = '${plan.executedConservationStartSurah ?? ''}',
//             executedConservationEndSurah = '${plan.executedConservationEndSurah ?? ''}',
//             executedConservationStartVerse = ${plan.executedConservationStartVerse ?? 'NULL'},
//             executedConservationEndVerse = ${plan.executedConservationEndVerse ?? 'NULL'},
//             recitationStartSurah = '${plan.recitationStartSurah ?? ''}',
//             recitationEndSurah = '${plan.recitationEndSurah ?? ''}',
//             recitationStartVerse = ${plan.recitationStartVerse ?? 'NULL'},
//             recitationEndVerse = ${plan.recitationEndVerse ?? 'NULL'},
//             executedRecitationStartSurah = '${plan.executedRecitationStartSurah ?? ''}',
//             executedRecitationEndSurah = '${plan.executedRecitationEndSurah ?? ''}',
//             executedRecitationStartVerse = ${plan.executedRecitationStartVerse ?? 'NULL'},
//             executedRecitationEndVerse = ${plan.executedRecitationEndVerse ?? 'NULL'},
//             conservationCompletionRate = ${plan.conservationCompletionRate ?? 0},
//             recitationCompletionRate = ${plan.recitationCompletionRate ?? 0},
//             lastUpdated = '${plan.lastUpdated}',
//             teacherNotes = '${plan.teacherNotes ?? ''}'
//           WHERE planId = $planId
//         ''');

//         return response > 0;
//       }
//     } catch (e) {
//       print("خطأ في حفظ خطة الطالب: $e");
//       return false;
//     }
//   }

//   // حذف خطة طالب
//   Future<bool> deleteStudentPlan(int planId) async {
//     try {
//       int response = await _sqlDb
//           .deleteData("DELETE FROM StudentPlans WHERE planId = $planId");
//       return response > 0;
//     } catch (e) {
//       print("خطأ في حذف خطة الطالب: $e");
//       return false;
//     }
//   }

//   // إنشاء جدول خطط الطلاب إذا لم يكن موجوداً
//   Future<void> createTableIfNotExists() async {
//     try {
//       Database db = await _sqlDb.database;
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS StudentPlans (
//           planId INTEGER PRIMARY KEY AUTOINCREMENT,
//           studentId INTEGER,
//           halagaId INTEGER,
//           conservationStartSurah TEXT,
//           conservationEndSurah TEXT,
//           conservationStartVerse INTEGER,
//           conservationEndVerse INTEGER,
//           executedConservationStartSurah TEXT,
//           executedConservationEndSurah TEXT,
//           executedConservationStartVerse INTEGER,
//           executedConservationEndVerse INTEGER,
//           recitationStartSurah TEXT,
//           recitationEndSurah TEXT,
//           recitationStartVerse INTEGER,
//           recitationEndVerse INTEGER,
//           executedRecitationStartSurah TEXT,
//           executedRecitationEndSurah TEXT,
//           executedRecitationStartVerse INTEGER,
//           executedRecitationEndVerse INTEGER,
//           conservationCompletionRate REAL,
//           recitationCompletionRate REAL,
//           lastUpdated TEXT,
//           teacherNotes TEXT,
//           FOREIGN KEY (studentId) REFERENCES Students(StudentID),
//           FOREIGN KEY (halagaId) REFERENCES Elhalagat(halagaID)
//         )
//       ''');
//       print("تم إنشاء جدول StudentPlans بنجاح أو التحقق من وجوده");
//     } catch (e) {
//       print("خطأ في إنشاء جدول StudentPlans: $e");
//     }
//   }

//   // إنشاء خطة جماعية لجميع طلاب الحلقة
//   Future<bool> createBulkPlansForHalaga(
//       int halagaId, StudentPlanModel templatePlan, List<int> studentIds) async {
//     try {
//       Database db = await _sqlDb.database;

//       // استخدام المعاملة لضمان إنشاء جميع الخطط بنجاح أو فشل العملية بالكامل
//       await db.transaction((txn) async {
//         // حذف الخطط القديمة إذا وجدت
//         for (int studentId in studentIds) {
//           await txn.delete(
//             'StudentPlans',
//             where: 'halagaId = ? AND studentId = ?',
//             whereArgs: [halagaId, studentId],
//           );
//         }

//         // إنشاء خطط جديدة
//         for (int studentId in studentIds) {
//           // إنشاء خطة جديدة لكل طالب باستخدام القالب
//           Map<String, dynamic> planData = {
//             'halagaId': halagaId,
//             'studentId': studentId,
//             'conservationStartSurah': templatePlan.conservationStartSurah,
//             'conservationEndSurah': templatePlan.conservationEndSurah,
//             'conservationStartVerse': templatePlan.conservationStartVerse,
//             'conservationEndVerse': templatePlan.conservationEndVerse,
//             'recitationStartSurah': templatePlan.recitationStartSurah,
//             'recitationEndSurah': templatePlan.recitationEndSurah,
//             'recitationStartVerse': templatePlan.recitationStartVerse,
//             'recitationEndVerse': templatePlan.recitationEndVerse,
//             'lastUpdated':
//                 DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
//           };

//           await txn.insert('StudentPlans', planData);
//         }
//       });

//       print(
//           "تم إنشاء الخطط الجماعية بنجاح للحلقة $halagaId لعدد ${studentIds.length} طالب");
//       return true;
//     } catch (e) {
//       print("خطأ أثناء إنشاء الخطط الجماعية: $e");
//       return false;
//     }
//   }
// }

// // إنشاء نسخة عالمية من وحدة التحكم
// final studentPlansController = StudentPlansController();
