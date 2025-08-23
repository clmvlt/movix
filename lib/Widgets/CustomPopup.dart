import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

Future<bool?> showConfirmationPopup({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = "Annuler",
  String confirmText = "Valider",
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
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
                        color: Globals.COLOR_MOVIX.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: Globals.COLOR_MOVIX,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
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
                          onTap: () => Navigator.of(context).pop(false),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              cancelText,
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
                          onTap: () => Navigator.of(context).pop(true),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              confirmText,
                              style: TextStyle(
                                color: Globals.COLOR_TEXT_DARK,
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

Future<void> showInfoPopup({
  required BuildContext context,
  required String title,
  required Widget content,
  String buttonText = "Fermer",
  IconData icon = Icons.info_outline,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        icon,
                        color: Globals.COLOR_MOVIX,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      child: content,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: Globals.COLOR_TEXT_DARK,
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
      );
    },
  );
}

Future<void> showErrorPopup({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = "Fermer",
}) {
  return showInfoPopup(
    context: context,
    title: title,
    content: Text(message),
    buttonText: buttonText,
    icon: Icons.error_outline,
  );
}

Future<void> showSuccessPopup({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = "Fermer",
}) {
  return showInfoPopup(
    context: context,
    title: title,
    content: Text(message),
    buttonText: buttonText,
    icon: Icons.check_circle_outline,
  );
}

Future<void> showWarningPopup({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = "Fermer",
}) {
  return showInfoPopup(
    context: context,
    title: title,
    content: Text(message),
    buttonText: buttonText,
    icon: Icons.warning_outlined,
  );
}