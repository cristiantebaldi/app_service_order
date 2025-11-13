import 'package:app_service_order/database/db.dart';
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
        await txn.update('service_order', {
          'reponsible': serviceOrder.responsible,
          'task': serviceOrder.task,
          'status': serviceOrder.status,
          'active': serviceOrder.active,
          'excluded': serviceOrder.excluded,
          'start_prevision': serviceOrder.startPrevison,
          'end_prevision': serviceOrder.endPrevison,
          'updated_date': DateTime.now().microsecondsSinceEpoch
        }, where: 'id = ?', whereArgs: [id]);
        return serviceOrder;
      });
  }
}