/// Text shared into Stashly from other apps (Android ACTION_SEND).
abstract interface class SharedTextSource {
  /// Text that launched the app (cold start), delivered at most once.
  Future<String?> takeInitialShare();

  /// Shares received while the app is running (warm start).
  Stream<String> get shares;
}
