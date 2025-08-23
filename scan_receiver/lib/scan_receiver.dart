
import 'scan_receiver_platform_interface.dart';

class ScanReceiver {
  Future<String?> getPlatformVersion() {
    return ScanReceiverPlatform.instance.getPlatformVersion();
  }
}
