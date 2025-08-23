import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
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
  bool canForceValidation = false;
  bool isValid = false;
  String errors = "";

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
    });

    Map<int, int> packagesStatusCount = PackageSearcher.countPackageStatus(widget.tour);

    if (packagesStatusCount[1] != 0) {
      setState(() {
        errors = "Certains colis n'ont pas été rensignés.";
        isLoading = false;
        isValid = false;
        canForceValidation = false;
      });
      return;
    }

    if (packagesStatusCount[5] != 0) {
      setState(() {
        final count = packagesStatusCount[5] ?? -1;
        errors =
            "$count colis ${count > 1 ? 'ont' : 'a'} été renseigné${count > 1 ? 's' : ''} comme MANQUANT, êtes-vous sûr de vouloir valider la tournée ?";

        isLoading = false;
        isValid = false;
        canForceValidation = true;
      });
      return;
    }

    validate();
  }

  Future<void> validate() async {
    setState(() {
      isLoading = true;
    });

    final result = await validateChargement(
      widget.tour,
      onUpdate,
    );

    if (result['success'] == true) {
      setState(() {
        errors = "";
        isValid = true;
        isLoading = false;
        canForceValidation = false;
      });
    } else {
      setState(() {
        errors = result['errors'] as String;
        isValid = false;
        isLoading = false;
        canForceValidation = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Globals.COLOR_BACKGROUND,
    appBar: AppBar(
      toolbarTextStyle: Globals.appBarTextStyle,
      titleTextStyle: Globals.appBarTextStyle,
      title: const Text('Validation en cours'),
      backgroundColor: Globals.COLOR_MOVIX,
      foregroundColor: Globals.COLOR_TEXT_LIGHT,
      elevation: 3,
      centerTitle: true,
    ),
    body: Center(
      child: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Globals.COLOR_MOVIX),
                  strokeWidth: 4,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Validation de la tournée en cours...\nMerci de patienter.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Globals.COLOR_TEXT_DARK,
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
                        Icons.check_circle_outline,
                        color: Globals.COLOR_MOVIX_GREEN,
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Tournée validée avec succès",
                        style: TextStyle(
                          fontSize: 24,
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
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Globals.COLOR_MOVIX_RED,
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Impossible de valider la tournée",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Globals.COLOR_MOVIX_RED,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      Card(
                        color: Globals.COLOR_SURFACE,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: Globals.COLOR_MOVIX_RED,
                          ),
                          title: Text(
                            errors,
                            style: const TextStyle(
                              color: Globals.COLOR_MOVIX_RED,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (canForceValidation)
                        customButton(
                          label: 'Forcer la validation',
                          onPressed: () => validate(),
                          color: Globals.COLOR_MOVIX_RED
                        ),
                      const SizedBox(height: 20),
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
