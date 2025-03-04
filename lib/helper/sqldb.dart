// يجب حفظ هذا الملف لإنشاء اي قاعدة بيانات

import 'dart:ui';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  // this is made to not make init again and again
  static Database? _db;
  Future<Database> get db async {
    if (_db == null) _db = await initalDb();
    return _db!;
  }

  // here we init the database and creat the tables
  initalDb() async {
    String databasepath = await getDatabasesPath();
    print(databasepath);
    String path = join(databasepath, 'alforqanDB.db');
    Database mydb = await openDatabase(path,
        onCreate: _onCreate, version: 4, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    // Check if the column 'isActivate' exists
    var tableInfo = await db.rawQuery("PRAGMA table_info(Users)");
    var columnExists =
        tableInfo.any((column) => column['name'] == 'isActivate');

    if (!columnExists) {
      await db
          .execute('ALTER TABLE Users ADD COLUMN isActivate INTEGER DEFAULT 0');
    }

    // Check if the column 'date' exists
    columnExists = tableInfo.any((column) => column['name'] == 'date');

    if (!columnExists) {
      await db.execute('ALTER TABLE Users ADD COLUMN date TEXT');
    }
    await db.execute('''
    CREATE TABLE REQUESTS (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      first_name TEXT,
      middle_name TEXT,
      grandfather_name TEXT,
      last_name TEXT,
      phone_number TEXT,
      telephone_number TEXT,
      email TEXT,
      password TEXT,
      role_id INTEGER,
      date TEXT,
      isActivate INTEGER
    )
    ''');

    print(
        "onUpgrade =========================================================");
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE Users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            middle_name TEXT,
            grandfather_name TEXT,
            last_name TEXT,
            password INTEGER,
            phone_number INTEGER,
            telephone_number INTEGER,
            email TEXT,
            role_id INTEGER,
            date Date,
            isActivate INTEGER DEFAULT 0,
            FOREIGN KEY(role_id) REFERENCES Roles(role_id)
        )
''');
    await db.execute('''
    CREATE TABLE Roles (
      role_id INTEGER PRIMARY KEY AUTOINCREMENT,
      role_name TEXT,
      role_description TEXT
  )
''');
    await db.execute('''
    CREATE TABLE REQUESTS (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      first_name TEXT,
      middle_name TEXT,
      grandfather_name TEXT,
      last_name TEXT,
      phone_number TEXT,
      telephone_number TEXT,
      email TEXT,
      password TEXT,
      role_id INTEGER,
      date TEXT,
      isActivate INTEGER
    )
    ''');

    print("==============onCreate database and tables ================");
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
