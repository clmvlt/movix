import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ScanReceiver {
  static const EventChannel _eventChannel = EventChannel('scan_receiver/event');
  static StreamSubscription<dynamic>? _subscription;
  static StreamController<String>? _controller;

  static Stream<String> get onScanned {
    if (_controller == null) {
      _controller = StreamController<String>.broadcast();
      _subscription = _eventChannel
          .receiveBroadcastStream()
          .map((event) => event.toString())
          .listen(
            (data) => _controller?.add(data),
            onError: (Object error) {
              debugPrint('Scan receiver error: $error');
              _controller?.addError(error);
            },
            onDone: () {
              _controller?.close();
              _controller = null;
              _subscription = null;
            },
          );
    }
    return _controller!.stream;
  }

  static void dispose() {
    _subscription?.cancel();
    _controller?.close();
    _subscription = null;
    _controller = null;
  }
}

class IntentScanner extends StatefulWidget {
  final void Function(String) onScanResult;

  const IntentScanner({
    super.key,
    required this.onScanResult,
  });

  @override
  State<IntentScanner> createState() => _IntentScannerState();
}

class _IntentScannerState extends State<IntentScanner> {
  StreamSubscription<String>? _subscription;
  bool _isActive = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    _startListening();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    GoRouterState.of(context);
    _isActive = true;
    if (_focusNode.hasFocus) {
      _startListening();
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _isActive) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() {
    _subscription?.cancel();
    _subscription = ScanReceiver.onScanned.listen(
      (result) {
        if (_isActive && _focusNode.hasFocus) {
          widget.onScanResult(result);
        }
      },
      onError: (Object error) {
        debugPrint('Scanner error: $error');
      },
    );
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: const SizedBox.shrink(),
    );
  }
}

