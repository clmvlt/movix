import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movix/Services/globals.dart';

import '../Models/Command.dart';

String getTourStatusText(int id) {
  switch (id) { 
    case 1:
      return "Création";
    case 2:
      return "🏠 Chargement";
    case 3:
      return "🚛 Livraison";
    case 4:
      return "Debiref";
    case 5:
      return "Cloturé";
    default:
      return "Introuvable";
  }
}

Widget GetLivraisonIconCommandStatus(Command command, double size) {
  Icon icon;
  Color circleColor = Globals.COLOR_LIGHT_GRAY;

  if (command.status.id == 1 || command.status.id == 2 || command.status.id == 6) {
    icon = Icon(
      Icons.question_mark,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
  } else if (command.status.id == 3) {
    icon = Icon(
      Icons.check,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
  } else if (command.status.id == 5) {
    icon = Icon(
      FontAwesomeIcons.exclamation,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_YELLOW;
  } else {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Globals.COLOR_TEXT_LIGHT,
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
  Color circleColor = Globals.COLOR_LIGHT_GRAY;

  if (command.status.id == 1 || command.status.id == 3) {
    icon = Icon(
      Icons.question_mark,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
  } else if (command.status.id == 2) {
    icon = Icon(
      Icons.check,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
    } else if (command.status.id == 6) {
    icon = Icon(
      FontAwesomeIcons.exclamation,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_YELLOW;
  } else {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Globals.COLOR_TEXT_LIGHT,
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

Widget getColisConfirm(BuildContext context) {
  final TextEditingController commentController = TextEditingController();

  return StatefulBuilder(
    builder: (context, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Globals.COLOR_SURFACE,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.warning_outlined,
                        color: Globals.COLOR_MOVIX_YELLOW,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Confirmation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tous les colis non scannés seront marqués comme absents. Voulez-vous continuer ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Globals.COLOR_BACKGROUND,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: commentController,
                        maxLines: 3,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Raison (obligatoire)',
                          hintStyle: TextStyle(
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: TextStyle(
                          color: Globals.COLOR_TEXT_DARK,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop({'confirmed': false}),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Non',
                              style: TextStyle(
                                color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 56,
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: commentController.text.trim().isEmpty 
                              ? null
                              : () {
                                  Navigator.of(context).pop({
                                    'confirmed': true,
                                    'comment': commentController.text.trim(),
                                  });
                                },
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Oui, continuer',
                              style: TextStyle(
                                color: commentController.text.trim().isEmpty
                                    ? Globals.COLOR_TEXT_DARK.withOpacity(0.4)
                                    : Globals.COLOR_MOVIX_RED,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


