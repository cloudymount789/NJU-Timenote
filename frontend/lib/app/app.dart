import 'package:flutter/material.dart';

import '../data/repositories/app_repositories.dart';
import '../data/repositories/repository_factory.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class TimenoteApp extends StatelessWidget {
  const TimenoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repositories: RepositoryFactory.local(),
      child: MaterialApp(
        title: 'NJU Timenote',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.home,
      ),
    );
  }
}

class AppScope extends InheritedWidget {
  const AppScope({required this.repositories, required super.child, super.key});

  final AppRepositories repositories;

  static AppRepositories repositoriesOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this context.');
    return scope!.repositories;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return repositories != oldWidget.repositories;
  }
}
