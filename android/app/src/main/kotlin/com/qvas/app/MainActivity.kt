package com.qvas.app

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Незалежна хаптика (рішення 36): прямий виклик вібромотора
        // замість performHapticFeedback, який система глушить, коли
        // «вібрація при дотику» вимкнена глобально. Потребує VIBRATE.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "qvas/haptics")
            .setMethodCallHandler { call, result ->
                if (call.method == "impact") {
                    impact()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun impact() {
        val vibrator = if (Build.VERSION.SDK_INT >= 31) {
            val manager =
                getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        // ВАЖЛИВО: usage мусить бути НЕ-дотиковим. Прості ефекти система
        // класифікує як TOUCH і глушить перемикачем «вібрація при дотику» —
        // саме від цього ми втікаємо (рішення 36). ALARM-канал грає завжди;
        // для клацання на 35 мс це прийнятно.
        when {
            Build.VERSION.SDK_INT >= 33 -> {
                val attrs = android.os.VibrationAttributes.Builder()
                    .setUsage(android.os.VibrationAttributes.USAGE_ALARM)
                    .build()
                vibrator.vibrate(
                    VibrationEffect.createOneShot(35, 200), attrs
                )
            }
            Build.VERSION.SDK_INT >= 26 -> {
                @Suppress("DEPRECATION")
                val attrs = android.media.AudioAttributes.Builder()
                    .setUsage(android.media.AudioAttributes.USAGE_ALARM)
                    .build()
                @Suppress("DEPRECATION")
                vibrator.vibrate(
                    VibrationEffect.createOneShot(35, 200), attrs
                )
            }
            else -> {
                // minSdk 24
                @Suppress("DEPRECATION")
                vibrator.vibrate(35)
            }
        }
    }
}
