import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';

class ValidationButtonWidget extends StatelessWidget {
  final Tour tour;
  final PackageSearcher packageSearcher;
  final bool isVisible;

  const ValidationButtonWidget({
    super.key,
    required this.tour,
    required this.packageSearcher,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: () {
          context.go('/tour/validateChargement', extra: {
            'packageSearcher': packageSearcher,
            'tour': tour
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Globals.COLOR_MOVIX,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Valider chargement',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}