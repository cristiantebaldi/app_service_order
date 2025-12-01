import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/core/domain/usecase/change_service_order_usecase.dart';
import 'package:app_service_order/module/home/core/domain/usecase/create_service_order_usecase.dart';
import 'package:app_service_order/module/home/core/domain/usecase/delete_service_order_usecase.dart';
import 'package:app_service_order/module/home/core/domain/usecase/fetch_service_order_usecase.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeController extends Cubit<HomeState> {
  final FetchServiceOrderUsecase fetchServiceOrderUsecase;
  final CreateServiceOrderUsecase createServiceOrderUsecase;
  final ChangeServiceOrderUsecase changeServiceOrderUsecase;
  final DeleteServiceOrderUsecase deleteServiceOrderUsecase;

  StatusFilter _currentFilter = StatusFilter.ativos;
  List<ServiceOrder> _all = const [];
  List<ServiceOrder> get all => List.unmodifiable(_all);

  HomeController({
    required this.fetchServiceOrderUsecase,
    required this.createServiceOrderUsecase,
    required this.changeServiceOrderUsecase,
    required this.deleteServiceOrderUsecase,
  }) : super(HomeInitial()) {
    fetchServiceOrders();
  }

  Future<void> fetchServiceOrders() async {
    emit(HomeLoading());
    try {
      _all = await fetchServiceOrderUsecase();
      emit(HomeLoaded(_applyFilter(_all, _currentFilter), _currentFilter));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void setFilter(StatusFilter filter) {
    _currentFilter = filter;
    emit(HomeLoaded(_applyFilter(_all, _currentFilter), _currentFilter));
  }

  List<ServiceOrder> _applyFilter(List<ServiceOrder> list, StatusFilter filter) {
    switch (filter) {
      case StatusFilter.ativos:
        return list.where((e) => (e.active ?? 1) == 1).toList();
      case StatusFilter.emAndamento:
        return list
            .where((e) => (e.status).toLowerCase().contains('andamento'))
            .toList();
      case StatusFilter.finalizados:
        return list
            .where((e) => (e.status).toLowerCase().contains('finaliz'))
            .toList();
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void updateStartDate(DateTime newDate, DateTime currentEndDate,
      Function(DateTime, DateTime) onUpdate) {
    DateTime endDate = currentEndDate;

    if (newDate.isAfter(endDate)) {
      endDate = newDate.add(const Duration(days: 1));
    }

    onUpdate(newDate, endDate);
  }

  void updateEndDate(DateTime newDate, DateTime currentStartDate,
      Function(DateTime, DateTime) onUpdate) {
    DateTime startDate = currentStartDate;

    if (newDate.isBefore(startDate)) {
      startDate = newDate.subtract(const Duration(days: 1));
    }

    onUpdate(startDate, newDate);
  }

  Future<void> saveServiceOrder(ServiceOrder serviceOrder) async {
    try {
      await createServiceOrderUsecase(serviceOrder);
      await fetchServiceOrders();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> updateServiceOrder(int id, ServiceOrder serviceOrder) async {
    try {
      await changeServiceOrderUsecase(id, serviceOrder);
      await fetchServiceOrders();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> deleteServiceOrder(int id) async {
    try {
      await deleteServiceOrderUsecase(id);
      await fetchServiceOrders();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}