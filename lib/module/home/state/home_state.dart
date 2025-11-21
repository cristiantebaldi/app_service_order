import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ServiceOrder> serviceOrders;
  HomeLoaded(this.serviceOrders);
}