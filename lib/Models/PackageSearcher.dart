import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';

class PackageSearcher {
  final Map<String, Command> commands;
  late Map<String, String> barcodeCommandIndex; 

  PackageSearcher(this.commands) {
    _buildbarcodeCommandIndex();
  }

  void _buildbarcodeCommandIndex() {
    barcodeCommandIndex = {};
    for (var command in commands.values) {
      for (var entry in command.packages.entries) {
        barcodeCommandIndex[entry.key] = command.id;
      }
    }
  }

  bool isAllPackagesScanned() {
    for (var status in barcodeCommandIndex.values) {
      if (status == '1') {
        return false; 
      }
    }
    return true;
  }

  Package? getPackageByBarcode(Command selectedCommand, String code) {
    if (selectedCommand.packages.containsKey(code)) {
      return selectedCommand.packages[code];
    }

    if (barcodeCommandIndex.containsKey(code)) {
      final commandId = barcodeCommandIndex[code]!;
      return commands[commandId]?.packages[code];
    }

    return null;
  }
}
