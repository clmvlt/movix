import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'scan_receiver_method_channel.dart';

abstract class ScanReceiverPlatform extends PlatformInterface {
  /// Constructs a ScanReceiverPlatform.
  ScanReceiverPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScanReceiverPlatform _instance = MethodChannelScanReceiver();

  /// The default instance of [ScanReceiverPlatform] to use.
  ///
  /// Defaults to [MethodChannelScanReceiver].
  static ScanReceiverPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScanReceiverPlatform] when
  /// they register themselves.
  static set instance(ScanReceiverPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
