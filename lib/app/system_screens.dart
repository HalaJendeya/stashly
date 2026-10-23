import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/state_views.dart';

/// Shown while the stored session is being checked on launch.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StashlyBackground(
        secondGlow: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(size: 76, large: true),
              SizedBox(height: 24),
              LoadingView(padding: EdgeInsets.zero),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blocks the app when the server no longer supports this version
/// (`min_supported_app_version` from `GET /config`).
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key, required this.latestVersion});

  final String? latestVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StashlyBackground(
        secondGlow: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(size: 76, large: true),
                const SizedBox(height: 28),
                Text(context.l10n.updateEyebrow, style: context.text.eyebrow),
                const SizedBox(height: 7),
                Text(context.l10n.updateTitle, style: context.text.heading),
                const SizedBox(height: 10),
                Text(
                  latestVersion == null
                      ? context.l10n.updateBody
                      : context.l10n.updateBodyVersion(latestVersion!),
                  style: context.text.body.copyWith(height: 1.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
