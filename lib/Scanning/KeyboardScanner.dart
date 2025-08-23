import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanKeyboardHandler extends StatefulWidget {
  final void Function(String code) onScanResult;

  const ScanKeyboardHandler({
    required this.onScanResult,
    super.key,
  });

  @override
  State<ScanKeyboardHandler> createState() => _ScanKeyboardHandlerState();
}

class _ScanKeyboardHandlerState extends State<ScanKeyboardHandler> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  DateTime? _lastKeyTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestFocus();
  }

  void _requestFocus() {
    print('FocusNode debug: Requesting focus');
    _focusNode.requestFocus();
    _focusNode.addListener(() {
      print('FocusNode debug: Focus changed - hasFocus: ${_focusNode.hasFocus}');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestFocus();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      final now = DateTime.now();
      if (_lastKeyTime == null || now.difference(_lastKeyTime!) > Duration(milliseconds: 100)) {
        _controller.clear();
      }
      _lastKeyTime = now;

      if (key == LogicalKeyboardKey.enter) {
        final scannedCode = _controller.text;
        if (scannedCode.isNotEmpty) {
          widget.onScanResult(scannedCode);
        }
        _controller.clear();
      } else {
        final label = key.keyLabel;
        if (label.length == 1) {
          _controller.text += label;
        }
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: TextField(
          controller: _controller,
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          keyboardType: TextInputType.none,
          decoration: InputDecoration(
            hintText: 'Scannez un code...',
            prefixIcon: const Icon(Icons.qr_code_scanner),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
