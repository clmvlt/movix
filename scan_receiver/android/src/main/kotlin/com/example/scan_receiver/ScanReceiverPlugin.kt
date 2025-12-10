package com.example.scan_receiver

import android.content.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class ScanReceiverPlugin: FlutterPlugin {
    private lateinit var context: Context

    // DT50 Scanner
    private var dt50EventSink: EventChannel.EventSink? = null
    private var dt50Receiver: BroadcastReceiver? = null

    // Zebra DataWedge Scanner
    private var zebraEventSink: EventChannel.EventSink? = null
    private var zebraReceiver: BroadcastReceiver? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        // DT50 EventChannel (existing)
        val dt50EventChannel = EventChannel(binding.binaryMessenger, "scan_receiver/event")
        dt50EventChannel.setStreamHandler(DT50StreamHandler())

        // Zebra DataWedge EventChannel (new)
        val zebraEventChannel = EventChannel(binding.binaryMessenger, "scan_receiver/zebra_event")
        zebraEventChannel.setStreamHandler(ZebraStreamHandler())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Cleanup DT50
        dt50Receiver?.let {
            try { context.unregisterReceiver(it) } catch (e: Exception) {}
        }
        dt50Receiver = null
        dt50EventSink = null

        // Cleanup Zebra
        zebraReceiver?.let {
            try { context.unregisterReceiver(it) } catch (e: Exception) {}
        }
        zebraReceiver = null
        zebraEventSink = null
    }

    // DT50 Stream Handler (existing behavior)
    inner class DT50StreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            dt50EventSink = events
            dt50Receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == "android.intent.ACTION_DECODE_DATA") {
                        val barcode = intent.getStringExtra("barcode_string")
                        barcode?.let { dt50EventSink?.success(it) }
                    }
                }
            }
            val filter = IntentFilter("android.intent.ACTION_DECODE_DATA")
            context.registerReceiver(dt50Receiver, filter, Context.RECEIVER_EXPORTED)
        }

        override fun onCancel(arguments: Any?) {
            dt50Receiver?.let {
                try { context.unregisterReceiver(it) } catch (e: Exception) {}
            }
            dt50Receiver = null
            dt50EventSink = null
        }
    }

    // Zebra DataWedge Stream Handler (new)
    inner class ZebraStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            zebraEventSink = events
            zebraReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == "com.movix.SCAN") {
                        // Zebra DataWedge standard key
                        val barcode = intent.getStringExtra("com.symbol.datawedge.data_string")
                        barcode?.let { zebraEventSink?.success(it) }
                    }
                }
            }
            val filter = IntentFilter("com.movix.SCAN")
            context.registerReceiver(zebraReceiver, filter, Context.RECEIVER_EXPORTED)
        }

        override fun onCancel(arguments: Any?) {
            zebraReceiver?.let {
                try { context.unregisterReceiver(it) } catch (e: Exception) {}
            }
            zebraReceiver = null
            zebraEventSink = null
        }
    }
}
