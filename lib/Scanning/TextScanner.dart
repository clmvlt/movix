import 'package:flutter/material.dart';


class TextScanner extends StatefulWidget {
  final void Function(String) onScanResult;

  const TextScanner({
    super.key,
    required this.onScanResult,
  });

  @override
  State<TextScanner> createState() => _TextScannerState();
}

class _TextScannerState extends State<TextScanner> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Scan text here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          widget.onScanResult(value);
          _controller.clear();
        }
      },
    );
  }
}

