import 'package:http/http.dart' as http;

import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/storage/key_value_store.dart';
import 'package:stashly/features/app_config/data/http_app_config_repository.dart';
import 'package:stashly/features/app_config/domain/app_config.dart';
import 'package:stashly/features/auth/data/http_auth_repository.dart';
import 'package:stashly/features/auth/data/google_sign_in_identity.dart';
import 'package:stashly/features/auth/data/token_store.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/auth/domain/google_identity.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';
import 'package:stashly/features/collections/data/http_collections_repository.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/home/data/http_home_repository.dart';
import 'package:stashly/features/home/domain/home.dart';
import 'package:stashly/features/links/data/http_links_repository.dart';
import 'package:stashly/features/links/data/link_mapper.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/profile/data/http_profile_repository.dart';
import 'package:stashly/features/profile/domain/profile.dart';
import 'package:stashly/features/search/data/search_data.dart';
import 'package:stashly/features/search/domain/search.dart';
import 'package:stashly/features/share_intake/data/share_channel.dart';
import 'package:stashly/features/share_intake/domain/shared_link_source.dart';

/// Build-time configuration, injected with `--dart-define` (no secrets).
abstract final class AppEnvironment {
  /// The deployed API. For a local `php artisan serve`, an emulator uses
  /// `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1`.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://stashly.labbaass.com/api/v1',
  );

  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// OAuth *Web* client ID that the backend verifies ID tokens against (its
  /// `GOOGLE_CLIENT_ID`). Public, not a secret. Empty disables Google sign-in.
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
}

/// Composition root: every repository and app-wide controller, created once
/// and passed down by constructor (no service locator).
class AppDependencies {
  AppDependencies({
    required this.api,
    required this.auth,
    required this.links,
    required this.collections,
    required this.tags,
    required this.home,
    required this.profile,
    required this.search,
    required this.config,
    required this.recentSearches,
    required this.sharedText,
    required this.session,
    required this.changes,
    required this.appVersion,
  });

  factory AppDependencies.create({
    http.Client? httpClient,
    TokenStore? tokenStore,
    KeyValueStore? preferences,
    SharedTextSource? sharedText,
    GoogleIdentity? google,
    String baseUrl = AppEnvironment.apiBaseUrl,
    String appVersion = AppEnvironment.appVersion,
  }) {
    final tokens = tokenStore ?? SecureTokenStore();
    final prefs = preferences ?? FileKeyValueStore();
    final api = ApiClient(
      baseUri: Uri.parse(baseUrl),
      httpClient: httpClient ?? http.Client(),
      tokens: tokens,
      appVersion: appVersion,
    );
    final auth = HttpAuthRepository(api, tokens);
    final googleIdentity =
        google ??
        GoogleSignInIdentity(
          serverClientId: AppEnvironment.googleServerClientId,
        );
    final config = HttpAppConfigRepository(api);
    final recent = LocalRecentSearchStore(prefs);
    return AppDependencies(
      api: api,
      auth: auth,
      links: HttpLinksRepository(api),
      collections: HttpCollectionsRepository(api),
      tags: HttpTagsRepository(api),
      home: HttpHomeRepository(
        api,
        parseLink: LinkMapper.link,
        parseCollection: CollectionMapper.collection,
      ),
      profile: HttpProfileRepository(api),
      search: HttpSearchRepository(api),
      config: config,
      recentSearches: recent,
      sharedText: sharedText ?? ShareChannel(),
      session: SessionController(
        auth: auth,
        google: googleIdentity,
        config: config,
        preferences: prefs,
        recentSearches: recent,
        unauthenticatedEvents: api.onUnauthenticated,
        appVersion: appVersion,
      ),
      changes: DataChanges(),
      appVersion: appVersion,
    );
  }

  final ApiClient api;
  final AuthRepository auth;
  final LinksRepository links;
  final CollectionsRepository collections;
  final TagsRepository tags;
  final HomeRepository home;
  final ProfileRepository profile;
  final SearchRepository search;
  final AppConfigRepository config;
  final RecentSearchStore recentSearches;
  final SharedTextSource sharedText;
  final SessionController session;
  final DataChanges changes;
  final String appVersion;

  void dispose() {
    session.dispose();
    changes.dispose();
    api.dispose();
  }
}
