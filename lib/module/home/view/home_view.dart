import 'package:app_service_order/di/injection.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/home/core/domain/model/service_order.dart';
import 'package:app_service_order/module/home/state/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  final controller = getIt<HomeController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => controller,
      child: BlocBuilder<HomeController, HomeState>(
        builder: (context, state) {
          return Scaffold(
            body: Builder(
              builder: (context) {
                if (state is HomeLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is HomeLoaded) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return Text(state.serviceOrders[index].task);
                    },
                    itemCount: state.serviceOrders.length,
                  );
                }
                return Center(child: Text('Estado inicial'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final serviceOrder = await Navigator.push<ServiceOrder>(
                  context,
                  MaterialPageRoute(builder: (_) => HomeView()),
                );

                if (serviceOrder != null && context.mounted) {
                  controller.createServiceOrderUsecase(serviceOrder);
                }
              },
              child: Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

}