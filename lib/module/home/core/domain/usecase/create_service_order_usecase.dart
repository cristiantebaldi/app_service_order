import 'package:app_service_order/module/home/core/domain/contract/create_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateServiceOrderUsecase {
  final CreateServiceOrderRepository createServiceOrderRepository;

  CreateServiceOrderUsecase({required this.createServiceOrderRepository});

  Future<ServiceOrder> call(ServiceOrder serviceOrder) async {
    return await createServiceOrderRepository(serviceOrder);
  }
}