import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class InputDialogWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hintText;
  final String? initialValue;
  final IconData? icon;
  final Function(String)? onConfirm;

  const InputDialogWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hintText,
    this.initialValue,
    this.icon = Icons.qr_code_scanner_outlined,
    this.onConfirm,
  });

  @override
  _InputDialogWidgetState createState() => _InputDialogWidgetState();
}

class _InputDialogWidgetState extends State<InputDialogWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _focusNode.unfocus();
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
                        widget.icon,
                        color: Globals.COLOR_MOVIX,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
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
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
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
                            _focusNode.unfocus();
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
                            String code = _controller.text.trim();
                            if (code.isNotEmpty) {
                              widget.onConfirm?.call(code);
                              _focusNode.unfocus();
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
}

void showInputDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String hintText,
  String? initialValue,
  IconData? icon,
  Function(String)? onConfirm,
}) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => InputDialogWidget(
      title: title,
      subtitle: subtitle,
      hintText: hintText,
      initialValue: initialValue,
      icon: icon,
      onConfirm: onConfirm,
    ),
  );
}