
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/core/domain/usecase/create_service_order_usecase.dart';
import 'package:app_service_order/module/home/core/domain/usecase/fetch_service_order_usecase.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeController extends Cubit<HomeState> {
  final FetchServiceOrderUsecase fetchServiceOrderUsecase;
  final CreateServiceOrderUsecase createServiceOrderUsecase;

  bool loading = false;
  List<ServiceOrder> serviceOrders = [];

  HomeController({required this.fetchServiceOrderUsecase,
    required this.createServiceOrderUsecase
  }) : super(HomeInitial()) {
    fetchServiceOrders();
  }

  Future<void> fetchServiceOrders() async {
    emit(HomeLoading());
    final serviceOrders = await fetchServiceOrderUsecase();
    emit(HomeLoaded(serviceOrders));
  }

  Future<void> createOrderService(ServiceOrder serviceOrder) async {
    emit(HomeLoading());
    await createServiceOrderUsecase(serviceOrder);
    await fetchServiceOrders();
  }
}