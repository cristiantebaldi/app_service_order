import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  DB._();

  static final DB instance = DB._();

  static Database? _database;

  get database async {
    if (_database != null) return _database;
    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'service_order.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, versao) async {
    await db.execute(_serviceOrder);
    await db.execute(_image);
    await db.execute(_serviceOrderImage);
  }

  String get _serviceOrder => '''
  CREATE TABLE service_order (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    responsible TEXT,
    task TEXT,
    description TEXT,
    status TEXT,
    active INT,
    excluded INT,
    start_prevision INT,
    end_prevision INT,
    created_date INT,
    updated_date INT
  );
  ''';

  String get _image => '''
  CREATE TABLE image (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT,
    service_order_id INT,
    created_date INT
  );
  ''';

  String get _serviceOrderImage => '''
  CREATE TABLE service_order_image (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_order_id INT,
    image_id INT
  );
  ''';
}
