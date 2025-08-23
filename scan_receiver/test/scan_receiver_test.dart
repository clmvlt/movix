import 'package:flutter_test/flutter_test.dart';
import 'package:scan_receiver/scan_receiver.dart';
import 'package:scan_receiver/scan_receiver_platform_interface.dart';
import 'package:scan_receiver/scan_receiver_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScanReceiverPlatform
    with MockPlatformInterfaceMixin
    implements ScanReceiverPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScanReceiverPlatform initialPlatform = ScanReceiverPlatform.instance;

  test('$MethodChannelScanReceiver is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScanReceiver>());
  });

  test('getPlatformVersion', () async {
    ScanReceiver scanReceiverPlugin = ScanReceiver();
    MockScanReceiverPlatform fakePlatform = MockScanReceiverPlatform();
    ScanReceiverPlatform.instance = fakePlatform;

    expect(await scanReceiverPlugin.getPlatformVersion(), '42');
  });
}
