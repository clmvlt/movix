import 'package:flutter/foundation.dart';
import 'package:movix/API/api.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Services/globals.dart';

void setPackageState(Command command, Package package, String id, VoidCallback onUpdate) async {
    String savedId = package.idStatus;
    package.idStatus = id;
    onUpdate();

    updateCommandState(command, onUpdate, false);

    API.setPackageState(package.barcode, id).then((res) {
      if (!res) {
        package.idStatus = savedId;
        onUpdate();

        updateCommandState(command, onUpdate, false);
        Globals.showSnackbar("Le colis ${package.barcode} n'a pas été scanné correctement.", backgroundColor: Globals.COLOR_MOVIX_RED);
      }
    });
}

void setPackageStateOffline(
    Command command, Package package, String id, Function update) async {
    package.idStatus = id;
    update();
}
