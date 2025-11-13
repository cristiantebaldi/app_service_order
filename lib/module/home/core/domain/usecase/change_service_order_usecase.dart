import 'package:app_service_order/module/home/core/domain/contract/change_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangeServiceOrderUsecase {
  final ChangeServiceOrderRepository changeServiceOrderRepository;
  ChangeServiceOrderUsecase({required this.changeServiceOrderRepository});

  Future<ServiceOrder> call(int id, ServiceOrder serviceOrder) async {
    return await changeServiceOrderRepository(id, serviceOrder);
  }
}