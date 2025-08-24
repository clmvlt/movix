import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class MissingPackagesDialogWidget extends StatefulWidget {
  final int missingCount;
  final String dialogType;

  const MissingPackagesDialogWidget({
    super.key,
    required this.missingCount,
    this.dialogType = 'validation',
  });

  @override
  State<MissingPackagesDialogWidget> createState() => _MissingPackagesDialogWidgetState();
}

class _MissingPackagesDialogWidgetState extends State<MissingPackagesDialogWidget> {
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                        color: _getIconColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.warning_outlined,
                        color: _getIconColor(),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDescription(),
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
                          hintText: 'Décrivez la raison des colis manquants...',
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
                            Navigator.pop(context, null);
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
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
                            
                            Navigator.pop(context, comment);
                          },
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                color: _getContinueButtonColor(),
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
  }

  Color _getIconColor() {
    return widget.dialogType == 'validation'
        ? Globals.COLOR_MOVIX_RED
        : Globals.COLOR_MOVIX_YELLOW;
  }

  String _getTitle() {
    return widget.dialogType == 'validation'
        ? 'Colis manquants'
        : 'Colis non chargés';
  }

  String _getDescription() {
    if (widget.dialogType == 'validation') {
      return '${widget.missingCount} colis ${widget.missingCount > 1 ? 'ont été renseignés' : 'a été renseigné'} comme MANQUANT. Veuillez préciser la raison.';
    } else {
      return 'Tous les colis non scannés seront marqués comme manquants. Veuillez préciser la raison.';
    }
  }

  Color _getContinueButtonColor() {
    return widget.dialogType == 'validation'
        ? Globals.COLOR_TEXT_DARK
        : Globals.COLOR_MOVIX_RED;
  }


  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}