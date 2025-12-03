import 'package:app_service_order/core/data/database/db.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<Database> get database async {
    final db = await DB.instance.database;
    return db;
  }
}
