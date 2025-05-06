import 'package:al_furqan/helper/sqldb.dart';

import '../models/messages_model.dart';

class MessageController {
  // Save message to SQLite
  Future<int> saveMessage(Message message, int id) async {
    final db = await sqlDb.database;
    message.id = id;
    return await db.insert('messages', message.toMap());
  }

  // Update message in SQLite
  Future<int> updateMessage(Message message) async {
    final db = await sqlDb.database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // Delete message from SQLite
  Future<int> deleteMessage(int id) async {
    final db = await sqlDb.database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    final db = await sqlDb.database;
    final result = await db.query('messages');
    return result.map((json) => Message.fromMap(json)).toList();
  }

  Future close() async {
    final db = await sqlDb.database;
    db.close();
  }
}

MessageController messageController = MessageController();