import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stashly/app/app.dart';
import 'package:stashly/app/dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0B0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(StashlyApp(deps: AppDependencies.create()));
}
