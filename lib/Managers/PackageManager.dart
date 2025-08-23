import 'package:flutter/foundation.dart';
import 'package:movix/API/api.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Services/globals.dart';

void setPackageState(Command command, Package package, int id, VoidCallback onUpdate) async {
    int savedId = package.status.id;
    package.status.id = id;
    onUpdate();

    updateCommandState(command, onUpdate, false);

    API.setPackageState(package.barcode, id).then((res) {
      if (!res) {
        package.status.id = savedId;
        onUpdate();

        updateCommandState(command, onUpdate, false);
        Globals.showSnackbar("Le colis ${package.barcode} n'a pas été scanné correctement.", backgroundColor: Globals.COLOR_MOVIX_RED);
      }
    });
}

void setPackageStateOffline(
    Command command, Package package, int id, Function update) async {
    package.status.id = id;
    update();
}
