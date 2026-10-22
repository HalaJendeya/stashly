import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';

/// Tab scaffold with the floating bottom navigation (Figma BottomNav):
/// Home, Collections, centre "+", Search, Profile.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.onAdd,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onAdd;

  void _goTo(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab returns it to its first page.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final onHome = navigationShell.currentIndex == 0;
    return PopScope<Object?>(
      // System back on another tab returns to Home; on Home it leaves the app.
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        extendBody: true,
        body: StashlyBackground(
          // Each tab has its own navigator, which tells Android "nothing to
          // go back to" when it has a single page. With predictive back
          // (Android 14+, default on 16) Android would then close the app
          // instead of letting the PopScope above return to Home, so off Home
          // the shell reports that it handles back — as Navigator does for
          // its own children.
          child: NotificationListener<NavigationNotification>(
            onNotification: (notification) {
              if (notification.canHandlePop || onHome) return false;
              const NavigationNotification(
                canHandlePop: true,
              ).dispatch(context);
              return true;
            },
            child: navigationShell,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10 + bottomInset),
          // Like Material's NavigationBar, tab labels stop growing at 1.3x
          // so the bar keeps its height; labels stay in the accessibility tree.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: _BottomNav(
              currentIndex: navigationShell.currentIndex,
              onSelect: _goTo,
              onAdd: onAdd,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onSelect,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 48,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: context.colors.navBar,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: context.colors.border, width: 1.36),
            ),
            child: Row(
              children: [
                _NavItem(
                  icon: AppIcons.navHome,
                  label: context.l10n.navHome,
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
                _NavItem(
                  icon: AppIcons.navCollections,
                  label: context.l10n.navCollections,
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
                SizedBox(
                  width: 58,
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: context.l10n.navSaveLink,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33D4AF37),
                              blurRadius: 12,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: context.colors.goldFill,
                          borderRadius: BorderRadius.circular(18),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onAdd,
                            child: Center(
                              child: AppIcon(
                                AppIcons.navPlus,
                                size: 27,
                                color: context.colors.onGold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: AppIcons.navSearch,
                  label: context.l10n.navSearch,
                  selected: currentIndex == 2,
                  onTap: () => onSelect(2),
                ),
                _NavItem(
                  icon: AppIcons.navProfile,
                  label: context.l10n.navProfile,
                  selected: currentIndex == 3,
                  onTap: () => onSelect(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.goldActive
        : context.colors.textMuted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(icon, size: 21, color: color),
                const SizedBox(height: 4),
                ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: context.text.navLabel.copyWith(color: color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
