import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Asset paths of the icons exported from the Stashly Figma file.
///
/// Size suffixes (e.g. `folder16`) keep the stroke weights the design uses at
/// that size; tint is applied at the call site through [AppIcon.color].
abstract final class AppIcons {
  static const String addExisting = 'assets/icons/add_existing.svg';
  static const String arrowLeft = 'assets/icons/arrow_left.svg';
  static const String arrowRight = 'assets/icons/arrow_right.svg';
  static const String arrowRight15 = 'assets/icons/arrow_right15.svg';
  static const String book17 = 'assets/icons/book17.svg';
  static const String book20 = 'assets/icons/book20.svg';
  static const String bookmark = 'assets/icons/bookmark.svg';
  static const String bookmark15 = 'assets/icons/bookmark15.svg';
  static const String calendar = 'assets/icons/calendar.svg';
  static const String cardArrow = 'assets/icons/card_arrow.svg';
  static const String check = 'assets/icons/check.svg';
  static const String check15 = 'assets/icons/check15.svg';
  static const String checkBadge = 'assets/icons/check_badge.svg';
  static const String checkCircle = 'assets/icons/check_circle.svg';
  static const String checkCircle28 = 'assets/icons/check_circle28.svg';
  static const String checkDark = 'assets/icons/check_dark.svg';
  static const String checkboxCheck = 'assets/icons/checkbox_check.svg';
  static const String chevronDown = 'assets/icons/chevron_down.svg';
  static const String chevronRight = 'assets/icons/chevron_right.svg';
  static const String chevronRightMuted =
      'assets/icons/chevron_right_muted.svg';
  static const String chipSliders = 'assets/icons/chip_sliders.svg';
  static const String clock = 'assets/icons/clock.svg';
  static const String close = 'assets/icons/close.svg';
  static const String close19 = 'assets/icons/close19.svg';
  static const String close20 = 'assets/icons/close20.svg';
  static const String collBook = 'assets/icons/coll_book.svg';
  static const String collCompass = 'assets/icons/coll_compass.svg';
  static const String collSparkles = 'assets/icons/coll_sparkles.svg';
  static const String copy = 'assets/icons/copy.svg';
  static const String copy17 = 'assets/icons/copy17.svg';
  static const String download = 'assets/icons/download.svg';
  static const String edit = 'assets/icons/edit.svg';
  static const String edit16 = 'assets/icons/edit16.svg';
  static const String edit18 = 'assets/icons/edit18.svg';
  static const String external = 'assets/icons/external.svg';
  static const String externalDark = 'assets/icons/external_dark.svg';
  static const String eye = 'assets/icons/eye.svg';
  static const String file17 = 'assets/icons/file17.svg';
  static const String fileText = 'assets/icons/file_text.svg';
  static const String folder16 = 'assets/icons/folder16.svg';
  static const String folder17 = 'assets/icons/folder17.svg';
  static const String folder26 = 'assets/icons/folder26.svg';
  static const String folder26Alt = 'assets/icons/folder26_alt.svg';
  static const String folderInput = 'assets/icons/folder_input.svg';
  static const String folderPlus = 'assets/icons/folder_plus.svg';
  static const String folderSmall = 'assets/icons/folder_small.svg';
  static const String heart15Filled = 'assets/icons/heart15_filled.svg';
  static const String heart17 = 'assets/icons/heart17.svg';
  static const String heart17Outline = 'assets/icons/heart17_outline.svg';
  static const String heartChip = 'assets/icons/heart_chip.svg';
  static const String heartFilledCard = 'assets/icons/heart_filled_card.svg';
  static const String heartGold = 'assets/icons/heart_gold.svg';
  static const String heartHeader = 'assets/icons/heart_header.svg';
  static const String heartOutlineCard = 'assets/icons/heart_outline_card.svg';
  static const String info = 'assets/icons/info.svg';
  static const String key = 'assets/icons/key.svg';
  static const String keyDark = 'assets/icons/key_dark.svg';
  static const String languages = 'assets/icons/languages.svg';
  static const String layoutGrid = 'assets/icons/layout_grid.svg';
  static const String layoutList = 'assets/icons/layout_list.svg';
  static const String link = 'assets/icons/link.svg';
  static const String linkInput = 'assets/icons/link_input.svg';
  static const String loader = 'assets/icons/loader.svg';
  static const String lock = 'assets/icons/lock.svg';
  static const String logout = 'assets/icons/logout.svg';
  static const String mail = 'assets/icons/mail.svg';
  static const String mailLarge = 'assets/icons/mail_large.svg';
  static const String moon = 'assets/icons/moon.svg';
  static const String sun = 'assets/icons/sun.svg';
  static const String more = 'assets/icons/more.svg';
  static const String navCollections = 'assets/icons/nav_collections.svg';
  static const String navCollectionsActive =
      'assets/icons/nav_collections_active.svg';
  static const String navHome = 'assets/icons/nav_home.svg';
  static const String navHomeActive = 'assets/icons/nav_home_active.svg';
  static const String navPlus = 'assets/icons/nav_plus.svg';
  static const String navProfile = 'assets/icons/nav_profile.svg';
  static const String navProfileActive = 'assets/icons/nav_profile_active.svg';
  static const String navSearch = 'assets/icons/nav_search.svg';
  static const String note = 'assets/icons/note.svg';
  static const String plus = 'assets/icons/plus.svg';
  static const String plus17 = 'assets/icons/plus17.svg';
  static const String plus18 = 'assets/icons/plus18.svg';
  static const String save = 'assets/icons/save.svg';
  static const String search = 'assets/icons/search.svg';
  static const String search18 = 'assets/icons/search18.svg';
  static const String search25 = 'assets/icons/search25.svg';
  static const String search28 = 'assets/icons/search28.svg';
  static const String searchInput = 'assets/icons/search_input.svg';
  static const String settings18 = 'assets/icons/settings18.svg';
  static const String settings20 = 'assets/icons/settings20.svg';
  static const String share = 'assets/icons/share.svg';
  static const String shield = 'assets/icons/shield.svg';
  static const String shield16 = 'assets/icons/shield16.svg';
  static const String shield18 = 'assets/icons/shield18.svg';
  static const String shieldGold = 'assets/icons/shield_gold.svg';
  static const String sliders = 'assets/icons/sliders.svg';
  static const String sliders18 = 'assets/icons/sliders18.svg';
  static const String sort = 'assets/icons/sort.svg';
  static const String sort15 = 'assets/icons/sort15.svg';
  static const String sort17 = 'assets/icons/sort17.svg';
  static const String sparkles17 = 'assets/icons/sparkles17.svg';
  static const String sparkles20 = 'assets/icons/sparkles20.svg';
  static const String sparkles24 = 'assets/icons/sparkles24.svg';
  static const String tag15 = 'assets/icons/tag15.svg';
  static const String tagFind = 'assets/icons/tag_find.svg';
  static const String tagInput = 'assets/icons/tag_input.svg';
  static const String trash17 = 'assets/icons/trash17.svg';
  static const String trash17Red = 'assets/icons/trash17_red.svg';
  static const String trash18Red = 'assets/icons/trash18_red.svg';
  static const String trash22 = 'assets/icons/trash22.svg';
  static const String trashRed = 'assets/icons/trash_red.svg';
  static const String typeArticle = 'assets/icons/type_article.svg';
  static const String user = 'assets/icons/user.svg';
  static const String user18 = 'assets/icons/user18.svg';
  static const String userGold = 'assets/icons/user_gold.svg';
  static const String x12 = 'assets/icons/x12.svg';
  static const String xInput = 'assets/icons/x_input.svg';
}

/// Renders a Figma icon, optionally re-tinted (all icons are single-colour strokes).
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size = 20,
    this.color,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final Color? color;

  /// Set for icon-only controls so screen readers announce them (CLAUDE.md §4).
  final String? semanticLabel;

  /// Arrows and chevrons that point "forward" or "back"; they flip in
  /// right-to-left languages such as Arabic.
  static const _directional = {
    AppIcons.arrowLeft,
    AppIcons.arrowRight,
    AppIcons.arrowRight15,
    AppIcons.cardArrow,
    AppIcons.chevronRight,
    AppIcons.chevronRightMuted,
    AppIcons.logout,
  };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      matchTextDirection: _directional.contains(asset),
    );
  }
}
