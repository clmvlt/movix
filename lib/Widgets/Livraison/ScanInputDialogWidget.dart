import 'package:flutter/material.dart';
import 'package:movix/Widgets/Livraison/InputDialogWidget.dart';

class ScanInputDialogWidget {
  static void show({
    required BuildContext context,
    required bool cipScanned,
    required void Function(String) onConfirm,
    String? initialValue,
  }) {
    InputDialogWidget.show(
      context: context,
      title: "Saisir un code",
      description: cipScanned 
          ? "Entrez le code d'un colis" 
          : "Entrez le code CIP de la pharmacie",
      hintText: cipScanned ? "Code colis" : "Code CIP",
      onConfirm: onConfirm,
      initialValue: initialValue ?? "",
    );
  }
}