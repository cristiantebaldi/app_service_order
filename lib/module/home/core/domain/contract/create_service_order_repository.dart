import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class CreateServiceOrderRepository {
  Future<ServiceOrder> call(ServiceOrder serviceOrder);
}