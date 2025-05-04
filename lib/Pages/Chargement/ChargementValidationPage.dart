import 'package:flutter/material.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Widgets/CustomButton.dart';

class ChargementValidationPage extends StatefulWidget {
  final Tour tour;
  final PackageSearcher packageSearcher;

  const ChargementValidationPage(
      {super.key, required this.tour, required this.packageSearcher});

  @override
  _ChargementValidationPageState createState() =>
      _ChargementValidationPageState();
}

class _ChargementValidationPageState extends State<ChargementValidationPage> {
  bool isLoading = true;
  bool allPackagesScanned = false;
  bool isValid = false;
  List<String> errors = [];
  String? validationMessage;

  void onUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeValidation();
    });
  }

  Future<void> _initializeValidation() async {
    setState(() {
      isLoading = true;
      validationMessage = null;
    });

    final scanned = widget.packageSearcher.isAllPackagesScanned();

    if (!scanned) {
      setState(() {
        allPackagesScanned = false;
        isLoading = false;
      });
      return;
    }

    final result = await validateChargement(
      widget.tour,
      onUpdate,
      errors: errors,
    );

    setState(() {
      allPackagesScanned = true;
      isValid = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text('Validation en cours'),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Globals.COLOR_MOVIX),
                    strokeWidth: 4,
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Validation de la tournée en cours...\nMerci de patienter.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : isValid
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Globals.COLOR_MOVIX_GREEN,
                          size: 90,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Tournée validée avec succès",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Globals.COLOR_MOVIX_GREEN,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        customButton(
                          onPressed: () => context.go('/tours'),
                          label: 'Voir les tournées',
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error,
                          color: Globals.COLOR_MOVIX_RED,
                          size: 90,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          allPackagesScanned
                              ? "Impossible de valider la tournée"
                              : "Tous les colis n'ont pas été scannés",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Globals.COLOR_MOVIX_RED,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        ListView.separated(
                          itemCount: errors.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Globals.COLOR_MOVIX_RED,
                                ),
                                title: Text(
                                  errors[index],
                                  style: const TextStyle(
                                    color: Globals.COLOR_MOVIX_RED,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        customButton(
                          label: 'Retour au chargement',
                          onPressed: () {
                            context.go('/tour/chargement', extra: {
                              'packageSearcher': widget.packageSearcher,
                              'tour': widget.tour,
                            });
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
