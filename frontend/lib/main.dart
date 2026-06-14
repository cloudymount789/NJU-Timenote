import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/repositories/repository_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repositories = await RepositoryFactory.persistent();
  runApp(TimenoteApp(repositories: repositories));
}
