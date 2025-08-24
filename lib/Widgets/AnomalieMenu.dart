import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Services/globals.dart';

import '../Models/Command.dart';

Widget _buildAnomalieOption({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Globals.COLOR_UNSELECTED.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: Globals.COLOR_MOVIX_RED,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Globals.COLOR_TEXT_DARK,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );
}

void ShowChargementAnomalieManu(
    BuildContext context, Command command, VoidCallback onUpdate) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Dialog(
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
                          color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.warning_outlined,
                          color: Globals.COLOR_MOVIX_RED,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choisir une action',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildAnomalieOption(
                        icon: Icons.error_outline,
                        title: 'Déclarer manquant',
                        subtitle: 'Marquer tous les colis comme manquants',
                        onTap: () {
                          Navigator.pop(context);
                          for (var package in command.packages.values) {
                            setPackageState(command, package, 5, onUpdate);
                          }
                        },
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
                      onTap: () => Navigator.pop(context),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Annuler',
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
              ],
            ),
          ),
        ),
      );
    },
  );
}

void ShowLivraisonAnomalieManu(
    BuildContext context, Command command, VoidCallback onUpdate) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Dialog(
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
                          color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.delivery_dining_outlined,
                          color: Globals.COLOR_MOVIX_RED,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Livraison impossible',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sélectionnez la raison de l\'impossibilité de livrer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          _buildAnomalieOption(
                            icon: Icons.error_outline,
                            title: 'Déclarer manquant',
                            subtitle: 'Colis introuvable ou perdu',
                            onTap: () {
                              Navigator.pop(context);
                              _showCommentDialog(context, command, 4, 'Déclarer manquant', onUpdate);
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildAnomalieOption(
                            icon: Icons.location_off_outlined,
                            title: 'Inaccessible',
                            subtitle: 'Adresse inaccessible ou fermée',
                            onTap: () {
                              Navigator.pop(context);
                              _showCommentDialog(context, command, 8, 'Inaccessible', onUpdate);
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildAnomalieOption(
                            icon: Icons.description_outlined,
                            title: 'Instructions invalides',
                            subtitle: 'Instructions de livraison incorrectes',
                            onTap: () {
                              Navigator.pop(context);
                              _showCommentDialog(context, command, 9, 'Instructions invalides', onUpdate);
                            },
                          ),
                        ],
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
                      onTap: () => Navigator.pop(context),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Annuler',
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
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showCommentDialog(BuildContext context, Command command, int statusId, String title, VoidCallback onUpdate) {
  final TextEditingController commentController = TextEditingController();
  
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Dialog(
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
                          color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.comment_outlined,
                          color: Globals.COLOR_MOVIX_RED,
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
                      const SizedBox(height: 8),
                      Text(
                        'Veuillez préciser la raison de cette décision',
                        style: TextStyle(
                          fontSize: 14,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Globals.COLOR_BACKGROUND,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: commentController,
                          maxLines: 3,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Décrivez la raison...',
                            hintStyle: TextStyle(
                              color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Globals.COLOR_TEXT_DARK,
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
                            onTap: () {
                              Navigator.pop(context);
                              ShowLivraisonAnomalieManu(context, command, onUpdate);
                            },
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Retour',
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
                            onTap: () {
                              String comment = commentController.text.trim();
                              if (comment.isEmpty) {
                                Globals.showSnackbar(
                                  'Veuillez renseigner une raison',
                                  backgroundColor: Globals.COLOR_MOVIX_RED,
                                );
                                return;
                              }
                              
                              Navigator.pop(context);
                              
                              // Store the comment for later use in API call
                              command.deliveryComment = comment;
                              
                              for (var package in command.packages.values) {
                                setPackageStateOffline(command, package, statusId, onUpdate);
                              }
                              
                              context.push('/tour/validateLivraison',
                                  extra: {'command': command, 'onUpdate': onUpdate});
                            },
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Valider',
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
        ),
      );
    },
  );
}