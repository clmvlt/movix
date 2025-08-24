import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class InputDialogWidget extends StatelessWidget {
  final String title;
  final String description;
  final String hintText;
  final void Function(String) onConfirm;
  final String? initialValue;
  final bool autofocus;

  const InputDialogWidget({
    super.key,
    required this.title,
    required this.description,
    required this.hintText,
    required this.onConfirm,
    this.initialValue,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    final FocusNode focusNode = FocusNode();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        focusNode.unfocus();
      },
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
                        color: Globals.COLOR_MOVIX.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_outlined,
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
                    const SizedBox(height: 8),
                    Text(
                      description,
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
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: autofocus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          counterText: "",
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
                            focusNode.unfocus();
                            Navigator.of(context).pop();
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Annuler",
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
                            String code = controller.text.trim();
                            if (code.isNotEmpty) {
                              onConfirm(code);
                              focusNode.unfocus();
                              Navigator.of(context).pop();
                            }
                          },
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Valider",
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
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String hintText,
    required void Function(String) onConfirm,
    String? initialValue,
    bool autofocus = true,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InputDialogWidget(
        title: title,
        description: description,
        hintText: hintText,
        onConfirm: onConfirm,
        initialValue: initialValue,
        autofocus: autofocus,
      ),
    );
  }
}