import 'dart:io';

import 'package:app_service_order/module/execution/state/service_execution_state.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/image/core/domain/model/image_entity.dart';
import 'package:app_service_order/module/image/core/domain/usecase/delete_image_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/fetch_image_paths_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/get_image_id_by_path_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/insert_image_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/link_image_to_service_order_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ServiceExecutionCubit extends Cubit<ServiceExecutionState> {
  final InsertImageUsecase _insertImageUsecase;
  final FetchImagePathsUsecase _fetchImagePathsUsecase;
  final DeleteImageUsecase _deleteImageUsecase;
  final GetImageIdByPathUsecase _getImageIdByPathUsecase;
  final LinkImageToServiceOrderUsecase _linkImageToServiceOrderUsecase;
  final HomeController _homeController;
  final ImagePicker _picker = ImagePicker();
  final ServiceOrder _serviceOrder;

  ServiceExecutionCubit({
    required ServiceOrder serviceOrder,
    required InsertImageUsecase insertImageUsecase,
    required FetchImagePathsUsecase fetchImagePathsUsecase,
    required DeleteImageUsecase deleteImageUsecase,
    required GetImageIdByPathUsecase getImageIdByPathUsecase,
    required LinkImageToServiceOrderUsecase linkImageToServiceOrderUsecase,
    required HomeController homeController,
  }) : _insertImageUsecase = insertImageUsecase,
       _fetchImagePathsUsecase = fetchImagePathsUsecase,
       _deleteImageUsecase = deleteImageUsecase,
       _getImageIdByPathUsecase = getImageIdByPathUsecase,
       _linkImageToServiceOrderUsecase = linkImageToServiceOrderUsecase,
       _homeController = homeController,
       _serviceOrder = serviceOrder,
       super(ServiceExecutionInitial()) {
    loadExistingImages();
  }

  Future<void> loadExistingImages() async {
    if (_serviceOrder.id == null) return;

    emit(ServiceExecutionLoadingImages(_serviceOrder));

    try {
      final paths = await _fetchImagePathsUsecase(_serviceOrder.id!);
      emit(
        ServiceExecutionReady(
          order: _serviceOrder,
          description: _serviceOrder.description,
          imagePaths: paths,
        ),
      );
    } catch (e) {
      emit(ServiceExecutionError('Erro ao carregar imagens: $e'));
    }
  }

  Future<void> takePhoto() async {
    if (_serviceOrder.id == null) return;

    if (state is! ServiceExecutionReady) return;
    final currentState = state as ServiceExecutionReady;

    emit(
      ServiceExecutionProcessing(
        order: currentState.order,
        description: currentState.description,
        imagePaths: currentState.imagePaths,
      ),
    );

    try {
      final shot = await _picker.pickImage(source: ImageSource.camera);

      if (shot == null) {
        emit(currentState);
        return;
      }

      final baseDir = await getApplicationDocumentsDirectory();
      final osId = _serviceOrder.id!;
      final osDir = Directory(
        p.join(baseDir.path, 'service_orders', osId.toString()),
      );

      if (!(await osDir.exists())) {
        await osDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}'
          '${p.extension(shot.path).isEmpty ? '.jpg' : p.extension(shot.path)}';
      final destPath = p.join(osDir.path, fileName);
      await File(shot.path).copy(destPath);

      final createdDate = DateTime.now();
      final imageEntity = ImageEntity(
        path: destPath,
        serviceOrderId: osId,
        createdDate: createdDate,
      );
      final imgId = await _insertImageUsecase(imageEntity);
      await _linkImageToServiceOrderUsecase(
        serviceOrderId: osId,
        imageId: imgId,
      );

      final updatedPaths = List<String>.from(currentState.imagePaths)
        ..add(destPath);
      emit(currentState.copyWith(imagePaths: updatedPaths));
    } catch (e) {
      emit(ServiceExecutionError('Erro ao tirar foto: $e'));
    }
  }

  Future<void> removeImage(String imagePath) async {
    if (_serviceOrder.id == null) return;

    if (state is! ServiceExecutionReady) return;
    final currentState = state as ServiceExecutionReady;

    emit(
      ServiceExecutionProcessing(
        order: currentState.order,
        description: currentState.description,
        imagePaths: currentState.imagePaths,
      ),
    );

    try {
      final imgId = await _getImageIdByPathUsecase(imagePath);

      if (imgId != null) {
        await _deleteImageUsecase(
          serviceOrderId: _serviceOrder.id!,
          imageId: imgId,
        );
      }

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }

      final updatedPaths = List<String>.from(currentState.imagePaths)
        ..remove(imagePath);
      emit(currentState.copyWith(imagePaths: updatedPaths));
    } catch (e) {
      emit(ServiceExecutionError('Erro ao remover imagem: $e'));
    }
  }

  void updateDescription(String description) {
    if (state is! ServiceExecutionReady) return;
    emit((state as ServiceExecutionReady).copyWith(description: description));
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  bool validateForm() {
    if (state is! ServiceExecutionReady) return false;
    final currentState = state as ServiceExecutionReady;

    if (currentState.description.trim().isEmpty) {
      emit(ServiceExecutionError('Preencha a descrição do atendimento'));
      return false;
    }

    return true;
  }

  ServiceOrder buildUpdatedServiceOrder(ServiceExecutionReady currentState) {
    return ServiceOrder(
      id: currentState.order.id,
      responsible: currentState.order.responsible,
      task: currentState.order.task,
      description: currentState.description,
      status: 'Finalizado',
      active: currentState.order.active,
      excluded: currentState.order.excluded,
      startPrevison: currentState.order.startPrevison,
      endPrevison: currentState.order.endPrevison,
      createdDate: currentState.order.createdDate,
      updatedDate: DateTime.now(),
    );
  }

  Future<void> finalizeServiceOrder() async {
    if (state is! ServiceExecutionReady) return;
    final currentState = state as ServiceExecutionReady;

    if (!validateForm()) {
      return;
    }

    emit(
      ServiceExecutionProcessing(
        order: currentState.order,
        description: currentState.description,
        imagePaths: currentState.imagePaths,
      ),
    );

    try {
      final updatedOrder = buildUpdatedServiceOrder(currentState);

      if (currentState.order.id != null) {
        await _homeController.updateServiceOrder(
          currentState.order.id!,
          updatedOrder,
        );
      }
      emit(ServiceExecutionSuccess());
    } catch (e) {
      emit(ServiceExecutionError('Erro ao finalizar ordem de serviço: $e'));
    }
  }
}
