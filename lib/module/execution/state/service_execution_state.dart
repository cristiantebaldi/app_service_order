import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class ServiceExecutionState {}

class ServiceExecutionInitial extends ServiceExecutionState {}

class ServiceExecutionLoadingImages extends ServiceExecutionState {
  final ServiceOrder order;

  ServiceExecutionLoadingImages(this.order);
}

class ServiceExecutionReady extends ServiceExecutionState {
  final ServiceOrder order;
  final String description;
  final List<String> imagePaths;

  ServiceExecutionReady({
    required this.order,
    required this.description,
    required this.imagePaths,
  });

  ServiceExecutionReady copyWith({
    ServiceOrder? order,
    String? description,
    List<String>? imagePaths,
  }) {
    return ServiceExecutionReady(
      order: order ?? this.order,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}

class ServiceExecutionProcessing extends ServiceExecutionState {
  final ServiceOrder order;
  final String description;
  final List<String> imagePaths;

  ServiceExecutionProcessing({
    required this.order,
    required this.description,
    required this.imagePaths,
  });
}

class ServiceExecutionError extends ServiceExecutionState {
  final String message;

  ServiceExecutionError(this.message);
}

class ServiceExecutionSuccess extends ServiceExecutionState {}
