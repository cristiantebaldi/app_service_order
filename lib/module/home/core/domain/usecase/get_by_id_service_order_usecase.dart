import 'package:app_service_order/module/home/core/domain/contract/get_by_id_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetByIdServiceOrderUsecase {
  final GetByIDServiceOrderRepository getByIDServiceOrderRepository;

  GetByIdServiceOrderUsecase({required this.getByIDServiceOrderRepository});

  Future<ServiceOrder> call(int id) async {
    return await getByIDServiceOrderRepository(id);
  }
}