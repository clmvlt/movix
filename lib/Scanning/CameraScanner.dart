import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScanner extends StatefulWidget {
  final void Function(String) onScanResult;

  const CameraScanner({
    super.key,
    required this.onScanResult,
  });

  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner> with TickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? controller;
  bool isExtended = false;
  bool isFlashOn = false;
  bool isInitialized = false;
  bool _isWidgetVisible = true;
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
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
      );
      
      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de la caméra: $e');
      if (mounted) {
        setState(() {
          isInitialized = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _isWidgetVisible = false;
        _stopAndDisposeCamera();
        break;
      case AppLifecycleState.resumed:
        if (_isWidgetVisible) {
          _reinitializeCamera();
        }
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
        _reinitializeCamera();
      } else if (!isCurrentRoute && _isWidgetVisible) {
        _isWidgetVisible = false;
        _stopAndDisposeCamera();
      }
    }
  }

  Future<void> _stopAndDisposeCamera() async {
    if (controller != null) {
      if (controller!.value.isRunning) {
        await controller!.stop();
      }
      await controller!.dispose();
      controller = null;
      if (mounted) {
        setState(() {
          isInitialized = false;
        });
      }
    }
  }

  Future<void> _reinitializeCamera() async {
    await _stopAndDisposeCamera();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _initializeCamera();
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    _animationController.dispose();
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
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Initialisation de la caméra...',
                          style: TextStyle(
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