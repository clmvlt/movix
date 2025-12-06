import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class _CameraScannerManager {
  static _CameraScannerState? _activeInstance;
  static bool _isInitializing = false;

  static Future<void> setActiveInstance(_CameraScannerState instance) async {
    if (_activeInstance != null && _activeInstance != instance) {
      await _activeInstance!._forceStop();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    _activeInstance = instance;
  }

  static void removeInstance(_CameraScannerState instance) {
    if (_activeInstance == instance) {
      _activeInstance = null;
    }
  }

  static bool get isInitializing => _isInitializing;
  static void setInitializing(bool value) => _isInitializing = value;
}

class CameraScannerIOS extends StatefulWidget {
  final void Function(String) onScanResult;

  const CameraScannerIOS({
    super.key,
    required this.onScanResult,
  });

  @override
  State<CameraScannerIOS> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScannerIOS> with TickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? controller;
  bool isExtended = false;
  bool isFlashOn = false;
  bool isInitialized = false;
  bool _isWidgetVisible = true;
  late AnimationController _animationController;
  final Map<String, DateTime> _recentScannedCodes = {};
  int _retryCount = 0;
  final int _maxRetries = 3;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _setActiveAndInitialize();
  }

  void _setActiveAndInitialize() async {
    await _CameraScannerManager.setActiveInstance(this);
    if (mounted && _isWidgetVisible) {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_CameraScannerManager.isInitializing || isInitialized) {
      return;
    }

    _CameraScannerManager.setInitializing(true);

    try {
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
      );

      await controller!.start();

      if (mounted && _isWidgetVisible) {
        setState(() {
          isInitialized = true;
          _retryCount = 0;
          _isRetrying = false;
        });
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de la caméra: $e');
      if (mounted) {
        setState(() {
          isInitialized = false;
        });
        _handleCameraError();
      }
    } finally {
      _CameraScannerManager.setInitializing(false);
    }
  }

  void _handleCameraError() async {
    if (_retryCount < _maxRetries && !_isRetrying && mounted && _isWidgetVisible && !_CameraScannerManager.isInitializing) {
      _isRetrying = true;
      _retryCount++;

      final delayMs = 1000 * _retryCount;

      if (mounted) {
        setState(() {});
      }

      await Future<void>.delayed(Duration(milliseconds: delayMs));

      if (mounted && _isWidgetVisible) {
        print('Tentative de reconnexion de la caméra ($_retryCount/$_maxRetries)');
        await _initializeCamera();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _pauseCamera();
        break;
      case AppLifecycleState.resumed:
        _resumeCamera();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null) {
      final isCurrentRoute = route.isCurrent;

      if (isCurrentRoute && !_isWidgetVisible) {
        _isWidgetVisible = true;
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (mounted && _isWidgetVisible) {
            await _reinitializeCamera();
          }
        });
      } else if (!isCurrentRoute) {
        if (_isWidgetVisible) {
          _isWidgetVisible = false;
          _stopAndDisposeCamera();
        }
      }
    }
  }

  Future<void> _stopAndDisposeCamera() async {
    if (controller != null) {
      try {
        if (controller!.value.isRunning) {
          await controller!.stop();
        }
        await controller!.dispose();
      } catch (e) {
        print('Erreur lors de l\'arrêt de la caméra: $e');
      } finally {
        controller = null;
        if (mounted) {
          setState(() {
            isInitialized = false;
          });
        }
      }
    }
  }

  Future<void> _reinitializeCamera() async {
    await _stopAndDisposeCamera();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted && _isWidgetVisible && !_CameraScannerManager.isInitializing) {
      await _initializeCamera();
    }
  }

  Future<void> _pauseCamera() async {
    if (controller != null && controller!.value.isRunning) {
      try {
        await controller!.stop();
      } catch (e) {
        print('Erreur lors de la mise en pause de la caméra: $e');
      }
    }
  }

  Future<void> _resumeCamera() async {
    if (controller != null && !controller!.value.isRunning && _isWidgetVisible) {
      try {
        await controller!.start();
      } catch (e) {
        print('Erreur lors de la reprise de la caméra: $e');
        if (mounted && _isWidgetVisible) {
          await _reinitializeCamera();
        }
      }
    } else if (controller == null && _isWidgetVisible) {
      await _initializeCamera();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final code = barcode.rawValue!;

        // Nettoyer les codes expirés (plus de 3 secondes)
        _recentScannedCodes.removeWhere((key, value) =>
          now.difference(value).inSeconds >= 3);

        // Vérifier si ce code a été scanné récemment
        if (_recentScannedCodes.containsKey(code)) {
          continue; // Ignorer ce code
        }

        // Enregistrer le nouveau code et l'envoyer
        _recentScannedCodes[code] = now;
        widget.onScanResult(code);
        break;
      }
    }
  }

  void _toggleFlash() {
    if (controller != null) {
      setState(() {
        isFlashOn = !isFlashOn;
      });
      controller!.toggleTorch();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      isExtended = !isExtended;
    });
    if (isExtended) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _forceStop() async {
    _isWidgetVisible = false;
    await _stopAndDisposeCamera();
  }

  @override
  void dispose() {
    _isWidgetVisible = false;
    _CameraScannerManager.removeInstance(this);
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _stopAndDisposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final height = Tween<double>(
          begin: 120.0,
          end: 320.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        )).value;

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
                if (isInitialized && controller != null)
                  MobileScanner(
                    controller: controller!,
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRetrying
                            ? 'Tentative de reconnexion ($_retryCount/$_maxRetries)...'
                            : 'Initialisation de la caméra...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Gradient overlay
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

                // Controls
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Flash button
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
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Fullscreen button
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
                            isExtended ? Icons.fullscreen_exit : Icons.fullscreen,
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
