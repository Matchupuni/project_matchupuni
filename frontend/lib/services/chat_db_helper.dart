import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ChatDbHelper {
  static final ChatDbHelper _instance = ChatDbHelper._internal();
  static Database? _database;

  factory ChatDbHelper() => _instance;

  ChatDbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms if needed
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else if (Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory appSupportDir = await getApplicationSupportDirectory();
    final String path = join(appSupportDir.path, 'chat_database.db');

    // Create the directory if it doesn't exist
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        targetUserId TEXT NOT NULL,
        text TEXT NOT NULL,
        isMe INTEGER NOT NULL,
        time TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMessage(
    String targetUserId,
    String text,
    bool isMe,
    String time,
  ) async {
    Database db = await database;
    return await db.insert('messages', {
      'targetUserId': targetUserId,
      'text': text,
      'isMe': isMe ? 1 : 0,
      'time': time,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(String targetUserId) async {
    Database db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      'messages',
      where: 'targetUserId = ?',
      whereArgs: [targetUserId],
      orderBy: 'timestamp ASC',
    );

    return maps
        .map(
          (map) => {
            'id': map['id'],
            'targetUserId': map['targetUserId'],
            'text': map['text'],
            'isMe': map['isMe'] == 1,
            'time': map['time'],
            'timestamp': map['timestamp'],
          },
        )
        .toList();
  }
}
