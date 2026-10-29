import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_schema.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('live_assistant.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // If desktop or test environment, initialize sqflite_ffi
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (Platform.isAndroid || Platform.isIOS) {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      path = join(appDocDir.path, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DatabaseSchema.createConversationsTable);
    await db.execute(DatabaseSchema.createSegmentsTable);
    await db.execute(DatabaseSchema.createSegmentIndex);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
