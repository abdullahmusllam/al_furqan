import 'dart:io';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 8, // زوّدنا الإصدار عشان التعديلات
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
    try {
        // تعطيل قيود المفاتيح الأجنبية مؤقتًا
        await db.execute('PRAGMA foreign_keys=off;');
        
        // بدء المعاملة
        await db.execute('BEGIN TRANSACTION;');
        
        // إنشاء جدول مؤقت بالهيكل الجديد (بدون حقل StudentID أو بجعله اختياري)
        await db.execute('''
          CREATE TABLE IslamicStudies_temp (
            "IslamicStudiesID" INTEGER NOT NULL PRIMARY KEY ,
            "ElhalagatID" INTEGER NOT NULL,
            "StudentID" INTEGER NOT NULL DEFAULT -1,
            "Subject" TEXT NOT NULL,
            "PlannedContent" TEXT,
            "ExecutedContent" TEXT,
            "PlanMonth" TEXT,
            "isSync" BOOLEAN,
            CONSTRAINT "elhalagatidfk" FOREIGN KEY("ElhalagatID") REFERENCES "Elhalagat"("halagaID")
          );
        ''');
        
        // نسخ البيانات من الجدول القديم إلى الجدول المؤقت
        await db.execute('INSERT INTO IslamicStudies_temp SELECT * FROM IslamicStudies;');
        
        // حذف الجدول القديم
        await db.execute('DROP TABLE IslamicStudies;');
        
        // إعادة تسمية الجدول المؤقت
        await db.execute('ALTER TABLE IslamicStudies_temp RENAME TO IslamicStudies;');
        
        // إنهاء المعاملة
        await db.execute('COMMIT;');
        
        // إعادة تفعيل قيود المفاتيح الأجنبية
        await db.execute('PRAGMA foreign_keys=on;');
        
        print("---------------------------> Upgrade to version 7 completed successfully!");
      } catch (e) {
        // التراجع عن المعاملة في حالة حدوث خطأ
        await db.execute('ROLLBACK;');
        print("---------------------------> Error upgrading database: $e");
      }
  }


  Future<String> loadSqlScript() async {
    return await rootBundle.loadString('assets/database/al_furqan.db');
  }

  Future<UserModel?> getUser(String phone, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone_number = ? AND password = ?',
      whereArgs: [phone, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    print("User not found for phone: $phone");
    return null;
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database mydb = await database;
    return await mydb.rawQuery(sql);
  }

  readDataID(String table, String column, int sync) async {
    Database mydb = await database;
    return await mydb.query(table, where: "$column = ?", whereArgs: [sync]);
  }

  Future<int> insertData(String sql) async {
    Database mydb = await database;
    return await mydb.rawInsert(sql);
  }

  Future<int> insertData2(String table, Map<String, dynamic> values) async {
    Database mydb = await database;
    try {
      return await mydb.insert(table, values);
    } catch (e) {
      print("Error inserting into $table: $e");
      return -1;
    }
  }

  updateData(String sql) async {
    Database mydb = await database;
    return await mydb.rawUpdate(sql);
  }

  Future<int> updateData3(String table, Map<String, dynamic> values,
      String where, List<dynamic> whereArgs) async {
    try {
      Database mydb = await database;
      int result = await mydb.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      print(
          "------------------> Updated $table where $where: $result row(s) affected");
      return result;
    } catch (e) {
      print("------------------> Error updating $table: $e");
      return -1;
    }
  }

  Future<int> deleteData(String sql) async {
    Database mydb = await database;
    return await mydb.rawDelete(sql);
  }

  Future<int> deleteData2(String table, String column, String id) async {
    Database mydb = await database;
    return await mydb.delete(table, where: "$column = ?", whereArgs: [id]);
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
      String table, Map<String, dynamic> values) async {
    try {
      final db = await database;
      // بناء شرط الـ WHERE ديناميكيًا
      String whereClause = values.keys.map((key) => '$key = ?').join(' AND ');
      List<dynamic> whereArgs = values.values.toList();

      final result = await db.query(
        table,
        where: whereClause,
        whereArgs: whereArgs,
      );

      print(
          "-----> Checking if item exists in $table with $values: ${result.isNotEmpty}");
      return result.isNotEmpty;
    } catch (e) {
      print("Error checking item in $table: $e");
      return false;
    }
  }

  Future<T> transaction<T>(Future<T> Function(Transaction) action) async {
    Database mydb = await database;
    return await mydb.transaction(action);
  }
}

SqlDb sqlDb = SqlDb();
