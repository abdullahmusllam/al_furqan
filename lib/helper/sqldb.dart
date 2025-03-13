// يجب حفظ هذا الملف لإنشاء اي قاعدة بيانات

import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  // this is made to not make init again and again
  static Database? _db;
  Future<Database> get db async {
    if (_db == null) _db = await initalDb();
    return _db!;
  }

  // here we init the database and create the tables
  initalDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'alforqanDB.db');

    // تحقق مما إذا كانت قاعدة البيانات موجودة بالفعل
    bool dbExists = await databaseExists(path);

    if (!dbExists) {
      // تعليق الكود القديم الذي ينشئ قاعدة بيانات جديدة
      /*
      Database mydb = await openDatabase(path,
          onCreate: _onCreate, version: 4, onUpgrade: _onUpgrade);
      return mydb;
      */

      // تحميل قاعدة البيانات من assets ونسخها إلى المسار الصحيح
      ByteData data = await rootBundle.load('assets/database/al_furqanDB.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    Database mydb = await openDatabase(path, version: 4, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('ALTER TABLE Users ADD COLUMN school_id INTEGER');

    await db.execute('''
    CREATE TABLE SCHOOLS(
      school_id INTEGER PRIMARY KEY AUTOINCREMENT,
      school_name TEXT,
      school_location TEXT,
    )
    ''');

    // إضافة قيد جديد على عمود isActivate
    await db.execute('''
    ALTER TABLE USERS ADD CONSTRAINT chk_isActivate CHECK (isActivate IN (0, 1))
    ''');

    print(
        "onUpgrade =========================================================");
  }

  // SELECT
  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database? mydb = await db;
    List<Map<String, dynamic>> response = await mydb!.rawQuery(sql);
    return response;
  }

  // INSERT
  insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  // UPDATE
  updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  // DELETE
  deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}
