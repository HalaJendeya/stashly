import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      extendBody: true,
      body: StashlyBackground(child: navigationShell),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10 + bottomInset),
        child: _BottomNav(
          currentIndex: navigationShell.currentIndex,
          onSelect: _goTo,
          onAdd: onAdd,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x6B000000),
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
              color: AppColors.navBar,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.border, width: 1.36),
            ),
            child: Row(
              children: [
                _NavItem(
                  icon: AppIcons.navHome,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
                _NavItem(
                  icon: AppIcons.navCollections,
                  label: 'Collections',
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
                SizedBox(
                  width: 58,
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: 'Save a link',
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
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(18),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onAdd,
                            child: const Center(
                              child: AppIcon(
                                AppIcons.navPlus,
                                size: 27,
                                color: AppColors.onGold,
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
                  label: 'Search',
                  selected: currentIndex == 2,
                  onTap: () => onSelect(2),
                ),
                _NavItem(
                  icon: AppIcons.navProfile,
                  label: 'Profile',
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
    final color = selected ? AppColors.goldActive : AppColors.textMuted;
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
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.navLabel.copyWith(color: color),
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
