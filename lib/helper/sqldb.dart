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
  Future<bool> checkIfitemExists(String table, int id, String Column) async {
  final db = await database; // احصل على قاعدة البيانات
  final result = await db.query(
    '${table}',
    where: '${Column} = ?',
    whereArgs: [id],
  );
  return result.isNotEmpty;
}

}
SqlDb sqlDb = SqlDb();