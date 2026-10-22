import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/app/dependencies.dart';
import 'package:stashly/app/shell.dart';
import 'package:stashly/app/system_screens.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/features/auth/presentation/forgot_password_screen.dart';
import 'package:stashly/features/auth/presentation/onboarding_screen.dart';
import 'package:stashly/features/auth/presentation/register_screen.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';
import 'package:stashly/features/auth/presentation/sign_in_screen.dart';
import 'package:stashly/features/auth/presentation/welcome_screen.dart';
import 'package:stashly/features/collections/presentation/collection_detail_screen.dart';
import 'package:stashly/features/collections/presentation/collections_screen.dart';
import 'package:stashly/features/home/presentation/home_screen.dart';
import 'package:stashly/features/home/presentation/home_view_model.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/presentation/duplicate_link_screen.dart';
import 'package:stashly/features/links/presentation/edit_link_screen.dart';
import 'package:stashly/features/links/presentation/library_screen.dart';
import 'package:stashly/features/links/presentation/link_details_screen.dart';
import 'package:stashly/features/links/presentation/save_link_sheet.dart';
import 'package:stashly/features/links/presentation/shared_link_screen.dart';
import 'package:stashly/features/profile/presentation/account_screens.dart';
import 'package:stashly/features/profile/presentation/profile_screen.dart';
import 'package:stashly/features/profile/presentation/settings_screen.dart';
import 'package:stashly/features/search/presentation/search_screen.dart';

/// Routes and auth redirects. Screens receive their dependencies through
/// constructors here (the only place that knows every feature).
GoRouter createRouter(
  AppDependencies deps, {
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final session = deps.session;

  Future<void> openSaveSheet(BuildContext context) => showSaveLinkSheet(
    context,
    links: deps.links,
    collections: deps.collections,
    changes: deps.changes,
    titleMaxLength: session.config.titleMaxLength,
  );

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (context, state) => _redirect(session, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.updateRequired,
        builder: (_, _) => UpdateRequiredScreen(
          latestVersion: session.config.latestAppVersion,
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, _) => OnboardingScreen(
          onFinished: () async {
            await session.markOnboardingSeen();
            if (context.mounted) context.go(Routes.welcome);
          },
        ),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => WelcomeScreen(
          session: session,
          sessionExpired: session.sessionExpired,
        ),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => SignInScreen(session: session),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => RegisterScreen(session: session),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => ForgotPasswordScreen(auth: deps.auth),
      ),
      GoRoute(
        path: Routes.checkInbox,
        builder: (_, state) =>
            CheckInboxScreen(email: state.extra as String? ?? 'your email'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          navigationShell: shell,
          onAdd: () => openSaveSheet(context),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, _) => _HomeTab(
                  deps: deps,
                  onSaveLink: () => openSaveSheet(context),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.collections,
                builder: (_, _) => CollectionsScreen(
                  collections: deps.collections,
                  changes: deps.changes,
                  nameMaxLength: session.config.collectionNameMaxLength,
                  descriptionMaxLength:
                      session.config.collectionDescriptionMaxLength,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (_, state) {
                  final openFilters =
                      state.uri.queryParameters['filters'] == '1';
                  return SearchScreen(
                    key: ValueKey(openFilters),
                    links: deps.links,
                    search: deps.search,
                    tags: deps.tags,
                    recentSearches: deps.recentSearches,
                    changes: deps.changes,
                    openFiltersOnStart: openFilters,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => ListenableBuilder(
                  listenable: session,
                  builder: (_, _) => ProfileScreen(
                    user: session.user,
                    profile: deps.profile,
                    changes: deps.changes,
                    onRefreshUser: session.refreshUser,
                    onSignOut: session.signOut,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.library,
        builder: (_, state) => LibraryScreen(
          links: deps.links,
          changes: deps.changes,
          favoritesOnly: state.uri.queryParameters['favorites'] == '1',
        ),
      ),
      GoRoute(
        path: '/links/:id',
        builder: (_, state) => LinkDetailsScreen(
          linkId: state.pathParameters['id']!,
          links: deps.links,
          collections: deps.collections,
          tags: deps.tags,
          changes: deps.changes,
        ),
      ),
      GoRoute(
        path: '/links/:id/edit',
        builder: (_, state) => EditLinkScreen(
          linkId: state.pathParameters['id']!,
          links: deps.links,
          collections: deps.collections,
          changes: deps.changes,
          noteMaxLength: session.config.noteMaxLength,
          titleMaxLength: session.config.titleMaxLength,
          focusNote: state.uri.queryParameters['focus'] == 'note',
        ),
      ),
      GoRoute(
        path: '/collections/:id',
        builder: (_, state) => CollectionDetailScreen(
          collectionId: state.pathParameters['id']!,
          collections: deps.collections,
          links: deps.links,
          changes: deps.changes,
        ),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => ListenableBuilder(
          listenable: session,
          builder: (_, _) => SettingsScreen(
            user: session.user,
            auth: deps.auth,
            profile: deps.profile,
            appVersion: deps.appVersion,
            termsUrl: session.config.termsUrl,
            privacyUrl: session.config.privacyUrl,
            onSignOut: session.signOut,
            onAccountDeleted: session.accountDeleted,
            confirmWithGoogle: session.confirmWithGoogle,
          ),
        ),
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (_, _) => EditProfileScreen(
          user: session.user,
          auth: deps.auth,
          onUpdated: session.updateUser,
        ),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, _) => ChangePasswordScreen(auth: deps.auth),
      ),
      GoRoute(
        path: Routes.shareIntake,
        builder: (_, state) {
          // The shared text arrives in memory (extra) or was parked while
          // the user signed in; it never travels in the route string.
          final text =
              state.extra as String? ?? session.pendingSharedText ?? '';
          session.pendingSharedText = null;
          return SharedLinkScreen(
            sharedText: text,
            links: deps.links,
            collections: deps.collections,
            changes: deps.changes,
            noteMaxLength: session.config.noteMaxLength,
            titleMaxLength: session.config.titleMaxLength,
          );
        },
      ),
      GoRoute(
        path: Routes.duplicate,
        builder: (_, state) => DuplicateLinkScreen(
          existing: state.extra is Link ? state.extra! as Link : null,
          links: deps.links,
          collections: deps.collections,
          changes: deps.changes,
        ),
      ),
    ],
  );
}

String? _redirect(SessionController session, String location) {
  switch (session.status) {
    case SessionStatus.unknown:
      return location == Routes.splash ? null : Routes.splash;
    case SessionStatus.signedOut:
      if (Routes.authPaths.contains(location)) return null;
      return session.onboardingSeen ? Routes.welcome : Routes.onboarding;
    case SessionStatus.signedIn:
      if (session.updateRequired) {
        return location == Routes.updateRequired ? null : Routes.updateRequired;
      }
      if (location == Routes.splash ||
          location == Routes.updateRequired ||
          Routes.authPaths.contains(location)) {
        return session.pendingSharedText != null
            ? Routes.shareIntake
            : Routes.home;
      }
      return null;
  }
}

/// Owns the Home view model for the lifetime of the Home tab.
class _HomeTab extends StatefulWidget {
  const _HomeTab({required this.deps, required this.onSaveLink});

  final AppDependencies deps;
  final VoidCallback onSaveLink;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late final HomeViewModel _vm = HomeViewModel(
    home: widget.deps.home,
    links: widget.deps.links,
    changes: widget.deps.changes,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      viewModel: _vm,
      displayName: widget.deps.session.user?.displayName ?? '',
      onSaveLink: widget.onSaveLink,
    );
  }
}
