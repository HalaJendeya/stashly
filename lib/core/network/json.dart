/// Decoded JSON object.
typedef JsonMap = Map<String, dynamic>;

/// Strict readers: a shape mismatch throws [FormatException], which the
/// repository layer turns into a typed failure instead of a crash.
extension JsonRead on JsonMap {
  String str(String key) {
    final value = this[key];
    if (value is String) return value;
    throw FormatException('Expected string at "$key"');
  }

  String? strOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value;
    throw FormatException('Expected string or null at "$key"');
  }

  int integer(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    throw FormatException('Expected number at "$key"');
  }

  int? intOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw FormatException('Expected number or null at "$key"');
  }

  bool boolean(String key, {bool? fallback}) {
    final value = this[key];
    if (value is bool) return value;
    if (value == null && fallback != null) return fallback;
    throw FormatException('Expected bool at "$key"');
  }

  JsonMap obj(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Expected object at "$key"');
  }

  JsonMap? objOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Expected object or null at "$key"');
  }

  List<JsonMap> objList(String key) {
    final value = this[key];
    if (value == null) return const [];
    if (value is List) {
      return [
        for (final item in value)
          if (item is JsonMap)
            item
          else
            throw FormatException('Expected objects in "$key"'),
      ];
    }
    throw FormatException('Expected list at "$key"');
  }

  List<String> strList(String key) {
    final value = this[key];
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    throw FormatException('Expected list at "$key"');
  }

  DateTime date(String key) {
    final parsed = DateTime.tryParse(str(key));
    if (parsed == null) throw FormatException('Expected ISO date at "$key"');
    return parsed.toUtc();
  }

  DateTime? dateOrNull(String key) {
    final raw = strOrNull(key);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }
}
