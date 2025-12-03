import 'package:app_service_order/module/home/core/domain/model/service_order.dart';

abstract class EditServiceOrderState {}

class EditServiceOrderLoading extends EditServiceOrderState {}

class EditServiceOrderEditing extends EditServiceOrderState {
  final int id;
  final String responsible;
  final String task;
  final String description;
  final String status;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdDate;

  EditServiceOrderEditing({
    required this.id,
    required this.responsible,
    required this.task,
    required this.description,
    required this.status,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.createdDate,
  });

  factory EditServiceOrderEditing.fromServiceOrder(ServiceOrder order) {
    return EditServiceOrderEditing(
      id: order.id!,
      responsible: order.responsible,
      task: order.task,
      description: order.description,
      status: order.status.toLowerCase(),
      isActive: order.active == 1,
      startDate: order.startPrevison,
      endDate: order.endPrevison,
      createdDate: order.createdDate,
    );
  }

  EditServiceOrderEditing copyWith({
    int? id,
    String? responsible,
    String? task,
    String? description,
    String? status,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdDate,
  }) {
    return EditServiceOrderEditing(
      id: id ?? this.id,
      responsible: responsible ?? this.responsible,
      task: task ?? this.task,
      description: description ?? this.description,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class EditServiceOrderSaving extends EditServiceOrderState {
  final EditServiceOrderEditing editingState;
  EditServiceOrderSaving(this.editingState);
}

class EditServiceOrderSuccess extends EditServiceOrderState {
  final ServiceOrder serviceOrder;
  EditServiceOrderSuccess(this.serviceOrder);
}

class EditServiceOrderError extends EditServiceOrderState {
  final String message;
  EditServiceOrderError(this.message);
}
