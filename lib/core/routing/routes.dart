/// Route paths. Features navigate by path so they never import each other's
/// presentation layers.
abstract final class Routes {
  static const splash = '/splash';
  static const updateRequired = '/update-required';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const checkInbox = '/check-inbox';

  static const home = '/home';
  static const collections = '/collections';
  static const search = '/search';
  static const profile = '/profile';

  static const library = '/library';
  static const settings = '/settings';
  static const editProfile = '/settings/profile';
  static const changePassword = '/settings/password';
  static const shareIntake = '/share';

  /// "Already in Stashly" (the existing link is passed as `extra`).
  static const duplicate = '/duplicate';

  static String link(String id) => '/links/$id';
  static String editLink(String id) => '/links/$id/edit';
  static String collection(String id) => '/collections/$id';

  /// Library pre-filtered to favourites.
  static const favorites = '/library?favorites=1';

  static const authPaths = {
    onboarding,
    welcome,
    signIn,
    register,
    forgotPassword,
    checkInbox,
  };
}
