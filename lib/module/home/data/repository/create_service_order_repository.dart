import 'package:app_service_order/database/db.dart';
import 'package:app_service_order/module/home/core/domain/contract/create_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

@Injectable(as: CreateServiceOrderRepository)
class CreateServiceOrderRepositoryImpl implements CreateServiceOrderRepository {
  late Database db;

  CreateServiceOrderRepositoryImpl({required this.db});

  @override
  Future<ServiceOrder> call(ServiceOrder serviceOrder) async {
    db = await DB.instance.database;
    return await db.transaction((txn) async {
      await txn.insert('service_order', {
        'responsible': serviceOrder.responsible,
        'task': serviceOrder.task,
        'status': serviceOrder.status,
        'active': serviceOrder.active,
        'excluded': serviceOrder.excluded,
        'start_prevision': serviceOrder.startPrevison.millisecondsSinceEpoch,
        'end_prevision': serviceOrder.endPrevison.millisecondsSinceEpoch,
        'created_date': DateTime.now().millisecondsSinceEpoch,
        'updated_date': DateTime.now().millisecondsSinceEpoch
      });
      return serviceOrder;
    });
  }
}