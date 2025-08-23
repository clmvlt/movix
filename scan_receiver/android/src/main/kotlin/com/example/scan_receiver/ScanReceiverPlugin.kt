package com.example.scan_receiver

import android.content.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class ScanReceiverPlugin: FlutterPlugin, EventChannel.StreamHandler {
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    private var receiver: BroadcastReceiver? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        val eventChannel = EventChannel(binding.binaryMessenger, "scan_receiver/event")
        eventChannel.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == "android.intent.ACTION_DECODE_DATA") {
                    val barcode = intent.getStringExtra("barcode_string")
                    barcode?.let { eventSink?.success(it) }
                }
            }
        }
        val filter = IntentFilter("android.intent.ACTION_DECODE_DATA")
        context.registerReceiver(receiver, filter)
    }

    override fun onCancel(arguments: Any?) {
        context.unregisterReceiver(receiver)
        receiver = null
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}
