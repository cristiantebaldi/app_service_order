import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class CreateServiceOrderState {}

class CreateServiceOrderInitial extends CreateServiceOrderState {}

class CreateServiceOrderEditing extends CreateServiceOrderState {
  final String responsible;
  final String task;
  final String description;
  final String status;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;

  CreateServiceOrderEditing({
    this.responsible = '',
    this.task = '',
    this.description = '',
    this.status = 'em andamento',
    this.isActive = true,
    DateTime? startDate,
    DateTime? endDate,
  }) : startDate = startDate ?? DateTime.now(),
       endDate = endDate ?? DateTime.now().add(const Duration(days: 1));

  CreateServiceOrderEditing copyWith({
    String? responsible,
    String? task,
    String? description,
    String? status,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CreateServiceOrderEditing(
      responsible: responsible ?? this.responsible,
      task: task ?? this.task,
      description: description ?? this.description,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class CreateServiceOrderSaving extends CreateServiceOrderState {
  final CreateServiceOrderEditing editingState;
  CreateServiceOrderSaving(this.editingState);
}

class CreateServiceOrderSuccess extends CreateServiceOrderState {
  final ServiceOrder serviceOrder;
  CreateServiceOrderSuccess(this.serviceOrder);
}

class CreateServiceOrderError extends CreateServiceOrderState {
  final String message;
  CreateServiceOrderError(this.message);
}
