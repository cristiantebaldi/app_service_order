import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/core/domain/usecase/change_service_order_usecase.dart';
import 'package:app_service_order/module/home/state/edit_service_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditServiceOrderCubit extends Cubit<EditServiceOrderState> {
  final ChangeServiceOrderUsecase changeServiceOrderUsecase;

  EditServiceOrderCubit({required this.changeServiceOrderUsecase})
    : super(EditServiceOrderLoading());

  void startEditing(ServiceOrder order) {
    try {
      emit(EditServiceOrderEditing.fromServiceOrder(order));
    } catch (e) {
      emit(
        EditServiceOrderError(
          'Erro ao carregar ordem de serviço: ${e.toString()}',
        ),
      );
    }
  }

  void updateResponsible(String value) {
    if (state is! EditServiceOrderEditing) return;
    emit((state as EditServiceOrderEditing).copyWith(responsible: value));
  }

  void updateTask(String value) {
    if (state is! EditServiceOrderEditing) return;
    emit((state as EditServiceOrderEditing).copyWith(task: value));
  }

  void updateDescription(String value) {
    if (state is! EditServiceOrderEditing) return;
    emit((state as EditServiceOrderEditing).copyWith(description: value));
  }

  void updateStatus(String value) {
    if (state is! EditServiceOrderEditing) return;
    emit((state as EditServiceOrderEditing).copyWith(status: value));
  }

  void toggleActive() {
    if (state is! EditServiceOrderEditing) return;
    final current = state as EditServiceOrderEditing;
    emit(current.copyWith(isActive: !current.isActive));
  }

  void updateStartDate(DateTime date) {
    if (state is! EditServiceOrderEditing) return;
    final current = state as EditServiceOrderEditing;

    DateTime endDate = current.endDate;

    if (date.isAfter(endDate)) {
      endDate = date.add(const Duration(days: 1));
    }

    emit(current.copyWith(startDate: date, endDate: endDate));
  }

  void updateEndDate(DateTime date) {
    if (state is! EditServiceOrderEditing) return;
    final current = state as EditServiceOrderEditing;

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
    final currentState = state;

    if (currentState is! EditServiceOrderEditing) {
      return false;
    }

    if (currentState.responsible.trim().isEmpty) {
      emit(EditServiceOrderError('Responsável é obrigatório'));
      return false;
    }

    if (currentState.task.trim().isEmpty) {
      emit(EditServiceOrderError('Tarefa é obrigatória'));
      return false;
    }

    return true;
  }

  ServiceOrder buildServiceOrder() {
    if (state is! EditServiceOrderEditing) {
      throw StateError('Cannot build service order from current state');
    }
    final current = state as EditServiceOrderEditing;

    return ServiceOrder(
      id: current.id,
      responsible: current.responsible,
      task: current.task,
      description: current.description,
      status: current.status,
      active: current.isActive ? 1 : 0,
      excluded: 0,
      startPrevison: current.startDate,
      endPrevison: current.endDate,
      createdDate: current.createdDate,
      updatedDate: DateTime.now(),
    );
  }

  Future<void> updateServiceOrder() async {
    if (!validateForm()) {
      return;
    }

    if (state is! EditServiceOrderEditing) {
      return;
    }

    try {
      final current = state as EditServiceOrderEditing;
      emit(EditServiceOrderSaving(current));

      final serviceOrder = ServiceOrder(
        id: current.id,
        responsible: current.responsible,
        task: current.task,
        description: current.description,
        status: current.status,
        active: current.isActive ? 1 : 0,
        excluded: 0,
        startPrevison: current.startDate,
        endPrevison: current.endDate,
        createdDate: current.createdDate,
        updatedDate: DateTime.now(),
      );

      final updatedServiceOrder = await changeServiceOrderUsecase(
        current.id,
        serviceOrder,
      );

      emit(EditServiceOrderSuccess(updatedServiceOrder));
    } catch (e) {
      emit(EditServiceOrderError('Erro ao atualizar: ${e.toString()}'));
    }
  }
}
