import 'dart:typed_data';

import 'package:stashly/core/result/result.dart';

/// Counts shown on Profile (`GET /me/stats`).
class AccountStats {
  const AccountStats({
    required this.linksCount,
    required this.collectionsCount,
    required this.favoritesCount,
  });

  final int linksCount;
  final int collectionsCount;
  final int favoritesCount;
}

/// The JSON export file returned by `GET /me/export`.
class DataExport {
  const DataExport({required this.filename, required this.bytes});

  final String filename;
  final Uint8List bytes;
}

abstract interface class ProfileRepository {
  Future<Result<AccountStats>> stats();

  /// Rate limited to one export per 10 minutes by the server.
  Future<Result<DataExport>> exportData();
}
