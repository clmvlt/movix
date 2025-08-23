import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Pages/Chargement/ChargementPage.dart';
import 'package:movix/Pages/Chargement/ChargementValidationPage.dart';
import 'package:movix/Pages/Chargement/FSChargementPage.dart';
import 'package:movix/Pages/Livraison/AddPharmacyInfosPage.dart';
import 'package:movix/Pages/Livraison/AnomaliePage.dart';
import 'package:movix/Pages/Livraison/FSLivraisonPage.dart';
import 'package:movix/Pages/Livraison/LivraisonPage.dart';
import 'package:movix/Pages/Livraison/LivraisonValidationPage.dart';
import 'package:movix/Pages/Livraison/MapBoxPage.dart';
import 'package:movix/Pages/Livraison/PharmacyInfosPage.dart';
import 'package:movix/Pages/Others/HomePage.dart';
import 'package:movix/Pages/Others/LoginPage.dart';
import 'package:movix/Pages/Others/PharmaciesPage.dart';
import 'package:movix/Pages/Others/Settings.dart';
import 'package:movix/Pages/Others/SplashPage.dart';
import 'package:movix/Pages/Others/SpoolerPage.dart';
import 'package:movix/Pages/Others/TestPage.dart';
import 'package:movix/Pages/Others/TourneesPage.dart';
import 'package:movix/Pages/Others/UpdatePage.dart';
import 'package:movix/Services/globals.dart';

CustomTransitionPage<Widget> buildPageWithTransition(Widget child) {
  return CustomTransitionPage<Widget>(
    transitionDuration: Duration.zero,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; 
    },
  );
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  observers: [routeObserver],
  redirect: (context, state) {
    // Ne pas rediriger depuis la page splash
    if (state.matchedLocation == '/') {
      return null;
    }
    
    final isLoggedIn = Globals.profil != null;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    if (isLoggedIn && isLoginRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', pageBuilder: (_, __) => buildPageWithTransition(const SplashPage())),
    GoRoute(path: '/login', pageBuilder: (_, __) => buildPageWithTransition(const LoginPage())),
    GoRoute(path: '/home', pageBuilder: (_, __) => buildPageWithTransition(const HomePage())),
    GoRoute(path: '/settings', pageBuilder: (_, __) => buildPageWithTransition(const SettingsPage())),
    GoRoute(path: '/pharmacies', pageBuilder: (_, __) => buildPageWithTransition(const PharmaciesPage())),
    GoRoute(path: '/spooler', pageBuilder: (_, __) => buildPageWithTransition(const SpoolerPage())),
    GoRoute(path: '/update', pageBuilder: (_, __) => buildPageWithTransition(const UpdatePage())),
    GoRoute(path: '/test', pageBuilder: (_, __) => buildPageWithTransition(const SoundTestPage())),
    GoRoute(path: '/tours', pageBuilder: (_, __) => buildPageWithTransition(const TourneesPage())),
    GoRoute(
      path: '/mapbox',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final command = extra['command'] as Command;
        return buildPageWithTransition(MapBoxPage(command: command));
      },
    ),
    GoRoute(
      path: '/pharmacy',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final command = extra['command'] as Command;
        return buildPageWithTransition(PharmacyInfosPage(command: command));
      },
    ),
    GoRoute(
      path: '/anomalie',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final command = extra['command'] as Command;
        final onUpdate = extra['onUpdate'] as VoidCallback;
        return buildPageWithTransition(AnomaliePage(command: command, onUpdate: onUpdate));
      },
    ),
    GoRoute(
      path: '/addinfospharmacy',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final command = extra['command'] as Command;
        return buildPageWithTransition(AddInfosPharmacyPage(command: command));
      },
    ),
    GoRoute(
      path: '/tour/chargement',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tour = extra['tour'] as Tour;
        return buildPageWithTransition(ChargementPage(tour: tour));
      },
    ),
    GoRoute(
      path: '/tour/fschargement',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tour = extra['tour'] as Tour;
        final command = extra['command'] as Command;
        final packageSearcher = extra['packageSearcher'] as PackageSearcher;
        final onUpdate = extra['onUpdate'] as VoidCallback;
        return buildPageWithTransition(FSChargementPage(
          tour: tour,
          command: command,
          packageSearcher: packageSearcher,
          onUpdate: onUpdate,
        ));
      },
    ),
    GoRoute(
      path: '/tour/validateChargement',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tour = extra['tour'] as Tour;
        final packageSearcher = extra['packageSearcher'] as PackageSearcher;
        return buildPageWithTransition(ChargementValidationPage(
          tour: tour,
          packageSearcher: packageSearcher,
        ));
      },
    ),
    GoRoute(
      path: '/tour/livraison',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tour = extra['tour'] as Tour;
        return buildPageWithTransition(LivraisonPage(tour: tour));
      },
    ),
    GoRoute(
      path: '/tour/fslivraison',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final command = extra['command'] as Command;
        final onUpdate = extra['onUpdate'] as VoidCallback;
        return buildPageWithTransition(FSLivraisonPage(command: command, onUpdate: onUpdate));
      },
    ),
    GoRoute(
      path: '/tour/validateLivraison',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final command = extra['command'] as Command;
        final onUpdate = extra['onUpdate'] as VoidCallback;
        return buildPageWithTransition(LivraisonValidationPage(
          onUpdate: onUpdate,
          command: command,
        ));
      },
    ),
  ],
);