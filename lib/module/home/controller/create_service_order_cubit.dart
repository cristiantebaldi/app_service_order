import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/core/domain/usecase/create_service_order_usecase.dart';
import 'package:app_service_order/module/home/state/create_service_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateServiceOrderCubit extends Cubit<CreateServiceOrderState> {
  final CreateServiceOrderUsecase createServiceOrderUsecase;

  CreateServiceOrderCubit({required this.createServiceOrderUsecase})
    : super(CreateServiceOrderInitial()) {
    emit(CreateServiceOrderEditing());
  }

  void updateResponsible(String value) {
    if (state is! CreateServiceOrderEditing) return;
    emit((state as CreateServiceOrderEditing).copyWith(responsible: value));
  }

  void updateTask(String value) {
    if (state is! CreateServiceOrderEditing) return;
    emit((state as CreateServiceOrderEditing).copyWith(task: value));
  }

  void updateDescription(String value) {
    if (state is! CreateServiceOrderEditing) return;
    emit((state as CreateServiceOrderEditing).copyWith(description: value));
  }

  void updateStatus(String value) {
    if (state is! CreateServiceOrderEditing) return;
    emit((state as CreateServiceOrderEditing).copyWith(status: value));
  }

  void toggleActive() {
    if (state is! CreateServiceOrderEditing) return;
    final current = state as CreateServiceOrderEditing;
    emit(current.copyWith(isActive: !current.isActive));
  }

  void updateStartDate(DateTime date) {
    if (state is! CreateServiceOrderEditing) return;
    final current = state as CreateServiceOrderEditing;

    DateTime endDate = current.endDate;

    if (date.isAfter(endDate)) {
      endDate = date.add(const Duration(days: 1));
    }

    emit(current.copyWith(startDate: date, endDate: endDate));
  }

  void updateEndDate(DateTime date) {
    if (state is! CreateServiceOrderEditing) return;
    final current = state as CreateServiceOrderEditing;

    DateTime startDate = current.startDate;

    if (date.isBefore(startDate)) {
      startDate = date.subtract(const Duration(days: 1));
    }

    emit(current.copyWith(startDate: startDate, endDate: date));
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatDateFull(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool validateForm() {
    if (state is! CreateServiceOrderEditing) return false;
    final current = state as CreateServiceOrderEditing;

    if (current.responsible.trim().isEmpty) {
      emit(CreateServiceOrderError('Responsável é obrigatório'));
      return false;
    }

    if (current.task.trim().isEmpty) {
      emit(CreateServiceOrderError('Tarefa é obrigatória'));
      return false;
    }

    return true;
  }

  ServiceOrder buildServiceOrder() {
    if (state is! CreateServiceOrderEditing) {
      throw StateError('Cannot build service order from current state');
    }
    final current = state as CreateServiceOrderEditing;

    return ServiceOrder(
      responsible: current.responsible,
      task: current.task,
      description: current.description,
      status: current.status,
      active: current.isActive ? 1 : 0,
      excluded: 0,
      startPrevison: current.startDate,
      endPrevison: current.endDate,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );
  }

  Future<void> saveServiceOrder() async {
    if (!validateForm()) {
      return;
    }

    try {
      final editingState = state as CreateServiceOrderEditing;

      final serviceOrder = buildServiceOrder();

      emit(CreateServiceOrderSaving(editingState));

      final savedServiceOrder = await createServiceOrderUsecase(serviceOrder);

      emit(CreateServiceOrderSuccess(savedServiceOrder));
    } catch (e) {
      emit(CreateServiceOrderError('Erro ao salvar: ${e.toString()}'));
    }
  }
}
