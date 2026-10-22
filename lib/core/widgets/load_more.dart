import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/buttons.dart';

/// "Load more" button under paginated lists (Figma library footer).
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key, required this.controller});

  final PagedController<Object?> controller;

  @override
  Widget build(BuildContext context) {
    final failure = controller.loadMoreFailure;
    if (!controller.hasMore && failure == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failure != null) ...[
            Text(
              failure.describe(context.l10n),
              textAlign: TextAlign.center,
              style: context.text.micro.copyWith(color: context.colors.danger),
            ),
            const SizedBox(height: 8),
          ],
          SecondaryButton(
            label: failure == null
                ? context.l10n.actionLoadMore
                : context.l10n.actionTryAgain,
            loading: controller.loadingMore,
            textStyle: context.text.bodySmall,
            onPressed: controller.loadMore,
          ),
        ],
      ),
    );
  }
}
