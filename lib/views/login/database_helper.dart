import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/users_model.dart'; // افترضت إن UserModel موجود في هالمسار

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // فتح قاعدة البيانات أو إنشائها إذا ما كانت موجودة
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'al_furqan.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone_number TEXT UNIQUE,
            password TEXT,
            role_id INTEGER
          )
        ''');
        // إضافة فهرس لتحسين الأداء على phone_number
        await db.execute('CREATE INDEX idx_phone ON users(phone_number)');
      },
    );
  }



  /// جلب مستخدم بناءً على رقم الهاتف فقط (للتسجيل التلقائي)
  Future<UserModel?> getUserByPhone(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone_number = ?',
      whereArgs: [phone],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // إغلاق قاعدة البيانات (اختياري)
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
