/// Client-side URL handling for UX only. The server re-validates and owns
/// normalization and duplicate detection (CLAUDE.md §6, §7).
abstract final class UrlUtils {
  static const int maxLength = 2048;

  static final RegExp _scheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:');
  static final RegExp _urlInText = RegExp(
    r'''(?:https?://|www\.)[^\s<>"'`]+''',
    caseSensitive: false,
  );

  /// Trims and adds `https://` when the user typed a bare host. Returns null
  /// for anything that is not an acceptable http(s) link.
  static String? prepareForSave(String input) {
    var text = input.trim();
    if (text.isEmpty || text.length > maxLength) return null;
    if (!_scheme.hasMatch(text)) {
      text = 'https://$text';
    }
    final uri = Uri.tryParse(text);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (uri.host.isEmpty ||
        !uri.host.contains('.') && uri.host != 'localhost') {
      return null;
    }
    // Credentials in links are a phishing vector; the API rejects them too.
    if (uri.userInfo.isNotEmpty) return null;
    return text.length > maxLength ? null : text;
  }

  /// Explains why [input] can't be saved, or null when it is acceptable.
  static String? validationMessage(String input) {
    final text = input.trim();
    if (text.isEmpty) return 'Paste a link to save.';
    if (text.length > maxLength) return 'Links can be at most 2048 characters.';
    final scheme = _scheme.firstMatch(text)?.group(0)?.toLowerCase();
    if (scheme != null && scheme != 'http:' && scheme != 'https:') {
      return 'Only http and https links can be saved.';
    }
    return prepareForSave(text) == null ? 'Enter a valid web link.' : null;
  }

  /// Finds the first web link inside text shared from another app
  /// (e.g. "Look at this https://…"). Shared input is untrusted.
  static String? extractFromSharedText(String sharedText) {
    final match = _urlInText.firstMatch(sharedText);
    if (match == null) return prepareForSave(sharedText);
    var candidate = match.group(0)!;
    // Drop trailing punctuation that usually belongs to the sentence.
    candidate = candidate.replaceFirst(RegExp(r'[).,;:!?\]]+$'), '');
    return prepareForSave(candidate);
  }

  /// Display host without `www.` (falls back to the raw text).
  static String displayHost(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    if (host.isEmpty) return url;
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}
