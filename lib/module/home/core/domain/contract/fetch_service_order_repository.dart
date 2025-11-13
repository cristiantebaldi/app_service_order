import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class FetchServiceOrderRepository {
  Future<List<ServiceOrder>> call();
}