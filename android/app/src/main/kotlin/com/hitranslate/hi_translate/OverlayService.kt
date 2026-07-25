package com.hitranslate.hi_translate

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.TextView
import android.widget.LinearLayout
import android.widget.ImageView
import android.graphics.Color
import android.graphics.drawable.GradientDrawable

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    companion object {
        private const val CHANNEL_ID = "translate_overlay"
        private const val NOTIFICATION_ID = 1001
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val text = intent?.getStringExtra("text") ?: ""
        val targetLang = intent?.getStringExtra("targetLang") ?: "hi"
        showOverlay(text, targetLang)
        return START_NOT_STICKY
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun showOverlay(text: String, targetLang: String) {
        removeOverlay()

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 50
            y = 300
        }

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 24, 32, 24)
            val bg = GradientDrawable().apply {
                setColor(Color.parseColor("#1A1A2E"))
                cornerRadius = 24f
                setStroke(2, Color.parseColor("#E94560"))
            }
            background = bg
            elevation = 16f
        }

        val originalText = TextView(this).apply {
            this.text = text
            setTextColor(Color.parseColor("#AAAAAA"))
            textSize = 14f
            setPadding(0, 0, 0, 8)
        }

        val translatedText = TextView(this).apply {
            this.text = "Translated text will appear here..."
            setTextColor(Color.WHITE)
            textSize = 16f
            setPadding(0, 8, 0, 0)
        }

        val closeBtn = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
            setColorFilter(Color.parseColor("#E94560"))
            val params = LinearLayout.LayoutParams(48, 48)
            params.gravity = Gravity.END
            layoutParams = params
            setOnClickListener {
                removeOverlay()
                stopSelf()
            }
        }

        container.addView(originalText)
        container.addView(translatedText)
        container.addView(closeBtn)

        overlayView = container

        var offsetX = 0
        var offsetY = 0
        var initialX = 0
        var initialY = 0
        var touching = false

        container.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    touching = true
                    initialX = event.rawX.toInt()
                    initialY = event.rawY.toInt()
                    offsetX = layoutParams.x
                    offsetY = layoutParams.y
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    if (touching) {
                        layoutParams.x = offsetX + (event.rawX.toInt() - initialX)
                        layoutParams.y = offsetY + (event.rawY.toInt() - initialY)
                        windowManager?.updateViewLayout(container, layoutParams)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    touching = false
                    true
                }
                else -> false
            }
        }

        windowManager?.addView(container, layoutParams)
    }

    private fun removeOverlay() {
        overlayView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) { }
            overlayView = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Translation Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows floating translation overlay"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Free Translator")
                .setContentText("Floating translator is active")
                .setSmallIcon(android.R.drawable.ic_menu_translate)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Free Translator")
                .setContentText("Floating translator is active")
                .setSmallIcon(android.R.drawable.ic_menu_translate)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }

    override fun onDestroy() {
        removeOverlay()
        super.onDestroy()
    }
}
