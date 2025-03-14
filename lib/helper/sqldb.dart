import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database> get db async {
    if (_db == null) _db = await initalDb();
    return _db!;
  }

  initalDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'alforqanDB.db');
    Database mydb = await openDatabase(
      path,
      version: 3,
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
    print("Database Upgraded from $oldVersion to $newVersion");
  }

  Future<String> loadSqlScript() async {
    return await rootBundle.loadString('assets/database/al_furqan.db');
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database mydb = await db;
    return await mydb.rawQuery(sql);
  }

  insertData(String sql) async {
    Database mydb = await db;
    return await mydb.rawInsert(sql);
  }

  updateData(String sql) async {
    Database mydb = await db;
    return await mydb.rawUpdate(sql);
  }

  deleteData(String sql) async {
    Database mydb = await db;
    return await mydb.rawDelete(sql);
  }
}
