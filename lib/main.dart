import 'package:flutter/material.dart';

import 'package:stashly/app/app.dart';
import 'package:stashly/app/dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // System bar colours follow the active theme (see AppViewport).
  runApp(StashlyApp(deps: AppDependencies.create()));
}
