import 'package:app_service_order/di/injection.dart';
import 'package:app_service_order/module/home/controller/edit_service_order_cubit.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/state/edit_service_order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditServiceOrderDialog extends StatelessWidget {
  final ServiceOrder serviceOrder;

  const EditServiceOrderDialog({super.key, required this.serviceOrder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditServiceOrderCubit>()..startEditing(serviceOrder),
      child: BlocListener<EditServiceOrderCubit, EditServiceOrderState>(
        listener: (context, state) {
          if (state is EditServiceOrderSuccess) {
            Navigator.pop(context, state.serviceOrder);
          } else if (state is EditServiceOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<EditServiceOrderCubit, EditServiceOrderState>(
          builder: (context, state) {
            final cubit = context.read<EditServiceOrderCubit>();

            if (state is EditServiceOrderLoading) {
              return Scaffold(
                appBar: AppBar(title: const Text('Editar Ordem de Serviço')),
                body: const Center(child: CircularProgressIndicator()),
              );
            } else if (state is EditServiceOrderEditing) {
              return _buildForm(context, cubit, state);
            } else if (state is EditServiceOrderSaving) {
              return _buildFormWithLoading(context, cubit, state.editingState);
            } else if (state is EditServiceOrderSuccess) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is EditServiceOrderError) {
              return _buildForm(
                context,
                cubit,
                EditServiceOrderEditing.fromServiceOrder(serviceOrder),
              );
            }

            return const Scaffold(
              body: Center(child: Text('Estado desconhecido')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    EditServiceOrderCubit cubit,
    EditServiceOrderEditing state,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Editar Ordem de Serviço',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Responsável",
                    border: OutlineInputBorder(),
                  ),
                  initialValue: state.responsible,
                  onChanged: cubit.updateResponsible,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: state.status,
                  items: const [
                    DropdownMenuItem(
                      value: 'em andamento',
                      child: Text('Em andamento'),
                    ),
                    DropdownMenuItem(
                      value: 'finalizado',
                      child: Text('Finalizado'),
                    ),
                  ],
                  onChanged: (v) => cubit.updateStatus(v ?? 'em andamento'),
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  title: const Text('Ativa'),
                  contentPadding: EdgeInsets.zero,
                  value: state.isActive,
                  onChanged: (_) => cubit.toggleActive(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Tarefa",
                    border: OutlineInputBorder(),
                  ),
                  initialValue: state.task,
                  onChanged: cubit.updateTask,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    border: OutlineInputBorder(),
                  ),
                  initialValue: state.description,
                  onChanged: cubit.updateDescription,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Data Início",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: cubit.formatDate(state.startDate),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: state.startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            cubit.updateStartDate(picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Data Término",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: cubit.formatDate(state.endDate),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: state.endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            cubit.updateEndDate(picked);
                          }
                        },
                      ),
                    ),
                  ],
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
                      cubit.updateServiceOrder();
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

  Widget _buildFormWithLoading(
    BuildContext context,
    EditServiceOrderCubit cubit,
    EditServiceOrderEditing state,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Editar Ordem de Serviço',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: 0.5,
                      child: AbsorbPointer(
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Responsável",
                                border: OutlineInputBorder(),
                              ),
                              initialValue: state.responsible,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: state.status,
                              items: const [
                                DropdownMenuItem(
                                  value: 'em andamento',
                                  child: Text('Em andamento'),
                                ),
                                DropdownMenuItem(
                                  value: 'finalizado',
                                  child: Text('Finalizado'),
                                ),
                              ],
                              onChanged: null,
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile.adaptive(
                              title: const Text('Ativa'),
                              contentPadding: EdgeInsets.zero,
                              value: state.isActive,
                              onChanged: null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Tarefa",
                                border: OutlineInputBorder(),
                              ),
                              initialValue: state.task,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Descrição",
                                border: OutlineInputBorder(),
                              ),
                              initialValue: state.description,
                              enabled: false,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Data Início",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    controller: TextEditingController(
                                      text: cubit.formatDate(state.startDate),
                                    ),
                                    enabled: false,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Data Término",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    controller: TextEditingController(
                                      text: cubit.formatDate(state.endDate),
                                    ),
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                onPressed: null,
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
                  ],
                ),
              ),
            ),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
