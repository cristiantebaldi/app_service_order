import 'package:app_service_order/module/home/core/domain/contract/fetch_service_order_repository.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchServiceOrderUsecase {
  final FetchServiceOrderRepository fetchServiceOrderRepository;

  FetchServiceOrderUsecase({required this.fetchServiceOrderRepository});

  Future<List<ServiceOrder>> call() async {
    return fetchServiceOrderRepository();
  }
}