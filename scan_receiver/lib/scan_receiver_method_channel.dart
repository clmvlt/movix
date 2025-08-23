import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'scan_receiver_platform_interface.dart';

/// An implementation of [ScanReceiverPlatform] that uses method channels.
class MethodChannelScanReceiver extends ScanReceiverPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('scan_receiver');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
