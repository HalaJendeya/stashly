package com.example.stashly

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hands text shared from other apps (ACTION_SEND, text/plain) to Flutter.
 *
 * Only the raw shared text crosses the channel; URL extraction and validation
 * happen in Dart, where the input is treated as untrusted.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingShare: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    // Cold start: Dart asks once for the text that launched the app.
                    "takeInitialShare" -> {
                        result.success(pendingShare)
                        pendingShare = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
        pendingShare = extractSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Warm start (singleTop): push the share straight to Dart.
        extractSharedText(intent)?.let { channel?.invokeMethod("onShare", it) }
    }

    private fun extractSharedText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return null
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()
        // Cap the payload: anything longer cannot contain a valid (≤2048 char) link worth parsing.
        return text?.takeIf { it.isNotEmpty() }?.take(MAX_SHARED_TEXT)
    }

    companion object {
        private const val CHANNEL = "stashly/share"
        private const val MAX_SHARED_TEXT = 8192
    }
}
