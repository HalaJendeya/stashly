import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'package:stashly/features/share_intake/domain/shared_link_source.dart';

/// [SharedTextSource] backed by the `stashly/share` MethodChannel implemented
/// in `MainActivity.kt`. Payloads are untrusted plain text.
class ShareChannel implements SharedTextSource {
  ShareChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('stashly/share') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onShare' && call.arguments is String) {
        _controller.add(call.arguments as String);
      }
    });
  }

  final MethodChannel _channel;
  final _controller = StreamController<String>.broadcast();

  @override
  Stream<String> get shares => _controller.stream;

  @override
  Future<String?> takeInitialShare() async {
    try {
      return await _channel.invokeMethod<String>('takeInitialShare');
    } on MissingPluginException {
      // Platforms without the channel (tests, iOS for now) have no share intake.
      return null;
    } on PlatformException catch (error) {
      developer.log(
        'Share intake unavailable: ${error.code}',
        name: 'stashly.share',
      );
      return null;
    }
  }
}
