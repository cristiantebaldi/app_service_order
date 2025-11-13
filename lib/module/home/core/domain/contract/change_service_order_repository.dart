import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class ChangeServiceOrderRepository {
  Future<ServiceOrder> call(int id, ServiceOrder serviceOrder);
}