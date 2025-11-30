import 'package:app_service_order/di/injection.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  final controller = getIt<HomeController>();

  HomeView({super.key});

  void _showCreateServiceOrderForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateServiceOrderDialog(
        onSave: (serviceOrder) {
          controller.saveServiceOrder(serviceOrder);
        },
      ),
    );
  }

  void _showEditServiceOrderForm(BuildContext context, ServiceOrder serviceOrder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditServiceOrderDialog(
        serviceOrder: serviceOrder,
        onSave: (updatedOrder) {
          controller.updateServiceOrder(serviceOrder.id!, updatedOrder);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => controller,
      child: BlocBuilder<HomeController, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ordens de Serviço'),
            ),
            body: Builder(
              builder: (context) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeError) {
                  return Center(child: Text('Erro: ${state.message}'));
                } else if (state is HomeLoaded) {
                  final loaded = state as HomeLoaded;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: SegmentedButton<StatusFilter>(
                          segments: const [
                            ButtonSegment(value: StatusFilter.ativos, label: Text('Ativos'), icon: Icon(Icons.check_circle_outline)),
                            ButtonSegment(value: StatusFilter.emAndamento, label: Text('Em andamento'), icon: Icon(Icons.timelapse)),
                            ButtonSegment(value: StatusFilter.finalizados, label: Text('Finalizados'), icon: Icon(Icons.done_all)),
                          ],
                          selected: {loaded.filter},
                          onSelectionChanged: (s) {
                            if (s.isNotEmpty) {
                              context.read<HomeController>().setFilter(s.first);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: loaded.serviceOrders.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text('Nenhuma ordem de serviço para este filtro'),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (context, index) {
                                  final order = loaded.serviceOrders[index];
                                  return Slidable(
                                    key: ValueKey(order.id),
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      extentRatio: 0.42,
                                      children: [
                                        SlidableAction(
                                          onPressed: (_) => _showEditServiceOrderForm(context, order),
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          icon: Icons.edit,
                                          label: 'Editar',
                                        ),
                                        SlidableAction(
                                          onPressed: (_) => context.read<HomeController>().deleteServiceOrder(order.id!),
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Excluir',
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _showEditServiceOrderForm(context, order),
                                      child: _ServiceOrderCard(serviceOrder: order),
                                    ),
                                  );
                                },
                                itemCount: loaded.serviceOrders.length,
                              ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('Estado inicial'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateServiceOrderForm(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
class _ServiceOrderCard extends StatelessWidget {
  final ServiceOrder serviceOrder;

  const _ServiceOrderCard({required this.serviceOrder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          child: Text(
            (serviceOrder.responsible.isNotEmpty
                    ? serviceOrder.responsible[0]
                    : 'A')
                .toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          serviceOrder.task,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Responsável: ${serviceOrder.responsible}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (serviceOrder.createdDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Criado em ${_formatDateFull(serviceOrder.createdDate!)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              children: [
                Chip(
                  label: Text(
                    serviceOrder.status,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 76,
          padding: const EdgeInsets.fromLTRB(10, 2, 8, 2),
          decoration: BoxDecoration(
            color: cs.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: cs.outlineVariant, width: 1),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Início',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                Text(
                  _formatDate(serviceOrder.startPrevison),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Divider(height: 6, thickness: 0.75),
                const SizedBox(height: 2),
                Text(
                  'Término',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                Text(
                  _formatDate(serviceOrder.endPrevison),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluído':
      case 'concluida':
        return Colors.green;
      case 'em andamento':
        return Colors.blue;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatDateFull(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ...existing code...
class _CreateServiceOrderDialog extends StatefulWidget {
  final Function(ServiceOrder) onSave;

  const _CreateServiceOrderDialog({required this.onSave});

  @override
  State<_CreateServiceOrderDialog> createState() => _CreateServiceOrderDialogState();
}

class _CreateServiceOrderDialogState extends State<_CreateServiceOrderDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _responsibleController;
  late final TextEditingController _taskController;
  late final TextEditingController _statusController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _responsibleController = TextEditingController();
    _taskController = TextEditingController();
    _statusController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
    _startDateController = TextEditingController(text: _formatDate(_startDate));
    _endDateController = TextEditingController(text: _formatDate(_endDate));
    _active = true;
  }

  @override
  void dispose() {
    _responsibleController.dispose();
    _taskController.dispose();
    _statusController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStartDate) {
        if (picked.isAfter(_endDate)) {
          _endDate = picked.add(const Duration(days: 1));
          _endDateController.text = _formatDate(_endDate);
        }
        _startDate = picked;
        _startDateController.text = _formatDate(_startDate);
      } else {
        if (picked.isBefore(_startDate)) {
          _startDate = picked.subtract(const Duration(days: 1));
          _startDateController.text = _formatDate(_startDate);
        }
        _endDate = picked;
        _endDateController.text = _formatDate(_endDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ordem de Serviço'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Responsável",
                    border: OutlineInputBorder(),
                  ),
                  controller: _responsibleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  controller: _statusController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  title: const Text('Ativa'),
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Tarefa",
                    border: OutlineInputBorder(),
                  ),
                  controller: _taskController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Data Início",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Selecione a data";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Data Término",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(false),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Selecione a data";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(ServiceOrder(
                          responsible: _responsibleController.text,
                          task: _taskController.text,
                          status: _statusController.text,
                          active: _active ? 1 : 0,
                          excluded: 0,
                          startPrevison: _startDate,
                          endPrevison: _endDate,
                          createdDate: DateTime.now(),
                          updatedDate: DateTime.now(),
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditServiceOrderDialog extends StatefulWidget {
  final ServiceOrder serviceOrder;
  final Function(ServiceOrder) onSave;

  const _EditServiceOrderDialog({
    required this.serviceOrder,
    required this.onSave,
  });

  @override
  State<_EditServiceOrderDialog> createState() => _EditServiceOrderDialogState();
}

class _EditServiceOrderDialogState extends State<_EditServiceOrderDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _responsibleController;
  late final TextEditingController _taskController;
  late final TextEditingController _statusController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _responsibleController = TextEditingController(
      text: widget.serviceOrder.responsible,
    );
    _taskController = TextEditingController(
      text: widget.serviceOrder.task,
    );
    _statusController = TextEditingController(
      text: widget.serviceOrder.status,
    );
    _startDate = widget.serviceOrder.startPrevison;
    _endDate = widget.serviceOrder.endPrevison;
    _startDateController = TextEditingController(text: _formatDate(_startDate));
    _endDateController = TextEditingController(text: _formatDate(_endDate));
    _active = (widget.serviceOrder.active == 1);
  }

  @override
  void dispose() {
    _responsibleController.dispose();
    _taskController.dispose();
    _statusController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStartDate) {
        if (picked.isAfter(_endDate)) {
          _endDate = picked.add(const Duration(days: 1));
          _endDateController.text = _formatDate(_endDate);
        }
        _startDate = picked;
        _startDateController.text = _formatDate(_startDate);
      } else {
        if (picked.isBefore(_startDate)) {
          _startDate = picked.subtract(const Duration(days: 1));
          _startDateController.text = _formatDate(_startDate);
        }
        _endDate = picked;
        _endDateController.text = _formatDate(_endDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ordem de Serviço'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Responsável",
                    border: OutlineInputBorder(),
                  ),
                  controller: _responsibleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  controller: _statusController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  title: const Text('Ativa'),
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Tarefa",
                    border: OutlineInputBorder(),
                  ),
                  controller: _taskController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Data Início",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Selecione a data";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Data Término",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(false),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Selecione a data";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(ServiceOrder(
                          responsible: _responsibleController.text,
                          task: _taskController.text,
                          status: _statusController.text,
                          active: _active ? 1 : 0,
                          excluded: 0,
                          startPrevison: _startDate,
                          endPrevison: _endDate,
                          createdDate: widget.serviceOrder.createdDate,
                          updatedDate: DateTime.now(),
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Atualizar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}