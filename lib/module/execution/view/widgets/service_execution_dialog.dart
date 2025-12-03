import 'dart:io';

import 'package:app_service_order/di/injection.dart';
import 'package:app_service_order/module/execution/controller/service_execution_cubit.dart';
import 'package:app_service_order/module/execution/state/service_execution_state.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/image/core/domain/usecase/delete_image_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/fetch_image_paths_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/get_image_id_by_path_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/insert_image_usecase.dart';
import 'package:app_service_order/module/image/core/domain/usecase/link_image_to_service_order_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceExecutionDialog extends StatelessWidget {
  final ServiceOrder serviceOrder;
  final HomeController homeController;

  const ServiceExecutionDialog({
    super.key,
    required this.serviceOrder,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceExecutionCubit(
        serviceOrder: serviceOrder,
        insertImageUsecase: getIt<InsertImageUsecase>(),
        fetchImagePathsUsecase: getIt<FetchImagePathsUsecase>(),
        deleteImageUsecase: getIt<DeleteImageUsecase>(),
        getImageIdByPathUsecase: getIt<GetImageIdByPathUsecase>(),
        linkImageToServiceOrderUsecase: getIt<LinkImageToServiceOrderUsecase>(),
        homeController: homeController,
      ),
      child: BlocConsumer<ServiceExecutionCubit, ServiceExecutionState>(
        listener: (context, state) {
          if (state is ServiceExecutionSuccess) {
            Navigator.of(context).pop(true);
          }

          if (state is ServiceExecutionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceExecutionInitial) {
            return const SizedBox.shrink();
          } else if (state is ServiceExecutionLoadingImages) {
            return _buildLoadingImages(context);
          } else if (state is ServiceExecutionReady) {
            return _buildForm(context, state);
          } else if (state is ServiceExecutionProcessing) {
            return _buildFormWithLoading(context, state);
          } else if (state is ServiceExecutionError) {
            return _buildError(context, state);
          } else if (state is ServiceExecutionSuccess) {
            return const SizedBox.shrink();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingImages(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando imagens...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ServiceExecutionReady state) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 8),
                _buildResponsibleInfo(state),
                const SizedBox(height: 16),
                _buildDescriptionField(context, state),
                const SizedBox(height: 16),
                _buildImagesSection(context, state),
                const SizedBox(height: 24),
                _buildFinalizeButton(context, state, cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormWithLoading(
    BuildContext context,
    ServiceExecutionProcessing state,
  ) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderProcessing(context, state),
                    const SizedBox(height: 8),
                    _buildResponsibleInfoProcessing(state),
                    const SizedBox(height: 16),
                    _buildDescriptionFieldProcessing(context, state),
                    const SizedBox(height: 16),
                    _buildImagesSectionProcessing(context, state),
                    const SizedBox(height: 24),
                    _buildFinalizeButtonProcessing(context, cs),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ServiceExecutionError state) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Erro',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ServiceExecutionReady state) {
    return Row(
      children: [
        Expanded(
          child: Text(
            state.order.task,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildResponsibleInfo(ServiceExecutionReady state) {
    return Text('Responsável: ${state.order.responsible}');
  }

  Widget _buildDescriptionField(
    BuildContext context,
    ServiceExecutionReady state,
  ) {
    final cubit = context.read<ServiceExecutionCubit>();

    return TextFormField(
      initialValue: state.description,
      maxLines: 4,
      onChanged: cubit.updateDescription,
      decoration: const InputDecoration(
        labelText: 'Observações / Relatório',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildImagesSection(
    BuildContext context,
    ServiceExecutionReady state,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...state.imagePaths.asMap().entries.map((entry) {
          return _buildImageThumbnail(context, entry.value);
        }),
        _buildTakePhotoButton(context),
      ],
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String imagePath) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(imagePath), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _showRemoveImageConfirmation(context, imagePath),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTakePhotoButton(BuildContext context) {
    final cubit = context.read<ServiceExecutionCubit>();

    return OutlinedButton.icon(
      onPressed: () => cubit.takePhoto(),
      icon: const Icon(Icons.photo_camera),
      label: const Text('Tirar foto'),
    );
  }

  Widget _buildFinalizeButton(
    BuildContext context,
    ServiceExecutionReady state,
    ColorScheme cs,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: () => _showSummaryAndConfirm(context, state),
        child: const Text(
          'Finalizar atendimento',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderProcessing(
    BuildContext context,
    ServiceExecutionProcessing state,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            state.order.task,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildResponsibleInfoProcessing(ServiceExecutionProcessing state) {
    return Text('Responsável: ${state.order.responsible}');
  }

  Widget _buildDescriptionFieldProcessing(
    BuildContext context,
    ServiceExecutionProcessing state,
  ) {
    return TextFormField(
      initialValue: state.description,
      maxLines: 4,
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Observações / Relatório',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildImagesSectionProcessing(
    BuildContext context,
    ServiceExecutionProcessing state,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...state.imagePaths.asMap().entries.map((entry) {
          return SizedBox(
            width: 72,
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(entry.value), fit: BoxFit.cover),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.photo_camera),
          label: const Text('Tirar foto'),
        ),
      ],
    );
  }

  Widget _buildFinalizeButtonProcessing(BuildContext context, ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: null,
        child: const Text(
          'Finalizar atendimento',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _showRemoveImageConfirmation(
    BuildContext context,
    String imagePath,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover foto?'),
        content: const Text('Esta foto será removida deste atendimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiceExecutionCubit>().removeImage(imagePath);
    }
  }

  Future<void> _showSummaryAndConfirm(
    BuildContext context,
    ServiceExecutionReady state,
  ) async {
    final cubit = context.read<ServiceExecutionCubit>();
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Extrato do atendimento',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.order.task,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Responsável',
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                state.order.responsible,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (state.order.id != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'OS',
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '#${state.order.id}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Divider(color: cs.outlineVariant),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Status',
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Finalizado',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Criado em',
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                state.order.createdDate != null
                                                    ? cubit.formatDateTime(
                                                        state
                                                            .order
                                                            .createdDate!,
                                                      )
                                                    : '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Prev. Início',
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                cubit.formatDate(
                                                  state.order.startPrevison,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Prev. Término',
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                cubit.formatDate(
                                                  state.order.endPrevison,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Finalização em',
                                          style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cubit.formatDateTime(now),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Descrição/Relatório',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                state.description.isEmpty
                                    ? '(vazio)'
                                    : state.description,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Imagens (${state.imagePaths.length})',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (state.imagePaths.isEmpty)
                              const Text('Nenhuma imagem anexada')
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final path in state.imagePaths)
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await cubit.finalizeServiceOrder();
                        },
                        child: const Text(
                          'Confirmar finalização',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
