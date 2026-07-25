package com.hitranslate.hi_translate

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.hitranslate/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canDrawOverlay" -> {
                    result.success(canDrawOverlay())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "startOverlayService" -> {
                    val text = call.argument<String>("text") ?: ""
                    val sourceLang = call.argument<String>("sourceLang") ?: "en"
                    val targetLang = call.argument<String>("targetLang") ?: "hi"
                    startOverlayService(text, sourceLang, targetLang)
                    result.success(true)
                }
                "stopOverlayService" -> {
                    stopOverlayService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun canDrawOverlay(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun startOverlayService(text: String, sourceLang: String, targetLang: String) {
        val intent = Intent(this, OverlayService::class.java).apply {
            putExtra("text", text)
            putExtra("sourceLang", sourceLang)
            putExtra("targetLang", targetLang)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopOverlayService() {
        stopService(Intent(this, OverlayService::class.java))
    }
}
