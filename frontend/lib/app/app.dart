import 'package:flutter/material.dart';

import '../core/time/app_clock.dart';
import '../data/repositories/app_repositories.dart';
import '../data/repositories/repository_factory.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class TimenoteApp extends StatelessWidget {
  const TimenoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      clock: const AppClock(),
      repositories: RepositoryFactory.local(const AppClock()),
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
  const AppScope({
    required this.repositories,
    required this.clock,
    required super.child,
    super.key,
  });

  final AppRepositories repositories;
  final AppClock clock;

  static AppRepositories repositoriesOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this context.');
    return scope!.repositories;
  }

  static AppClock clockOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this context.');
    return scope!.clock;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return repositories != oldWidget.repositories || clock != oldWidget.clock;
  }
}
