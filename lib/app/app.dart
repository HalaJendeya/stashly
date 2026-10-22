import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/app/dependencies.dart';
import 'package:stashly/app/router.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_theme.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';

/// Root widget: theme, router, session bootstrap and share intake.
class StashlyApp extends StatefulWidget {
  const StashlyApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<StashlyApp> createState() => _StashlyAppState();
}

class _StashlyAppState extends State<StashlyApp> {
  late final GoRouter _router = createRouter(widget.deps);
  StreamSubscription<String>? _shares;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final session = widget.deps.session;
    // Cold start from the share sheet: park the text until the session is known.
    final initial = await widget.deps.sharedText.takeInitialShare();
    if (initial != null) session.pendingSharedText = initial;
    _shares = widget.deps.sharedText.shares.listen(_onShare);
    await session.bootstrap();
  }

  /// Warm start: open the share flow now, or after sign-in.
  void _onShare(String text) {
    final session = widget.deps.session;
    if (session.status == SessionStatus.signedIn && !session.updateRequired) {
      _router.push(Routes.shareIntake, extra: text);
    } else {
      session.pendingSharedText = text;
    }
  }

  @override
  void dispose() {
    _shares?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stashly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
