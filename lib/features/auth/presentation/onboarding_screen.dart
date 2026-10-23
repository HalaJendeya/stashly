import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
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

  /// Three steps; the count drives the dots and the last-step button.
  static const _stepCount = 3;

  List<({String eyebrow, String title, String body})> _steps(
    AppLocalizations l10n,
  ) => [
    (
      eyebrow: l10n.onboardingSaveEyebrow,
      title: l10n.onboardingSaveTitle,
      body: l10n.onboardingSaveBody,
    ),
    (
      eyebrow: l10n.onboardingOrganizeEyebrow,
      title: l10n.onboardingOrganizeTitle,
      body: l10n.onboardingOrganizeBody,
    ),
    (
      eyebrow: l10n.onboardingFindEyebrow,
      title: l10n.onboardingFindTitle,
      body: l10n.onboardingFindBody,
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
    final last = _index == _stepCount - 1;
    return Scaffold(
      body: StashlyBackground(
        secondGlow: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 54),
                  child: Row(
                    children: [
                      if (_index == 0)
                        const BrandMark()
                      else
                        IconTapButton(
                          icon: AppIcons.arrowLeft,
                          semanticLabel: context.l10n.actionPrevious,
                          onPressed: () => _go(_index - 1),
                        ),
                      const Spacer(),
                      TextActionButton(
                        label: context.l10n.actionSkip,
                        minHeight: 44,
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 4,
                        ),
                        style: context.text.linkButton.copyWith(
                          color: context.colors.textSecondary,
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
                    itemCount: _stepCount,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) {
                      final step = _steps(context.l10n)[index];
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 9),
                            _VisualFrame(child: _visualFor(index)),
                            const SizedBox(height: 25),
                            Text(step.eyebrow, style: context.text.eyebrow),
                            const SizedBox(height: 7),
                            Text(step.title, style: context.text.heading),
                            const SizedBox(height: 10),
                            Text(
                              step.body,
                              style: context.text.body.copyWith(height: 1.65),
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
                      label: context.l10n.onboardingStep(
                        _index + 1,
                        _stepCount,
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < _stepCount; i++) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: i == _index ? 24 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? context.colors.gold
                                    : context.colors.dotInactive,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            if (i < _stepCount - 1) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right-aligned; at least the design width, and never
                    // wider than the space left by the step dots.
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: last ? 0 : 144),
                          // Sized to its label, as in the design.
                          child: IntrinsicWidth(
                            child: PrimaryButton(
                              label: last
                                  ? context.l10n.actionGetStarted
                                  : context.l10n.actionNext,
                              authStyle: true,
                              trailingIcon: AppIcons.arrowRight,
                              horizontalPadding: 20,
                              onPressed: last
                                  ? widget.onFinished
                                  : () => _go(_index + 1),
                            ),
                          ),
                        ),
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
    // The illustration is artwork drawn at a fixed design size and scaled
    // as a whole, so its mock-UI text ignores the font-size setting.
    return ExcludeSemantics(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery.withNoTextScaling(
          child: AspectRatio(
            aspectRatio: 379.4 / 330,
            child: FittedBox(
              child: Container(
                width: 379.4,
                height: 330,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: context.colors.border, width: 1.36),
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 0.75,
                    colors: [Color(0x1FD4AF37), context.colors.card],
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
                            color: context.colors.divider,
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
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border, width: 1.36),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
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

class _TileLabel extends StatelessWidget {
  const _TileLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.text.caption.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
  );
}

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
              color: context.colors.floatingCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x40D4AF37), width: 1.36),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow,
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
                  child: AppIcon(
                    AppIcons.sparkles24,
                    size: 24,
                    color: context.colors.gold,
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
                        style: context.text.tiny.copyWith(fontSize: 8),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        context.l10n.artSavedTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.rowTitle.copyWith(
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
                  decoration: BoxDecoration(
                    color: context.colors.goldFill,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(
                    AppIcons.check15,
                    size: 15,
                    color: context.colors.onGoldAuth,
                  ),
                ),
              ],
            ),
          ),
        ),
        _FloatingTile(left: 48, top: 38, child: const _TileLabel('YT')),
        _FloatingTile(left: 295.7, top: 56, child: const _TileLabel('IG')),
        _FloatingTile(
          left: 273.7,
          top: 237.3,
          child: AppIcon(
            AppIcons.book17,
            size: 17,
            color: context.colors.textSecondary,
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
        color: context.colors.floatingCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border, width: 1.36),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
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
              color: context.colors.goldTint,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 20, color: context.colors.gold),
          ),
          const Spacer(),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.rowTitle.copyWith(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 5),
          Text(
            count,
            maxLines: 1,
            style: context.text.tiny.copyWith(fontSize: 8),
          ),
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
                      color: context.colors.subtleFill,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      tag,
                      style: context.text.tiny.copyWith(
                        fontSize: 7,
                        color: context.colors.textSecondary,
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
            child: Opacity(
              opacity: 0.66,
              child: _MiniCollectionCard(
                icon: AppIcons.book20,
                name: context.l10n.artLearning,
                count: context.l10n.artSaves(16),
              ),
            ),
          ),
        ),
        Positioned(
          left: 158.7,
          top: 67,
          child: Transform.rotate(
            angle: 5 * math.pi / 180,
            child: _MiniCollectionCard(
              icon: AppIcons.sparkles20,
              name: context.l10n.artInspiration,
              count: context.l10n.artSaves(28),
              tags: [context.l10n.artTagInteriors, context.l10n.artTagIdeas],
            ),
          ),
        ),
        Positioned(
          left: 261.7,
          top: 260.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: ShapeDecoration(
              color: context.colors.goldFill,
              shape: StadiumBorder(),
              shadows: [
                BoxShadow(
                  color: context.colors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                AppIcon(
                  AppIcons.tag15,
                  size: 15,
                  color: context.colors.onGoldAuth,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.artCurated,
                  style: context.text.micro.copyWith(
                    fontSize: 9,
                    color: context.colors.onGoldAuth,
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
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x52D4AF37), width: 1.36),
            ),
            child: Row(
              children: [
                AppIcon(
                  AppIcons.search18,
                  size: 18,
                  color: context.colors.gold,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.artQuery,
                  maxLines: 1,
                  style: context.text.bodySmall.copyWith(
                    fontSize: 11,
                    color: context.colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _ResultRow(
            domain: 'design-milk.com',
            title: context.l10n.artResultTitle,
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
          Opacity(
            opacity: 0.7,
            child: _ResultRow(
              domain: 'behance.net',
              title: context.l10n.artResultTitle2,
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
          Text(
            context.l10n.artIdeasFound(12),
            style: context.text.micro.copyWith(fontSize: 9),
          ),
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
        color: context.colors.floatingCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.colors.border, width: 1.36),
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
                  style: context.text.tiny.copyWith(fontSize: 8),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.rowTitle.copyWith(
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          AppIcon(icon, size: 15, color: context.colors.gold),
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
