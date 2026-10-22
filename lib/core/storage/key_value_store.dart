import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Small persistent store for non-sensitive preferences (onboarding flag,
/// recent searches). Tokens never go here; they live in secure storage.
abstract interface class KeyValueStore {
  Future<Object?> read(String key);
  Future<void> write(String key, Object? value);
  Future<void> remove(String key);
}

/// [KeyValueStore] backed by one JSON file in the app support directory.
class FileKeyValueStore implements KeyValueStore {
  FileKeyValueStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  Map<String, Object?>? _cache;

  Future<File> get _file async =>
      File('${(await _directory()).path}/stashly_prefs.json');

  Future<Map<String, Object?>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final file = await _file;
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, Object?>) return _cache = decoded;
      }
    } on Exception catch (error) {
      // A corrupt prefs file must not block the app; start fresh.
      developer.log('Preferences unreadable: $error', name: 'stashly.storage');
    }
    return _cache = {};
  }

  Future<void> _flush() async {
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(_cache));
  }

  @override
  Future<Object?> read(String key) async => (await _load())[key];

  @override
  Future<void> write(String key, Object? value) async {
    (await _load())[key] = value;
    await _flush();
  }

  @override
  Future<void> remove(String key) async {
    (await _load()).remove(key);
    await _flush();
  }
}

/// In-memory [KeyValueStore] for tests and previews.
class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object?> values = {};

  @override
  Future<Object?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Object? value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
