import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

@singleton
class DB {
  DB._();

  static final DB instance = DB._();

  static Database? _database;

  get database async {
    if (_database != null) return _database;
    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase (
      join(await getDatabasesPath(), 'service_order.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, versao) async {
    await db.execute(_serviceOrder);
  }

  String get _serviceOrder => '''
  CREATE TABLE service_order (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    responsible TEXT,
    task TEXT,
    status TEXT,
    active BOOL,
    excluded BOOL,
    start_prevision INT,
    end_prevision INT,
    created_date INT,
    updated_date INT
  );
  ''';
}