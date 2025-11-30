import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

enum StatusFilter {
  ativos,
  emAndamento,
  finalizados,
}

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ServiceOrder> serviceOrders;
  final StatusFilter filter;
  HomeLoaded(this.serviceOrders, this.filter);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}