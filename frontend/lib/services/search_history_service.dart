import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SearchHistoryService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    // Use path_provider to get a guaranteed writable directory
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory('${documentsDir.path}/matchupuni_db');

    // Ensure the directory exists
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final path = '${dbDir.path}/search_history.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            search_type TEXT NOT NULL,
            searched_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Add a search query to history.
  /// If the same query+type already exists, update its timestamp instead of duplicating.
  static Future<void> addSearch(String query, String searchType) async {
    final db = await database;
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Remove existing duplicate (same query + type) so it moves to top
    await db.delete(
      'search_history',
      where: 'query = ? AND search_type = ?',
      whereArgs: [trimmed, searchType],
    );

    // Insert as new (latest)
    await db.insert('search_history', {
      'query': trimmed,
      'search_type': searchType,
      'searched_at': DateTime.now().toIso8601String(),
    });

    // Keep only the latest 20 entries per search type
    final all = await db.query(
      'search_history',
      where: 'search_type = ?',
      whereArgs: [searchType],
      orderBy: 'searched_at DESC',
    );

    if (all.length > 20) {
      final idsToDelete = all.sublist(20).map((row) => row['id']).toList();
      for (final id in idsToDelete) {
        await db.delete('search_history', where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  /// Get recent searches for a given type, ordered by most recent first.
  static Future<List<String>> getRecentSearches(String searchType,
      {int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      'search_history',
      where: 'search_type = ?',
      whereArgs: [searchType],
      orderBy: 'searched_at DESC',
      limit: limit,
    );
    return results.map((row) => row['query'] as String).toList();
  }

  /// Delete a single search entry by query text and type.
  static Future<void> deleteSearch(String query, String searchType) async {
    final db = await database;
    await db.delete(
      'search_history',
      where: 'query = ? AND search_type = ?',
      whereArgs: [query, searchType],
    );
  }

  /// Clear all search history for a given type.
  static Future<void> clearHistory(String searchType) async {
    final db = await database;
    await db.delete(
      'search_history',
      where: 'search_type = ?',
      whereArgs: [searchType],
    );
  }
}
