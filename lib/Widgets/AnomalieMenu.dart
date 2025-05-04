import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Services/globals.dart';

import '../Models/Command.dart';

void ShowChargementAnomalieManu(
    BuildContext context, Command command, VoidCallback onUpdate) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: const Text(
            'Choisir une action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.warning, color: Globals.COLOR_MOVIX_RED),
                title: const Text('Déclarer manquant'),
                onTap: () {
                  Navigator.pop(context);
                  for (var package in command.packages.values) {
                    setPackageState(command, package, "5", onUpdate);
                  }
                },
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Annuler'),
            ),
          ],
        ),
      );
    },
  );
}

void ShowLivraisonAnomalieManu(
    BuildContext context, Command command, VoidCallback onUpdate) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: const Text(
            'Livraison impossible',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.warning, color: Globals.COLOR_MOVIX_RED),
                title: const Text('Déclarer manquant'),
                onTap: () {
                  Navigator.pop(context);
                  for (var package in command.packages.values) {
                    setPackageStateOffline(command, package, "4", onUpdate);
                  }
                  context.push('/tour/validateLivraison',
                      extra: {'command': command, 'onUpdate': onUpdate});
                },
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading:
                    const Icon(Icons.warning, color: Globals.COLOR_MOVIX_RED),
                title: const Text('Inaccessible'),
                onTap: () {
                  Navigator.pop(context);
                  for (var package in command.packages.values) {
                    setPackageStateOffline(command, package, "8", onUpdate);
                  }
                  context.push('/tour/validateLivraison',
                      extra: {'command': command, 'onUpdate': onUpdate});
                },
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading:
                    const Icon(Icons.warning, color: Globals.COLOR_MOVIX_RED),
                title: const Text('Instructions invalides'),
                onTap: () {
                  Navigator.pop(context);
                  for (var package in command.packages.values) {
                    setPackageStateOffline(command, package, "9", onUpdate);
                  }
                  context.push('/tour/validateLivraison',
                      extra: {'command': command, 'onUpdate': onUpdate});
                },
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Annuler'),
            ),
          ],
        ),
      );
    },
  );
}
