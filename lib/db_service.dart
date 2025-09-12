import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'career_assistant.db'),
      version: 1,
      onCreate: (db, version) async {
        // Resume table with version
        await db.execute('''
          CREATE TABLE resume(
            id INTEGER PRIMARY KEY,
            data TEXT,
            version INTEGER
          )
        ''');
        // Chat history table
        await db.execute('''
          CREATE TABLE chats(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT,
            content TEXT,
            timestamp TEXT,
            resume_version INTEGER
          )
        ''');
      },
    );
  }

  // ---------------- Resume ----------------
  static Future<void> saveResume(Map<String, dynamic> data) async {
    final db = await database;
    final old = await loadResume();
    int newVersion = (old?['version'] ?? 0) + 1;

    await db.insert(
      'resume',
      {'id': 1, 'data': jsonEncode(data), 'version': newVersion},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> loadResume() async {
    final db = await database;
    final res = await db.query('resume', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      final map = jsonDecode(res.first['data'] as String) as Map<String, dynamic>;
      map['version'] = res.first['version'] as int? ?? 0;
      return map;
    }
    return null;
  }

  // ---------------- Chat History ----------------
  static Future<void> saveChat(String role, String content, {int? resumeVersion}) async {
    final db = await database;
    await db.insert('chats', {
      'role': role,
      'content': content,
      'resume_version': resumeVersion ?? 0,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  static Future<List<Map<String, dynamic>>> loadChats() async {
    final db = await database;
    final res = await db.query('chats', orderBy: 'id ASC');
    return res
        .map((e) => {
      "role": e['role'] as String,
      "content": e['content'] as String,
      "resume_version": e['resume_version'] as int,
    })
        .toList();
  }

  static Future<void> clearChats() async {
    final db = await database;
    await db.delete('chats');
  }
}
