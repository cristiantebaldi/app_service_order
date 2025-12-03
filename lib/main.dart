import 'package:app_service_order/core/theme/theme_cubit.dart';
import 'package:app_service_order/di/injection.dart';
import 'package:app_service_order/module/home/view/home_view.dart';
import 'package:app_service_order/module/execution/view/service_execution_view.dart';
import 'package:app_service_order/module/home/controller/home_controller.dart';
import 'package:app_service_order/module/navigation/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'App Service Order',
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[HomeView(), const ServiceExecutionView()];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<NavigationCubit>()),
        BlocProvider(create: (_) => getIt<HomeController>()),
      ],
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ordens de Serviço'),
              actions: [
                IconButton(
                  icon: context.watch<ThemeCubit>().state == ThemeMode.dark
                      ? const Icon(Icons.light_mode)
                      : const Icon(Icons.dark_mode),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ],
            ),
            body: IndexedStack(index: currentIndex, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                context.read<NavigationCubit>().navigateTo(index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt),
                  label: 'Ordens',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: 'Atendimentos',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
