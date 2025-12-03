import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:flutter/material.dart';

class ServiceOrderCard extends StatelessWidget {
  final ServiceOrder serviceOrder;

  const ServiceOrderCard({super.key, required this.serviceOrder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceOrder.task,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Responsável: ${serviceOrder.responsible}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.start,
                      children: [
                        Chip(
                          label: Text(
                            serviceOrder.active == 1 ? 'Ativa' : 'Inativa',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: serviceOrder.active == 1
                              ? cs.tertiaryContainer
                              : cs.errorContainer.withValues(alpha: 0.20),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: serviceOrder.active == 1
                                  ? cs.tertiary
                                  : cs.error,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: serviceOrder.active == 1
                                ? cs.onTertiaryContainer
                                : cs.error,
                          ),
                        ),
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
              ),
            ),
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(
                  left: BorderSide(color: cs.outlineVariant, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Início',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(serviceOrder.startPrevison),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.75, color: cs.outlineVariant),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Término',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
