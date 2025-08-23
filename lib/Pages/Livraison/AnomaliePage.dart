import 'package:flutter/material.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/Scan.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Widgets/PackagesWidget.dart';
import 'package:movix/Widgets/Common/AppBarWidget.dart';
import 'package:movix/Widgets/Sections/PhotoSectionWidget.dart';
import 'package:movix/Widgets/Sections/FormSectionWidget.dart';

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
    return Scaffold(
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
                  iconColor: Globals.COLOR_MOVIX,
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
    );
  }


  Widget _buildFormContent() {
    return Column(
      children: [
        // Dropdown pour le motif
        Container(
          decoration: BoxDecoration(
            color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Motif d'anomalie",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              labelStyle: TextStyle(color: Globals.COLOR_TEXT_DARK.withOpacity(0.7)),
            ),
            value: _selectedReasonCode,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedReasonCode = newValue;
              });
            },
            items: _reasonsMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(color: Globals.COLOR_TEXT_DARK),
                ),
              );
            }).toList(),
          ),
        ),
        
        if (_selectedReasonCode == "other") ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _otherReasonController,
              decoration: InputDecoration(
                labelText: "Autre (précisez)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                labelStyle: TextStyle(color: Globals.COLOR_TEXT_DARK.withOpacity(0.7)),
              ),
              style: TextStyle(color: Globals.COLOR_TEXT_DARK),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _actionsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Actions prises",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              labelStyle: TextStyle(color: Globals.COLOR_TEXT_DARK.withOpacity(0.7)),
            ),
            style: TextStyle(color: Globals.COLOR_TEXT_DARK),
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Globals.COLOR_MOVIX_YELLOW.withOpacity(0.15),
                        Globals.COLOR_MOVIX_YELLOW.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Globals.COLOR_MOVIX_YELLOW,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Colis concernés",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "Scannez les colis affectés",
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: packages.isNotEmpty 
                        ? Globals.COLOR_MOVIX_GREEN.withOpacity(0.1)
                        : Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${packages.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: packages.isNotEmpty 
                          ? Globals.COLOR_MOVIX_GREEN
                          : Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                minHeight: 60,
                maxHeight: packages.length > 3 ? 160 : double.infinity,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: packages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_outlined,
                            size: 28,
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scannez pour ajouter un colis',
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: packages.values.map((package) {
                          final emote = getPackageEmote(package.type);
                          final isFresh = package.fresh == 't' ? '❄️' : '';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Globals.COLOR_MOVIX.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Globals.COLOR_MOVIX.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    emote,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.barcode,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Globals.COLOR_TEXT_DARK,
                                        ),
                                      ),
                                      if (isFresh.isNotEmpty)
                                        Text(
                                          'Produit frais $isFresh',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      packages.remove(package.barcode);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Globals.COLOR_MOVIX_RED,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isPageActive 
          ? ScannerWidget(validateCode: validateCode)
          : Container(
              height: 120,
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Globals.COLOR_MOVIX,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Initialisation du scanner...',
                      style: TextStyle(
                        color: Globals.COLOR_TEXT_DARK,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
