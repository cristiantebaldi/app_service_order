import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:app_service_order/module/home/view/widgets/create_service_order_dialog.dart';
import 'package:app_service_order/module/home/view/widgets/edit_service_order_dialog.dart';
import 'package:app_service_order/module/home/view/widgets/service_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _showCreateServiceOrderForm(BuildContext context) async {
    final result = await showModalBottomSheet<ServiceOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CreateServiceOrderDialog(),
    );

    if (result != null && context.mounted) {
      context.read<HomeController>().fetchServiceOrders();
    }
  }

  Future<void> _showEditServiceOrderForm(
    BuildContext context,
    ServiceOrder serviceOrder,
  ) async {
    final result = await showModalBottomSheet<ServiceOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditServiceOrderDialog(serviceOrder: serviceOrder),
    );

    if (result != null && context.mounted) {
      context.read<HomeController>().fetchServiceOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeController, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeError) {
                return Center(child: Text('Erro: ${state.message}'));
              } else if (state is HomeLoaded) {
                final loaded = state;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: SegmentedButton<StatusFilter>(
                        segments: const [
                          ButtonSegment(
                            value: StatusFilter.ativos,
                            label: Text('Ativos'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                          ButtonSegment(
                            value: StatusFilter.emAndamento,
                            label: Text('Em andamento'),
                            icon: Icon(Icons.timelapse),
                          ),
                          ButtonSegment(
                            value: StatusFilter.finalizados,
                            label: Text('Finalizados'),
                            icon: Icon(Icons.done_all),
                          ),
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
                                child: Text(
                                  'Nenhuma ordem de serviço para este filtro',
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final order = loaded.serviceOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Slidable(
                                      key: ValueKey(order.id),
                                      endActionPane: ActionPane(
                                        motion: const StretchMotion(),
                                        extentRatio: 0.60,
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) =>
                                                _showEditServiceOrderForm(
                                                  context,
                                                  order,
                                                ),
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            icon: Icons.edit,
                                            label: 'Editar',
                                          ),
                                          SlidableAction(
                                            onPressed: (_) async {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text(
                                                        'Excluir ordem?',
                                                      ),
                                                      content: const Text(
                                                        'Esta ação não pode ser desfeita.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            'Excluir',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                              if (confirmed == true &&
                                                  context.mounted) {
                                                await context
                                                    .read<HomeController>()
                                                    .deleteServiceOrder(
                                                      order.id!,
                                                    );
                                              }
                                            },
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Excluir',
                                          ),
                                        ],
                                      ),
                                      child: GestureDetector(
                                        onTap: () => _showEditServiceOrderForm(
                                          context,
                                          order,
                                        ),
                                        child: ServiceOrderCard(
                                          serviceOrder: order,
                                        ),
                                      ),
                                    ),
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
    );
  }
}
