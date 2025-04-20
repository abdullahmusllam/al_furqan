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
      version: 4,
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
      await db.execute("ALTER TABLE Students ADD COLUMN userID INTEGER NULL");
      print("Column added successfully!");
    } catch (e) {
      print("Error upgrading database: $e");
    }
    print("Database upgraded from $oldVersion to $newVersion");
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
<<<<<<< HEAD

  Future<bool> checkIfitemExists(String table, int id, String column) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}
=======

  Future<bool> checkIfitemExists(String table, int id, String column) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}

SqlDb sqlDb = SqlDb();
>>>>>>> 376d5759104a29dbc0afd24f029d8122a050eb04
