import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movix/Services/globals.dart';
import '../Models/Command.dart';
import '../Models/Package.dart';

String getTourStatusText(String id) {
  switch (id) {
    case "1":
      return "Création";
    case "2":
      return "🏠 Chargement";
    case "3":
      return "🚛 Livraison";
    case "4":
      return "Debiref";
    case "5":
      return "Cloturé";
    default:
      return "Introuvable";
  }
}

String getColisEmote(String type) {
  switch (type) {
    case "BAC":
      return "💊";
    case "COLIS":
      return "📦";
    default:
      return type;
  }
}

Widget getIconPackageStatus(Package package, double size) {
  Icon icon;
  Color circleColor = Colors.black38;

  if (package.idStatus == '2') {
    icon = Icon(
      Icons.check,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
  } else if (package.idStatus == '5') {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_RED;
  } else {
    icon = Icon(
      Icons.question_mark,
      color: Colors.white,
      size: size * 0.6,
    );
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: circleColor,
    ),
    child: Center(child: icon),
  );
}

Widget GetLivraisonIconPackageStatus(Package package, double size) {
  Icon icon;
  Color circleColor = Colors.black38;

  if (package.idStatus == '1' || package.idStatus == '2') {
    icon = Icon(
      Icons.question_mark,
      color: Colors.white,
      size: size * 0.6,
    );
  } else if (package.idStatus == '3') {
    icon = Icon(
      Icons.check,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
  } else if (package.idStatus == '6') {
    icon = Icon(
      Icons.warning_amber_outlined,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_YELLOW;
  } else {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_RED;
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: circleColor,
    ),
    child: Center(child: icon),
  );
}

Widget GetLivraisonIconCommandStatus(Command command, double size) {
  Icon icon;
  Color circleColor = Colors.black38;

  if (command.idStatus == '1' || command.idStatus == '2' || command.idStatus == '6') {
    icon = Icon(
      Icons.question_mark,
      color: Colors.white,
      size: size * 0.6,
    );
  } else if (command.idStatus == '3') {
    icon = Icon(
      Icons.check,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
  } else if (command.idStatus == '5') {
    icon = Icon(
      FontAwesomeIcons.exclamation,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Colors.orangeAccent;
  } else {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_RED;
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: circleColor,
    ),
    child: Center(child: icon),
  );
}

Widget GetChargementIconCommandStatus(Command command, double size) {
  Icon icon;
  Color circleColor = Colors.black38;

  if (command.idStatus == '1' || command.idStatus == '3') {
    icon = Icon(
      Icons.question_mark,
      color: Colors.white,
      size: size * 0.6,
    );
  } else if (command.idStatus == '2') {
    icon = Icon(
      Icons.check,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
  } else if (command.idStatus == '6') {
    icon = Icon(
      FontAwesomeIcons.exclamation,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Colors.orangeAccent;
  } else {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Colors.white,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_RED;
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: circleColor,
    ),
    child: Center(child: icon),
  );
}

AlertDialog getColisConfirm(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    backgroundColor: Colors.white,
    title: const Text(
      'Confirmation',
      style: TextStyle(color: Colors.black),
    ),
    content: const Text(
      'Tous les colis non scannés seront marqués comme absents. Voulez-vous continuer ?',
      style: TextStyle(color: Colors.black87),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Non'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Globals.COLOR_MOVIX_RED,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Oui'),
      ),
    ],
  );
}

Widget newBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Globals.COLOR_MOVIX_RED,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'NEW',
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
