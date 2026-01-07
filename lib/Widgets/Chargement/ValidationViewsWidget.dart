import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';

class ValidationViewsWidget {
  const ValidationViewsWidget._();

  static Widget loading() {
    return const _LoadingView();
  }

  static Widget success() {
    return const _SuccessView();
  }

  static Widget error(String errors, Tour tour, PackageSearcher packageSearcher) {
    return _ErrorView(
      errors: errors,
      tour: tour,
      packageSearcher: packageSearcher,
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Globals.COLOR_MOVIX),
                    strokeWidth: 6,
                  ),
                ),
                Icon(
                  Icons.verified_outlined,
                  color: Globals.COLOR_MOVIX,
                  size: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Validation en cours',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Globals.COLOR_TEXT_DARK,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Vérification de la tournée et synchronisation avec le serveur...',
            style: TextStyle(
              fontSize: 16,
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Globals.COLOR_MOVIX.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Globals.COLOR_MOVIX,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Merci de patienter',
                  style: TextStyle(
                    fontSize: 14,
                    color: Globals.COLOR_TEXT_DARK,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX_GREEN.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Globals.COLOR_MOVIX_GREEN,
              size: 80,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Tournée validée',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Globals.COLOR_MOVIX_GREEN,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'La validation a été effectuée avec succès. Tous les colis ont été synchronisés.',
            style: TextStyle(
              fontSize: 16,
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => context.go('/tours'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Globals.COLOR_MOVIX,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Voir les tournées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String errors;
  final Tour tour;
  final PackageSearcher packageSearcher;

  const _ErrorView({
    required this.errors,
    required this.tour,
    required this.packageSearcher,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_rounded,
              color: Globals.COLOR_MOVIX_RED,
              size: 80,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Validation impossible',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Globals.COLOR_MOVIX_RED,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'La tournée ne peut pas être validée en l\'état actuel.',
            style: TextStyle(
              fontSize: 16,
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Globals.COLOR_MOVIX_RED.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Globals.COLOR_MOVIX_RED,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Problème détecté',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Globals.COLOR_TEXT_DARK,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            errors,
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/tour/chargement', extra: {
                  'packageSearcher': packageSearcher,
                  'tour': tour,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Retour au chargement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}