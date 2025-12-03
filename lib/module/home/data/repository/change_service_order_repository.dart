import 'package:app_service_order/core/data/database/db.dart';
import 'package:app_service_order/module/home/core/domain/contract/change_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

@Injectable(as: ChangeServiceOrderRepository)
class ChangeServiceOrderRepositoryImpl implements ChangeServiceOrderRepository {
  late Database db;

  ChangeServiceOrderRepositoryImpl({required this.db});

  @override
  Future<ServiceOrder> call(int id, ServiceOrder serviceOrder) async {
    db = await DB.instance.database;
    return await db.transaction((txn) async {
      await txn.update(
        'service_order',
        {
          'responsible': serviceOrder.responsible,
          'task': serviceOrder.task,
          'description': serviceOrder.description,
          'status': serviceOrder.status,
          'active': serviceOrder.active,
          'excluded': serviceOrder.excluded,
          'start_prevision': serviceOrder.startPrevison.millisecondsSinceEpoch,
          'end_prevision': serviceOrder.endPrevison.millisecondsSinceEpoch,
          'updated_date': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return serviceOrder;
    });
  }
}
