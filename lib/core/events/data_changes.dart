import 'package:flutter/foundation.dart';

enum DataTopic { links, collections, account }

/// Lets screens refresh after something changed elsewhere (e.g. Home reloads
/// after a link is saved from the share sheet) without coupling features.
class DataChanges extends ChangeNotifier {
  final Map<DataTopic, int> _versions = {
    for (final t in DataTopic.values) t: 0,
  };

  int version(DataTopic topic) => _versions[topic]!;

  void notify(Set<DataTopic> topics) {
    for (final topic in topics) {
      _versions[topic] = _versions[topic]! + 1;
    }
    notifyListeners();
  }
}
