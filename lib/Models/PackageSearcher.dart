import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Tour.dart';

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

  static Map<int, int> countPackageStatus(Tour tour) {
    final Map<int, int> mapStatus = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final command in tour.commands.values) {
      for (final package in command.packages.values) {
        mapStatus.update(package.status.id, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }

    return mapStatus;
  }

  static Map<int, int> countPackageStatusInCommand(
      Command command) {
    final Map<int, int> mapStatus = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final package in command.packages.values) {
        mapStatus.update(package.status.id, (value) => value + 1,
          ifAbsent: () => 1);
    }

    return mapStatus;
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
