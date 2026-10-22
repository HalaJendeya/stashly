import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/state_views.dart';

/// Three-step introduction shown on first launch (Figma 1:610, 1:674, 1:749).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  /// Called by Skip and Get Started.
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  static const _steps = [
    (
      eyebrow: 'SAVE IN A MOMENT',
      title: 'Save what matters',
      body:
          'Share useful links from the apps you already use. Stashly keeps the '
          'source, not a downloaded copy.',
    ),
    (
      eyebrow: 'MAKE IT YOURS',
      title: 'Organize your world',
      body:
          'Collections and tags add structure when you want it—and stay out of '
          'the way when you don’t.',
    ),
    (
      eyebrow: 'READY WHEN YOU ARE',
      title: 'Find it when you need it',
      body:
          'Search across titles, sources, collections, and favorites to '
          'rediscover the right link fast.',
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) => _pages.animateToPage(
    page,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final last = _index == _steps.length - 1;
    return Scaffold(
      body: StashlyBackground(
        secondGlow: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      if (_index == 0)
                        const BrandMark()
                      else
                        IconTapButton(
                          icon: AppIcons.arrowLeft,
                          semanticLabel: 'Previous',
                          onPressed: () => _go(_index - 1),
                        ),
                      const Spacer(),
                      TextActionButton(
                        label: 'Skip',
                        minHeight: 44,
                        padding: const EdgeInsets.only(left: 16, right: 4),
                        style: AppTextStyles.linkButton.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: widget.onFinished,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _steps.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 9),
                            _VisualFrame(child: _visualFor(index)),
                            const SizedBox(height: 25),
                            Text(step.eyebrow, style: AppTextStyles.eyebrow),
                            const SizedBox(height: 7),
                            Text(step.title, style: AppTextStyles.heading),
                            const SizedBox(height: 10),
                            Text(
                              step.body,
                              style: AppTextStyles.body.copyWith(height: 1.65),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Semantics(
                      label: 'Step ${_index + 1} of ${_steps.length}',
                      child: Row(
                        children: [
                          for (var i = 0; i < _steps.length; i++) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: i == _index ? 24 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? AppColors.gold
                                    : AppColors.dotInactive,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            if (i < _steps.length - 1) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: last ? null : 144,
                      child: PrimaryButton(
                        label: last ? 'Get Started' : 'Next',
                        authStyle: true,
                        trailingIcon: AppIcons.arrowRight,
                        horizontalPadding: 20,
                        onPressed: last
                            ? widget.onFinished
                            : () => _go(_index + 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _visualFor(int index) => switch (index) {
    0 => const _SaveVisual(),
    1 => const _OrganizeVisual(),
    _ => const _FindVisual(),
  };
}

/// Draws a visual on the design's 379×330 canvas and scales it to fit.
class _VisualFrame extends StatelessWidget {
  const _VisualFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 379.4 / 330,
        child: FittedBox(
          child: Container(
            width: 379.4,
            height: 330,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.border, width: 1.36),
              gradient: const RadialGradient(
                center: Alignment(0, -0.3),
                radius: 0.75,
                colors: [Color(0x1FD4AF37), AppColors.card],
                stops: [0, 0.45],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    width: 336.7,
                    height: 287.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(155.5),
                      border: Border.all(
                        color: const Color(0x0AFFFFFF),
                        width: 1.36,
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingTile extends StatelessWidget {
  const _FloatingTile({
    required this.left,
    required this.top,
    required this.child,
  });

  final double left;
  final double top;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.36),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D000000),
              blurRadius: 16,
              offset: Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

Widget _tileLabel(String text) => Text(
  text,
  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
);

class _SaveVisual extends StatelessWidget {
  const _SaveVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 83,
          top: 76,
          child: Transform.rotate(
            angle: -9 * math.pi / 180,
            child: CustomPaint(
              size: const Size(215, 174),
              painter: _DashedOvalPainter(),
            ),
          ),
        ),
        Positioned(
          left: 53.35,
          top: 104.8,
          child: Container(
            width: 270,
            height: 83,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.floatingCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x40D4AF37), width: 1.36),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6B000000),
                  blurRadius: 25,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: const RadialGradient(
                      center: Alignment(0.4, -0.6),
                      radius: 0.9,
                      colors: [Color(0x59D4AF37), Color(0xFF302817)],
                      stops: [0, 0.35],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const AppIcon(
                    AppIcons.sparkles24,
                    size: 24,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'design-milk.com',
                        maxLines: 1,
                        style: AppTextStyles.tiny,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Spaces worth remembering',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.rowTitle.copyWith(
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 11),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const AppIcon(
                    AppIcons.check15,
                    size: 15,
                    color: AppColors.onGoldAuth,
                  ),
                ),
              ],
            ),
          ),
        ),
        _FloatingTile(left: 48, top: 38, child: _tileLabel('YT')),
        _FloatingTile(left: 295.7, top: 56, child: _tileLabel('IG')),
        const _FloatingTile(
          left: 273.7,
          top: 237.3,
          child: AppIcon(
            AppIcons.book17,
            size: 17,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MiniCollectionCard extends StatelessWidget {
  const _MiniCollectionCard({
    required this.icon,
    required this.name,
    required this.count,
    this.tags = const [],
  });

  final String icon;
  final String name;
  final String count;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.floatingCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 16,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.goldTint,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 20, color: AppColors.gold),
          ),
          const Spacer(),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.rowTitle.copyWith(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 5),
          Text(count, maxLines: 1, style: AppTextStyles.tiny),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              clipBehavior: Clip.hardEdge,
              children: [
                for (final tag in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.subtleFill,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.tiny.copyWith(
                        fontSize: 7,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrganizeVisual extends StatelessWidget {
  const _OrganizeVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 41,
          top: 48,
          child: Transform.rotate(
            angle: -8 * math.pi / 180,
            child: const Opacity(
              opacity: 0.66,
              child: _MiniCollectionCard(
                icon: AppIcons.book20,
                name: 'Learning',
                count: '16 saves',
              ),
            ),
          ),
        ),
        Positioned(
          left: 158.7,
          top: 67,
          child: Transform.rotate(
            angle: 5 * math.pi / 180,
            child: const _MiniCollectionCard(
              icon: AppIcons.sparkles20,
              name: 'Inspiration',
              count: '28 saves',
              tags: ['#interiors', '#ideas'],
            ),
          ),
        ),
        Positioned(
          left: 261.7,
          top: 260.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const ShapeDecoration(
              color: AppColors.gold,
              shape: StadiumBorder(),
              shadows: [
                BoxShadow(
                  color: Color(0x3D000000),
                  blurRadius: 16,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                const AppIcon(
                  AppIcons.tag15,
                  size: 15,
                  color: AppColors.onGoldAuth,
                ),
                const SizedBox(width: 6),
                Text(
                  'Curated',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.onGoldAuth,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FindVisual extends StatelessWidget {
  const _FindVisual();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 54, 25, 0),
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x52D4AF37), width: 1.36),
            ),
            child: Row(
              children: [
                const AppIcon(
                  AppIcons.search18,
                  size: 18,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 10),
                Text(
                  'design inspiration',
                  maxLines: 1,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          const _ResultRow(
            domain: 'design-milk.com',
            title: 'Quiet modern spaces',
            icon: AppIcons.heart15Filled,
            thumbnail: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(11)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B2821), Color(0xB3D4AF37)],
                stops: [0.45, 1],
              ),
            ),
          ),
          const SizedBox(height: 11),
          const Opacity(
            opacity: 0.7,
            child: _ResultRow(
              domain: 'behance.net',
              title: 'Brand systems to revisit',
              icon: AppIcons.bookmark15,
              thumbnail: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(11)),
                gradient: RadialGradient(
                  center: Alignment(0.3, -0.3),
                  radius: 0.4,
                  colors: [Color(0xFF8A7BC1), Color(0xFF292636)],
                  stops: [0, 0.6],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('12 ideas found', style: AppTextStyles.micro),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.domain,
    required this.title,
    required this.icon,
    required this.thumbnail,
  });

  final String domain;
  final String title;
  final String icon;
  final BoxDecoration thumbnail;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.7,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xEB1F1F23),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border, width: 1.36),
      ),
      child: Row(
        children: [
          Container(width: 43, height: 43, decoration: thumbnail),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domain,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tiny,
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          AppIcon(icon, size: 15, color: AppColors.gold),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}

class _DashedOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addOval(Offset.zero & size);
    DashedBorderPainter.paintDashedPath(
      canvas,
      path,
      Paint()
        ..color = const Color(0x33D4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.36,
    );
  }

  @override
  bool shouldRepaint(_DashedOvalPainter oldDelegate) => false;
}
