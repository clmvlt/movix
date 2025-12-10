import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ZebraScanReceiver {
  static const EventChannel _eventChannel = EventChannel('scan_receiver/zebra_event');
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
              debugPrint('Zebra scan receiver error: $error');
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

class ZebraScanner extends StatefulWidget {
  final void Function(String) onScanResult;
  final bool isActive;

  const ZebraScanner({
    super.key,
    required this.onScanResult,
    this.isActive = true,
  });

  @override
  State<ZebraScanner> createState() => _ZebraScannerState();
}

class _ZebraScannerState extends State<ZebraScanner> with WidgetsBindingObserver {
  StreamSubscription<String>? _subscription;
  bool _isActive = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(ZebraScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _isActive = widget.isActive;
      if (_isActive) {
        _startListening();
      } else {
        _stopListening();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_handleFocusChange);
    _isActive = widget.isActive;
    if (_isActive) {
      _startListening();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    GoRouterState.of(context);
    _isActive = true;
    _startListening();
  }

  void _handleFocusChange() {
    // Le scanner reste actif même sans focus pour permettre le scan pendant la saisie de texte
    if (_isActive) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() {
    if (!_isActive || !widget.isActive) return;

    _subscription?.cancel();
    _subscription = ZebraScanReceiver.onScanned.listen(
      (result) {
        if (_isActive && widget.isActive && mounted) {
          widget.onScanResult(result);
        }
      },
      onError: (Object error) {
        debugPrint('Zebra scanner error: $error');
      },
    );
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListening();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isActive = false;
      _stopListening();
    } else if (state == AppLifecycleState.resumed) {
      _isActive = true;
      if (mounted) {
        _startListening();
      }
    }
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
