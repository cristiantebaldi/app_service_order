import 'package:app_service_order/module/home/core/domain/contract/delete_service_order_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteServiceOrderUsecase {
  final DeleteServiceOrderRepository deleteServiceOrderRepository;

  DeleteServiceOrderUsecase({required this.deleteServiceOrderRepository});

  Future<void> call(int id) async {
    await deleteServiceOrderRepository(id);
  }

}