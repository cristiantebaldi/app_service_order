import 'package:app_service_order/database/db.dart';
import 'package:app_service_order/module/home/core/domain/contract/fetch_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

@Injectable(as: FetchServiceOrderRepository)
class FetchServiceOrderRepositoryImpl implements FetchServiceOrderRepository {
  late Database db;

  FetchServiceOrderRepositoryImpl({required this.db});

  @override
  Future<List<ServiceOrder>> call() async {
    db = await DB.instance.database;
    final rows = await db.query('service_order');
    return rows.map<ServiceOrder>((r) => ServiceOrder.fromMap(r)).toList();
  }
}