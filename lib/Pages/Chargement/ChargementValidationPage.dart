import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Chargement/index.dart';

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
      // Show dialog to get comment for missing packages
      final comment = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return MissingPackagesDialogWidget(
            missingCount: packagesStatusCount[5] ?? 0,
            dialogType: 'validation',
          );
        },
      );
      
      if (comment == null) {
        // User cancelled, show error
        setState(() {
          errors = "Validation annulée. Veuillez justifier les colis manquants pour continuer.";
          isLoading = false;
          isValid = false;
          canForceValidation = false;
        });
        return;
      }
      
      // Add comment to all commands that have missing packages
      _addCommentToCommandsWithMissingPackages(comment);
      
      // Continue with validation
      validate();
      return;
    }

    validate();
  }


  void _addCommentToCommandsWithMissingPackages(String comment) {
    for (final command in widget.tour.commands.values) {
      // Check if this command has any missing packages (status 5)
      bool hasMissingPackages = false;
      for (final package in command.packages.values) {
        if (package.status.id == 5) {
          hasMissingPackages = true;
          break;
        }
      }
      
      // Add comment to command if it has missing packages
      if (hasMissingPackages) {
        command.deliveryComment = comment;
      }
    }
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
      title: Text(
        'Validation de la tournée',
        style: TextStyle(
          color: Globals.COLOR_TEXT_LIGHT,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Globals.COLOR_MOVIX,
      foregroundColor: Globals.COLOR_TEXT_LIGHT,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
        onPressed: () {
          context.pop();
        },
      ),
    ),
    body: SafeArea(
      child: isLoading
          ? ValidationViewsWidget.loading()
          : isValid
              ? ValidationViewsWidget.success()
              : ValidationViewsWidget.error(errors, widget.tour, widget.packageSearcher),
    ),
  );
}


}
