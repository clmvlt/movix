import 'dart:io';

import 'package:movix/Services/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// Applications de navigation disponibles
enum MapApp {
  googleMaps,
  waze,
  appleMaps, // iOS uniquement
}

/// Résultat du lancement de la navigation
enum MapLaunchResult {
  success,
  noCoordinates,
  launchFailed,
}

/// Extension pour obtenir le nom d'affichage de l'app
extension MapAppExtension on MapApp {
  String get displayName {
    switch (this) {
      case MapApp.googleMaps:
        return 'Google Maps';
      case MapApp.waze:
        return 'Waze';
      case MapApp.appleMaps:
        return 'Apple Maps';
    }
  }

  /// Valeur stockée en base (pour SharedPreferences)
  String get storageKey {
    switch (this) {
      case MapApp.googleMaps:
        return 'google_maps';
      case MapApp.waze:
        return 'waze';
      case MapApp.appleMaps:
        return 'apple_maps';
    }
  }

  /// Créer depuis la clé de stockage
  static MapApp fromStorageKey(String key) {
    switch (key) {
      case 'google_maps':
        return MapApp.googleMaps;
      case 'waze':
        return MapApp.waze;
      case 'apple_maps':
        return MapApp.appleMaps;
      // Migration des anciennes valeurs
      case 'Google Maps':
        return MapApp.googleMaps;
      case 'Waze':
        return MapApp.waze;
      default:
        return Platform.isIOS ? MapApp.appleMaps : MapApp.googleMaps;
    }
  }
}

/// Service de gestion des applications de navigation GPS
class MapService {
  MapService._();
  static final MapService _instance = MapService._();
  static MapService get instance => _instance;

  /// Retourne les apps de navigation disponibles selon la plateforme
  static List<MapApp> getAvailableApps() {
    if (Platform.isIOS) {
      return [MapApp.appleMaps, MapApp.googleMaps, MapApp.waze];
    } else {
      return [MapApp.googleMaps, MapApp.waze];
    }
  }

  /// Retourne l'app par défaut selon la plateforme
  static MapApp getDefaultApp() {
    return Platform.isIOS ? MapApp.appleMaps : MapApp.googleMaps;
  }

  /// Ouvre la navigation vers les coordonnées spécifiées
  ///
  /// [latitude] et [longitude] : coordonnées de destination
  /// [preferredApp] : app à utiliser (utilise Globals.MAP_APP si null)
  ///
  /// Retourne [MapLaunchResult] indiquant le résultat de l'opération
  Future<MapLaunchResult> openNavigation({
    double? latitude,
    double? longitude,
    MapApp? preferredApp,
  }) async {
    final double lat = latitude ?? 0;
    final double lng = longitude ?? 0;

    // Vérifier que les coordonnées sont valides
    if (lat == 0 || lng == 0) {
      Globals.showSnackbar(
        'Aucune position disponible.',
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return MapLaunchResult.noCoordinates;
    }

    final MapApp app = preferredApp ?? Globals.MAP_APP;
    final uris = _buildUris(lat, lng, app);

    // Tenter d'ouvrir chaque URI dans l'ordre
    for (final uri in uris) {
      try {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return MapLaunchResult.success;
        }
      } catch (_) {
        // Essayer l'URI suivant
      }
    }

    // Aucun URI n'a fonctionné
    Globals.showSnackbar(
      'Impossible d\'ouvrir l\'application de navigation.',
      backgroundColor: Globals.COLOR_MOVIX_RED,
    );
    return MapLaunchResult.launchFailed;
  }

  /// Construit la liste des URIs à tenter selon la plateforme et l'app
  List<Uri> _buildUris(double lat, double lng, MapApp app) {
    final List<Uri> uris = [];

    if (Platform.isAndroid) {
      uris.addAll(_buildAndroidUris(lat, lng, app));
    } else if (Platform.isIOS) {
      uris.addAll(_buildIOSUris(lat, lng, app));
    } else {
      // Web/Desktop fallback
      uris.add(_buildWebUri(lat, lng, app));
    }

    return uris;
  }

  /// URIs pour Android
  List<Uri> _buildAndroidUris(double lat, double lng, MapApp app) {
    switch (app) {
      case MapApp.googleMaps:
        return [
          Uri.parse('google.navigation:q=$lat,$lng&mode=d'),
          Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'),
        ];
      case MapApp.waze:
        return [
          Uri.parse('waze://?ll=$lat,$lng&navigate=yes'),
          Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
          Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes'),
        ];
      case MapApp.appleMaps:
        // Apple Maps n'existe pas sur Android, fallback vers Google Maps
        return [
          Uri.parse('google.navigation:q=$lat,$lng&mode=d'),
          Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'),
        ];
    }
  }

  /// URIs pour iOS
  List<Uri> _buildIOSUris(double lat, double lng, MapApp app) {
    switch (app) {
      case MapApp.appleMaps:
        return [
          Uri.parse('maps://?daddr=$lat,$lng&dirflg=d'),
          Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d'),
        ];
      case MapApp.googleMaps:
        return [
          Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving'),
          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'),
        ];
      case MapApp.waze:
        return [
          Uri.parse('waze://?ll=$lat,$lng&navigate=yes'),
          Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes'),
        ];
    }
  }

  /// URI web de fallback
  Uri _buildWebUri(double lat, double lng, MapApp app) {
    switch (app) {
      case MapApp.waze:
        return Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
      case MapApp.appleMaps:
        return Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
      case MapApp.googleMaps:
        return Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    }
  }
}
