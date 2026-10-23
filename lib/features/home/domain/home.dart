import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';

/// Home dashboard in one round trip (`GET /home`).
class HomeSummary {
  const HomeSummary({
    required this.displayName,
    required this.linksCount,
    required this.favoritesCount,
    required this.quickAccess,
    required this.recentLinks,
  });

  final String displayName;
  final int linksCount;
  final int favoritesCount;

  /// Up to four most recently active collections.
  final List<Collection> quickAccess;
  final List<Link> recentLinks;
}

abstract interface class HomeRepository {
  Future<Result<HomeSummary>> load({int recentLimit = 10});
}
