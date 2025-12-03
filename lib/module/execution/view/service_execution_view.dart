import 'package:app_service_order/module/execution/view/widgets/service_execution_dialog.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
              .where((e) => (e.active) == 1)
              .where((e) => !e.status.toLowerCase().contains('finaliz'))
              .toList();
          return Scaffold(
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Slidable(
                            key: ValueKey('exec-${order.id}'),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(), 
                              extentRatio: 0.50,
                              children: [
                                SlidableAction(
                                  onPressed: (_) =>
                                      _openExecutionDialog(context, order),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.assignment,
                                  label: 'Preencher',
                                ),
                              ],
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 2,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.zero,
                              ),
                              child: ListTile(
                                title: Text(
                                  order.task,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Responsável: ${order.responsible}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    _openExecutionDialog(context, order),
                              ),
                            ),
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

  Future<void> _openExecutionDialog(
    BuildContext context,
    ServiceOrder order,
  ) async {
    final controller = context.read<HomeController>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceExecutionDialog(
        serviceOrder: order,
        homeController: controller,
      ),
    );

    if (result == true && context.mounted) {
      await context.read<HomeController>().fetchServiceOrders();
    }
  }
}
