import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/globals.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScannerWidget extends StatefulWidget {
  final Future<ScanResult> Function(String) validateCode;

  const ScannerWidget({super.key, required this.validateCode});

  @override
  State<ScannerWidget> createState() => ScannerWidgetState();
}

class ScannerWidgetState extends State<ScannerWidget> with RouteAware {
  final Map<String, DateTime> _scannedCodes = {};
  bool _torchOn = false;

  final AudioPlayer _player = AudioPlayer();
  final MobileScannerController _controller = MobileScannerController();
  final FocusNode _focusNode = FocusNode();
  bool _isFullScreen = false;

  bool _scanningEnabled = true;
  String _inputLog = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    startScanner();
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void startScanner() {
    _scanningEnabled = true;
  }

  void stopScanner() {
    _scanningEnabled = false;
  }

  Future<void> _playSound(ScanResult result) async {
    final path = switch (result) {
      ScanResult.SCAN_SUCCESS =>
        'sounds/${Globals.SOUND_PATH}/scan_success1.mp3',
      ScanResult.SCAN_ERROR => 'sounds/${Globals.SOUND_PATH}/scan_error1.mp3',
      ScanResult.SCAN_FINISH => 'sounds/${Globals.SOUND_PATH}/scan_finish.mp3',
      ScanResult.SCAN_SWITCH => 'sounds/${Globals.SOUND_PATH}/scan_switch1.mp3',
      ScanResult.NOTHING => null,
    };

    if (path == null) return;

    try {
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (_) {}
  }

  Future<void> _processCode(String code) async {
    try {
      final result = await widget.validateCode(code.toLowerCase());
      await _playSound(result);
    } catch (_) {}
  }

  Future<void> _handleKeyEvent(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey.keyLabel == 'Enter') {
        await _processCode(_inputLog);
        _inputLog = '';
      } else {
        _inputLog += event.logicalKey.keyLabel;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: 300,
          child: Center(
            child: _buildMobileScanner(),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 30 : 10),
      child: SizedBox(
        height: 100,
        child: Center(
          child: Globals.isScannerMode
              ? _buildKeyboardScanner()
              : _buildMobileScanner(),
        ),
      ),
    );
  }

  Widget _buildKeyboardScanner() {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/barcode.svg',
            height: 80,
            width: 100,
            color: Colors.black,
          ),
          const Text(
            "Mode scanner",
            style: TextStyle(fontSize: 8, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileScanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scanWidth = width * 0.9;
        final scanHeight = height * 0.9;
        final scanLeft = (width - scanWidth) / 2;
        final scanTop = (height - scanHeight) / 2;

        return Stack(
          children: [
            ClipRRect(
              borderRadius:
                  _isFullScreen ? BorderRadius.zero : BorderRadius.circular(16),
              child: MobileScanner(
                controller: _controller,
                fit: BoxFit.cover,
                scanWindow:
                    Rect.fromLTWH(scanLeft, scanTop, scanWidth, scanHeight),
                onDetect: (capture) {
                  if (!_scanningEnabled) return;
                  final now = DateTime.now();

                  for (final barcode in capture.barcodes) {
                    final code = barcode.rawValue;
                    if (code == null) continue;

                    final lastScannedAt = _scannedCodes[code];
                    final canProcess = lastScannedAt == null ||
                        now.difference(lastScannedAt) >
                            const Duration(seconds: 5);

                    if (!canProcess) continue;

                    _scannedCodes[code] = now;
                    _processCode(code);
                  }
                },
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.close : Icons.fullscreen,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                  _torchOn ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  await _controller.toggleTorch();
                  setState(() {
                    _torchOn = !_torchOn;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
