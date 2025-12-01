import 'dart:io';

import 'package:app_service_order/database/image_dao.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ServiceExecutionView extends StatelessWidget {
  const ServiceExecutionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeController, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(child: Text('Erro: ${state.message}'));
        }
        if (state is HomeLoaded) {
          final all = context.read<HomeController>().all;
          final notFinished = all
              .where((e) => (e.active ?? 1) == 1)
              .where((e) => !e.status.toLowerCase().contains('finaliz'))
              .toList();
          return Scaffold(
            appBar: AppBar(title: const Text('Atendimentos')),
            body: notFinished.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Nenhuma OS pendente de atendimento'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notFinished.length,
                    itemBuilder: (context, index) {
                      final order = notFinished[index];
                      return Slidable(
                        key: ValueKey('exec-${order.id}')
                        ,
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.28,
                          children: [
                            SlidableAction(
                              onPressed: (_) => _openExecutionDialog(context, order),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.assignment,
                              label: 'Preencher',
                            ),
                          ],
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(order.task, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('Responsável: ${order.responsible}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () => _openExecutionDialog(context, order),
                          ),
                        ),
                      );
                    },
                  ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _openExecutionDialog(BuildContext context, ServiceOrder order) {
    final controller = context.read<HomeController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceExecutionDialog(order: order, controller: controller),
    );
  }
}

class _ServiceExecutionDialog extends StatefulWidget {
  final ServiceOrder order;
  final HomeController controller;
  const _ServiceExecutionDialog({required this.order, required this.controller});

  @override
  State<_ServiceExecutionDialog> createState() => _ServiceExecutionDialogState();
}

class _ServiceExecutionDialogState extends State<_ServiceExecutionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  final List<XFile> _images = [];
  final _picker = ImagePicker();
  final _imageDao = ImageDao();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.order.description);
    _loadExistingImages();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingImages() async {
    if (widget.order.id == null) return;
    final paths = await _imageDao.fetchImagePathsForServiceOrder(widget.order.id!);
    if (!mounted) return;
    setState(() {
      _images
        ..clear()
        ..addAll(paths.map((p) => XFile(p)));
    });
  }

  Future<void> _takePhoto() async {
    final shot = await _picker.pickImage(source: ImageSource.camera);
    if (shot != null) {
      // Copy to app-private directory for persistence
      final baseDir = await getApplicationDocumentsDirectory();
      final osId = widget.order.id!;
      final osDir = Directory(p.join(baseDir.path, 'service_orders', osId.toString()));
      if (!(await osDir.exists())) {
        await osDir.create(recursive: true);
      }
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(shot.path).isEmpty ? '.jpg' : p.extension(shot.path)}';
      final destPath = p.join(osDir.path, fileName);
      await File(shot.path).copy(destPath);

      // Persist path and link to OS
      final imgId = await _imageDao.insertImage(path: destPath, createdDate: DateTime.now());
      await _imageDao.linkImageToServiceOrder(serviceOrderId: osId, imageId: imgId);

      if (!mounted) return;
      setState(() => _images.add(XFile(destPath)));
    }
  }

  Future<void> _finalize() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = ServiceOrder(
      id: widget.order.id,
      responsible: widget.order.responsible,
      task: widget.order.task,
      description: _descriptionController.text,
      status: 'finalizado',
      active: widget.order.active,
      excluded: widget.order.excluded,
      startPrevison: widget.order.startPrevison,
      endPrevison: widget.order.endPrevison,
      createdDate: widget.order.createdDate,
      updatedDate: DateTime.now(),
    );

    // Persist OS update
    // ignore: use_build_context_synchronously
    await widget.controller.updateServiceOrder(widget.order.id!, updated);

    // Refresh lists
    // ignore: use_build_context_synchronously
    await widget.controller.fetchServiceOrders();

    if (mounted) Navigator.pop(context);
  }

  Future<void> _showSummaryAndConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    final cs = Theme.of(context).colorScheme;
    String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    String _fmtDateTime(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final viewInsets = MediaQuery.of(context).viewInsets;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Extrato do atendimento', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.order.task, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Responsável: ${widget.order.responsible}'),
                          if (widget.order.id != null) ...[
                            const SizedBox(height: 4),
                            Text('OS #${widget.order.id}')
                          ],
                          const SizedBox(height: 8),
                          Text('Status: finalizado'),
                          const SizedBox(height: 8),
                          Text('Criado em: ${widget.order.createdDate != null ? _fmtDateTime(widget.order.createdDate!) : '-'}', style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('Prev. início: ${_fmtDate(widget.order.startPrevison)}  •  Prev. término: ${_fmtDate(widget.order.endPrevison)}', style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('Finalização em: ${_fmtDateTime(now)}', style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Text('Descrição/Relatório:', style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(_descriptionController.text.isEmpty ? '(vazio)' : _descriptionController.text),
                          const SizedBox(height: 12),
                          Text('Imagens (${_images.length}):', style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          if (_images.isEmpty)
                            const Text('Nenhuma imagem anexada')
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final x in _images)
                                  SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(x.path), fit: BoxFit.cover),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _finalize();
                        },
                        child: const Text('Confirmar finalização', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.order.task, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Responsável: ${widget.order.responsible}'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observações / Relatório',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _images.length; i++)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_images[i].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Remover foto?'),
                                        content: const Text('Esta foto será removida deste atendimento.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover')),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      final path = _images[i].path;
                                      try {
                                        final imgId = await _imageDao.getImageIdByPath(path);
                                        if (imgId != null && widget.order.id != null) {
                                          await _imageDao.deleteLinkAndImage(serviceOrderId: widget.order.id!, imageId: imgId);
                                        }
                                        final f = File(path);
                                        if (await f.exists()) {
                                          await f.delete();
                                        }
                                      } catch (_) {
                                        // noop: ignore deletion errors silently for UX
                                      }
                                      if (!mounted) return;
                                      setState(() => _images.removeAt(i));
                                    }
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Tirar foto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                      onPressed: _showSummaryAndConfirm,
                      child: const Text('Finalizar atendimento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
