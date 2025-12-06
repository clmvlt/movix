import 'package:flutter/material.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Widgets/Common/AppBarWidget.dart';
import 'package:movix/Widgets/Sections/PhotoSectionWidget.dart';
import 'package:movix/Widgets/Sections/FormSectionWidget.dart';
import 'package:movix/Widgets/Livraison/FormFieldWidget.dart';
import 'package:movix/Widgets/Livraison/PackageListWidget.dart';
import 'package:movix/Widgets/Livraison/ScannerSectionWidget.dart';

class AnomaliePage extends StatefulWidget {
  final Command command;
  final VoidCallback onUpdate;

  const AnomaliePage(
      {super.key, required this.command, required this.onUpdate});

  @override
  _AnomaliePage createState() => _AnomaliePage();
}

class _AnomaliePage extends State<AnomaliePage> with WidgetsBindingObserver {
  List<String> _photosBase64 = [];
  String? _selectedReasonCode;
  final TextEditingController _otherReasonController = TextEditingController();
  final TextEditingController _actionsController = TextEditingController();
  final Map<String, Package> packages = {};
  bool _isPageActive = true; // Commence à true par défaut

  final Map<String, String> _reasonsMap = {
    'excu_temp': 'Excurtion de température',
    'c_dev': 'Colis dévoyé',
    'c_end': 'Colis endommagé',
    'other': 'Autre',
  };

  void _onImagesChanged(List<String> images) {
    setState(() {
      _photosBase64 = images;
    });
  }

  void handleFormSend() {
    if (_photosBase64.isEmpty) {
      Globals.showSnackbar("Veuillez ajouter au moins une photo.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (_selectedReasonCode == null) {
      Globals.showSnackbar("La raison est obligatoire.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (_selectedReasonCode == 'Autre' && _otherReasonController.text == '') {
      Globals.showSnackbar("Veuillez préciser la raison.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (_actionsController.text == '') {
      Globals.showSnackbar("Veuillez préciser l'action prise.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (packages.isEmpty) {
      Globals.showSnackbar("Veuillez ajouter au moins un colis.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }

    for (final package in packages.values) {
      setPackageStateOffline(widget.command, package, 6, onUpdate);
    }

    ValidLivraisonAnomalie(_photosBase64, _selectedReasonCode,
        _otherReasonController.text, _actionsController.text, packages, widget.command);

    Globals.showSnackbar("L'anomalie à bien été envoyée.",
        backgroundColor: Globals.COLOR_MOVIX_GREEN);
    Navigator.of(context).pop();
  }

  void onUpdate() {
    widget.onUpdate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _otherReasonController.dispose();
    _actionsController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final scanMode = await getScanMode();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (scanMode == ScanMode.Camera) {
        setState(() {
          _isPageActive = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (scanMode == ScanMode.Camera) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isPageActive = true;
            });
          }
        });
      }
      // Pour les autres modes, ne rien faire - _isPageActive reste à sa valeur actuelle
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: CustomAppBarWidget(
        title: widget.command.pharmacy.name,
        subtitle: 'Signaler une anomalie',
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoSectionWidget(
                  title: "Photos de l'anomalie",
                  subtitle: "Ajoutez au moins une photo",
                  photosBase64: _photosBase64,
                  onImagesChanged: _onImagesChanged,
                  isRequired: true,
                  emptyMessage: "Aucune photo prise",
                ),
                const SizedBox(height: 8),
                FormSectionWidget(
                  title: "Détails de l'anomalie",
                  icon: Icons.assignment_outlined,
                  iconColor: Globals.COLOR_ADAPTIVE_ACCENT,
                  content: _buildFormContent(),
                ),
                const SizedBox(height: 8),
                _buildPackagesSection(),
                const SizedBox(height: 8),
                _buildScannerSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: handleFormSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.COLOR_MOVIX,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Valider l\'anomalie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }


  Widget _buildFormContent() {
    return Column(
      children: [
        ModernDropdownWidget<String>(
          value: _selectedReasonCode,
          labelText: "Motif d'anomalie",
          items: _reasonsMap,
          onChanged: (String? newValue) {
            setState(() {
              _selectedReasonCode = newValue;
            });
          },
        ),
        
        if (_selectedReasonCode == "other") ...[
          const SizedBox(height: 12),
          ModernTextFieldWidget(
            controller: _otherReasonController,
            labelText: "Autre (précisez)",
          ),
        ],
        
        const SizedBox(height: 16),
        ModernTextFieldWidget(
          controller: _actionsController,
          labelText: "Actions prises",
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPackagesSection() {
    return PackageListWidget(
      packages: packages,
      onPackageRemove: (package) {
        setState(() {
          packages.remove(package.barcode);
        });
      },
      iconColor: Globals.COLOR_MOVIX_YELLOW,
    );
  }

  Widget _buildScannerSection() {
    return ScannerSectionWidget(
      isPageActive: _isPageActive,
      validateCode: validateCode,
    );
  }

  Future<ScanResult> validateCode(String code) async {
    Package? package = widget.command.packages[code];
    if (package == null) {
      Globals.showSnackbar("Colis introuvable",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return ScanResult.SCAN_ERROR;
    } else {
      packages[package.barcode] = package;
      onUpdate();
      Globals.showSnackbar("Colis ajouté dans l'anomalie",
          backgroundColor: Globals.COLOR_MOVIX_GREEN);
      return ScanResult.SCAN_SUCCESS;
    }
  }
}
