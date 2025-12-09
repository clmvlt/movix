import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScannerIOS extends StatefulWidget {
  final void Function(String) onScanResult;

  const CameraScannerIOS({
    super.key,
    required this.onScanResult,
  });

  @override
  State<CameraScannerIOS> createState() => _CameraScannerIOSState();
}

class _CameraScannerIOSState extends State<CameraScannerIOS>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isExtended = false;
  bool _isFlashOn = false;
  bool _isInitialized = false;
  late AnimationController _animationController;
  final Map<String, DateTime> _recentScannedCodes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _loadCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _unloadCamera();
        break;
      case AppLifecycleState.resumed:
        _loadCamera();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _loadCamera() async {
    if (_controller != null) return;

    // Délai avant chargement pour éviter les conflits
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
        autoStart: true,
      );

      _controller!.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Erreur chargement caméra: $e');
    }
  }

  Future<void> _unloadCamera() async {
    if (_controller == null) return;

    final controllerToDispose = _controller;
    _controller = null;

    if (mounted) {
      setState(() {
        _isInitialized = false;
      });
    }

    try {
      controllerToDispose!.removeListener(_onControllerUpdate);
      await controllerToDispose.stop();
      await controllerToDispose.dispose();
    } catch (e) {
      debugPrint('Erreur déchargement caméra: $e');
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _controller == null) return;

    final isRunning = _controller!.value.isRunning;
    if (isRunning != _isInitialized) {
      setState(() {
        _isInitialized = isRunning;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final now = DateTime.now();

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        final code = barcode.rawValue!;

        _recentScannedCodes.removeWhere(
            (key, value) => now.difference(value).inSeconds >= 3);

        if (_recentScannedCodes.containsKey(code)) continue;

        _recentScannedCodes[code] = now;
        widget.onScanResult(code);
        break;
      }
    }
  }

  void _toggleFlash() {
    if (_controller != null) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _controller!.toggleTorch();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isExtended = !_isExtended;
    });
    if (_isExtended) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final height = Tween<double>(begin: 120.0, end: 320.0)
            .animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ))
            .value;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (_controller != null)
                  MobileScanner(
                    controller: _controller!,
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                  ),
                if (!_isInitialized)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleFullscreen,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isExtended ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
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
}
