import 'dart:io';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class SqlDb {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await initalDb();
    return _db!;
  }

  initalDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'alforqanDB.db');
    Database mydb = await openDatabase(
      path,
      version: 5, // تحديث إصدار قاعدة البيانات
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  _onCreate(Database db, int version) async {
    String sqlScript = await loadSqlScript();
    List<String> queries = sqlScript.split(';');

    for (String query in queries) {
      if (query.trim().isNotEmpty) {
        await db.execute(query);
      }
    }
    print("Database Created Successfully");
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  Future<String> loadSqlScript() async {
    return await rootBundle.loadString('assets/database/al_furqan.db');
  }

  /// جلب مستخدم بناءً على رقم الهاتف وكلمة المرور
  Future<UserModel?> getUser(String phone, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone_number = ? AND password = ?',
      whereArgs: [phone, password],
    );

    print(" phone: $phone, password: $password");
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      print("لم يتم العثور على مستخدم بـ phone: $phone و password: $password");
      final allUsers = await db.query('users');
      print("All Users: $allUsers");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database mydb = await database;
    return await mydb.rawQuery(sql);
  }

  insertData(String sql) async {
    Database mydb = await database;
    return await mydb.rawInsert(sql);
  }

  updateData(String sql) async {
    Database mydb = await database;
    return await mydb.rawUpdate(sql);
  }

  deleteData(String sql) async {
    Database mydb = await database;
    return await mydb.rawDelete(sql);
  }

  Future<bool> checkIfitemExists(String table, int id, String column) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<bool> checkIfitemExistsForExcel(
      String table, Map<String, dynamic> conditions) async {
    final db = await database;
    String whereClause = conditions.keys.map((key) => "$key = ?").join(" AND ");
    List<dynamic> whereArgs = conditions.values.toList();
    final result = await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
    return result.isNotEmpty;
  }
  // حساب نسبة التنفيذ بناءً على القيم النصية للآيات
  double calculateExecutedRate(String start, String end, String planStart, String planEnd) {
    // التحقق من صحة القيم
    if (start.isEmpty || end.isEmpty || planStart.isEmpty || planEnd.isEmpty) {
      return 0.0;
    }

    try {
      // استخراج رقم السورة والآية
      List<String> startParts = start.split(':');
      List<String> endParts = end.split(':');
      List<String> planStartParts = planStart.split(':');
      List<String> planEndParts = planEnd.split(':');

      if (startParts.length != 2 || endParts.length != 2 || 
          planStartParts.length != 2 || planEndParts.length != 2) {
        return 0.0;
      }

      // تحويل القيم إلى أرقام
      int startSurah = int.parse(startParts[0]);
      int startAyah = int.parse(startParts[1]);
      int endSurah = int.parse(endParts[0]);
      int endAyah = int.parse(endParts[1]);
      int planStartSurah = int.parse(planStartParts[0]);
      int planStartAyah = int.parse(planStartParts[1]);
      int planEndSurah = int.parse(planEndParts[0]);
      int planEndAyah = int.parse(planEndParts[1]);

      // جلب عدد الآيات في كل سورة - هذه مصفوفة ثابتة تحتوي على عدد آيات كل سورة
      List<int> surahAyatCount = [
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
        112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53,
        89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18,
        12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17,
        19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
      ];

      // تحويل موقع السورة والآية إلى رقم تسلسلي للآية
      int convertToAbsoluteAyah(int surah, int ayah) {
        int absoluteAyah = 0;
        // جمع عدد الآيات في السور السابقة
        for (int i = 0; i < surah - 1; i++) {
          absoluteAyah += surahAyatCount[i];
        }
        // إضافة رقم الآية الحالية
        absoluteAyah += ayah;
        return absoluteAyah;
      }

      // حساب الآيات المطلقة
      int startAbsolute = convertToAbsoluteAyah(startSurah, startAyah);
      int endAbsolute = convertToAbsoluteAyah(endSurah, endAyah);
      int planStartAbsolute = convertToAbsoluteAyah(planStartSurah, planStartAyah);
      int planEndAbsolute = convertToAbsoluteAyah(planEndSurah, planEndAyah);

      // حساب عدد الآيات المنفذة وعدد الآيات المطلوبة
      int executedCount = endAbsolute - startAbsolute + 1;
      int planCount = planEndAbsolute - planStartAbsolute + 1;

      // تجنب القسمة على صفر
      if (planCount <= 0) return 0.0;

      // حساب نسبة التنفيذ
      double rate = executedCount / planCount;
      // تقييد النسبة بين 0 و 1
      return rate < 0 ? 0.0 : (rate > 1 ? 1.0 : rate);
    } catch (e) {
      print("Error calculating executed rate: $e");
      return 0.0;
    }
  }

  // إضافة تقدم طالب في الحفظ
  Future<int> addStudentConservationProgress({
    required int studentId,
    required int conservationPlanId, 
    required String executedStart,
    required String executedEnd,
    String? planMonth,
  }) async {
    final db = await database;
    
    // جلب خطة الحفظ للحصول على نقطة البداية والنهاية
    final planResults = await db.query(
      'ConservationPlans',
      where: 'ConservationPlanID = ?',
      whereArgs: [conservationPlanId],
    );
    
    if (planResults.isEmpty) {
      throw Exception("Conservation plan not found");
    }
    
    final plan = planResults.first;
    final planStart = plan['StartAya'].toString();
    final planEnd = plan['EndAya'].toString();
    
    // حساب نسبة التنفيذ
    final executedRate = calculateExecutedRate(executedStart, executedEnd, planStart, planEnd);
    
    // إعداد قيمة الشهر (استخدام الشهر الحالي إذا لم يتم تحديده)
    final month = planMonth ?? plan['PlanMonth'] ?? 
      DateFormat('yyyy-MM').format(DateTime.now());
    
    return await db.insert('StudentConservationProgress', {
      'StudentID': studentId,
      'ConservationPlanID': conservationPlanId,
      'ExecutedStart': executedStart,
      'ExecutedEnd': executedEnd,
      'ExecutedRate': executedRate,
      'PlanMonth': month,
    });
  }
  
  // إضافة تقدم طالب في التلاوة
  Future<int> addStudentTlawahProgress({
    required int studentId,
    required int eltlawahPlanId, 
    required String executedStart,
    required String executedEnd,
    String? planMonth,
  }) async {
    final db = await database;
    
    // جلب خطة التلاوة للحصول على نقطة البداية والنهاية
    final planResults = await db.query(
      'EltlawahPlans',
      where: 'EltlawahPlanID = ?',
      whereArgs: [eltlawahPlanId],
    );
    
    if (planResults.isEmpty) {
      throw Exception("Eltlawah plan not found");
    }
    
    final plan = planResults.first;
    final planStart = plan['StartAya'].toString();
    final planEnd = plan['EndAya'].toString();
    
    // حساب نسبة التنفيذ
    final executedRate = calculateExecutedRate(executedStart, executedEnd, planStart, planEnd);
    
    // إعداد قيمة الشهر (استخدام الشهر الحالي إذا لم يتم تحديده)
    final month = planMonth ?? plan['PlanMonth'] ?? 
      DateFormat('yyyy-MM').format(DateTime.now());
    
    return await db.insert('StudentTlawahProgress', {
      'StudentID': studentId,
      'EltlawahPlanID': eltlawahPlanId,
      'ExecutedStart': executedStart,
      'ExecutedEnd': executedEnd,
      'ExecutedRate': executedRate,
      'PlanMonth': month,
    });
  }
  
  // تحديث تقدم طالب في الحفظ
  Future<int> updateStudentConservationProgress({
    required int progressId,
    required String executedStart,
    required String executedEnd,
  }) async {
    final db = await database;
    
    // جلب تقدم الطالب للحصول على معرف خطة الحفظ
    final progressResults = await db.query(
      'StudentConservationProgress',
      where: 'StudentProgressID = ?',
      whereArgs: [progressId],
    );
    
    if (progressResults.isEmpty) {
      throw Exception("Student progress not found");
    }
    
    final progress = progressResults.first;
    final conservationPlanId = progress['ConservationPlanID'];
    
    // جلب خطة الحفظ للحصول على نقطة البداية والنهاية
    final planResults = await db.query(
      'ConservationPlans',
      where: 'ConservationPlanID = ?',
      whereArgs: [conservationPlanId],
    );
    
    if (planResults.isEmpty) {
      throw Exception("Conservation plan not found");
    }
    
    final plan = planResults.first;
    final planStart = plan['StartAya'].toString();
    final planEnd = plan['EndAya'].toString();
    
    // حساب نسبة التنفيذ
    final executedRate = calculateExecutedRate(executedStart, executedEnd, planStart, planEnd);
    
    return await db.update(
      'StudentConservationProgress',
      {
        'ExecutedStart': executedStart,
        'ExecutedEnd': executedEnd,
        'ExecutedRate': executedRate,
      },
      where: 'StudentProgressID = ?',
      whereArgs: [progressId],
    );
  }
  
  // تحديث تقدم طالب في التلاوة
  Future<int> updateStudentTlawahProgress({
    required int progressId,
    required String executedStart,
    required String executedEnd,
  }) async {
    final db = await database;
    
    // جلب تقدم الطالب للحصول على معرف خطة التلاوة
    final progressResults = await db.query(
      'StudentTlawahProgress',
      where: 'StudentProgressID = ?',
      whereArgs: [progressId],
    );
    
    if (progressResults.isEmpty) {
      throw Exception("Student progress not found");
    }
    
    final progress = progressResults.first;
    final eltlawahPlanId = progress['EltlawahPlanID'];
    
    // جلب خطة التلاوة للحصول على نقطة البداية والنهاية
    final planResults = await db.query(
      'EltlawahPlans',
      where: 'EltlawahPlanID = ?',
      whereArgs: [eltlawahPlanId],
    );
    
    if (planResults.isEmpty) {
      throw Exception("Eltlawah plan not found");
    }
    
    final plan = planResults.first;
    final planStart = plan['StartAya'].toString();
    final planEnd = plan['EndAya'].toString();
    
    // حساب نسبة التنفيذ
    final executedRate = calculateExecutedRate(executedStart, executedEnd, planStart, planEnd);
    
    return await db.update(
      'StudentTlawahProgress',
      {
        'ExecutedStart': executedStart,
        'ExecutedEnd': executedEnd,
        'ExecutedRate': executedRate,
      },
      where: 'StudentProgressID = ?',
      whereArgs: [progressId],
    );
  }
  
  // جلب تقدم الحفظ للطالب
  Future<List<Map<String, dynamic>>> getStudentConservationProgress(int studentId, {String? planMonth}) async {
    final db = await database;
    String whereClause = 'StudentID = ?';
    List<dynamic> whereArgs = [studentId];
    
    if (planMonth != null) {
      whereClause += ' AND PlanMonth = ?';
      whereArgs.add(planMonth);
    }
    
    return await db.query(
      'StudentConservationProgress',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'PlanMonth DESC'
    );
  }
  
  // جلب تقدم التلاوة للطالب
  Future<List<Map<String, dynamic>>> getStudentTlawahProgress(int studentId, {String? planMonth}) async {
    final db = await database;
    String whereClause = 'StudentID = ?';
    List<dynamic> whereArgs = [studentId];
    
    if (planMonth != null) {
      whereClause += ' AND PlanMonth = ?';
      whereArgs.add(planMonth);
    }
    
    return await db.query(
      'StudentTlawahProgress',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'PlanMonth DESC'
    );
  }

  readDataID(String tablename, String column, int value) async{
    Database? mydb = await database;
    List<Map> response = await mydb.query(tablename, where: '$column = ?', whereArgs: [value]);
    return response;
  }
}

SqlDb sqlDb = SqlDb();
