import 'package:app_service_order/database/db.dart';
import 'package:app_service_order/module/home/core/domain/contract/delete_service_order_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

@Injectable(as: DeleteServiceOrderRepository)
class DeleteServiceOrderRepositoryImpl implements DeleteServiceOrderRepository {
  late Database db;

  DeleteServiceOrderRepositoryImpl({required this.db});

  @override
  Future<void> call(int id) async {
    db = await DB.instance.database;
    await db.transaction((txn) async {
      await txn.delete('service_order', where: 'id = ?', whereArgs: [id]);
    });
  }
}