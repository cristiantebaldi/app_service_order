import 'package:app_service_order/core/data/database/db.dart';
import 'package:app_service_order/module/home/core/domain/contract/get_by_id_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

@Injectable(as: GetByIDServiceOrderRepository)
class GetByIDServiceOrderRepositoryImpl
    implements GetByIDServiceOrderRepository {
  late Database db;

  GetByIDServiceOrderRepositoryImpl({required this.db});

  @override
  Future<ServiceOrder> call(int id) async {
    db = await DB.instance.database;
    final rows = await db.query(
      'service_order',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw Exception('Registro não encontrado');
    return ServiceOrder.fromMap(rows.first);
  }
}
