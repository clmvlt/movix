import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/location.dart';

class MapBoxPage extends StatefulWidget {
  final Command command;

  const MapBoxPage({super.key, required this.command});

  @override
  MapBoxPageState createState() => MapBoxPageState();
}

class MapBoxPageState extends State<MapBoxPage> {
  late final LatLng locationDepot;
  final MapController mapController = MapController();
  final LocationService _locationService = GetIt.I<LocationService>();

  bool sateliteMode = false;
  LatLng? currentUserLocation;
  double? currentHeading;
  String tileLayerKey = 'initial';

  Color get _colorAdap {
    final tourColor = widget.command.tourColor;
    if (tourColor.isNotEmpty && tourColor.startsWith('#')) {
      return Color(int.parse("0xff${tourColor.substring(1)}"));
    }
    return Globals.COLOR_ADAPTIVE_ACCENT;
  }

  StreamSubscription<LocationData>? _locationSub;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    locationDepot = LatLng(
      widget.command.pharmacy.latitude,
      widget.command.pharmacy.longitude,
    );
    
    // Debug: vérifier le token MapBox
    if (!_hasValidToken) {
      print('ATTENTION: Token MapBox manquant ou invalide. Utilisation d\'OpenStreetMap comme fallback.');
    } else {
      print('Token MapBox disponible: ${_mapboxToken!.substring(0, 8)}...');
    }
    
    _initUserPosition();
    _listenToUserLocation();
    _listenToCompass();
  }

  void _initUserPosition() async {
    final loc = _locationService.currentLocation;
    if (loc != null && loc.latitude != null && loc.longitude != null) {
      setState(() {
        currentUserLocation = LatLng(loc.latitude!, loc.longitude!);
      });
    }
  }

  void _listenToUserLocation() {
    _locationSub = _locationService.locationStream.listen((loc) {
      if (mounted && loc.latitude != null && loc.longitude != null) {
        setState(() {
          currentUserLocation = LatLng(loc.latitude!, loc.longitude!);
        });
      }
    });
  }

  void _listenToCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        setState(() {
          currentHeading = event.heading;
        });
      }
    });
  }

  void _toggleMapStyle() {
    // Si pas de token MapBox et on essaie d'activer le satellite
    if (!_hasValidToken && !sateliteMode) {
      Globals.showSnackbar(
        "Mode satellite non disponible sans token MapBox", 
        backgroundColor: Globals.COLOR_MOVIX_YELLOW
      );
      return;
    }
    
    setState(() {
      sateliteMode = !sateliteMode;
      // Générer une nouvelle clé pour forcer le rechargement des tuiles
      tileLayerKey = '${sateliteMode ? 'satellite' : 'street'}_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  Future<void> _centerOnUserLocation() async {
    final loc = _locationService.currentLocation;
    if (loc != null && loc.latitude != null && loc.longitude != null) {
      mapController.move(LatLng(loc.latitude!, loc.longitude!), 17);
    } else {
      Globals.showSnackbar("Localisation non disponible",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }
  }

  void _centerOnPharmacy() {
    mapController.move(locationDepot, 17);
  }

  void _zoomIn() {
    mapController.move(
        mapController.camera.center, mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    mapController.move(
        mapController.camera.center, mapController.camera.zoom - 1);
  }

  String _getMapStyle() {
    // Si pas de token MapBox, on ne peut pas utiliser les styles MapBox
    if (!_hasValidToken) {
      return "streets-v12"; // fallback, mais ne sera pas utilisé
    }
    
    if (sateliteMode) {
      return "satellite-streets-v12";
    } else {
      // Si dark mode est activé, utiliser le style dark, sinon le style normal
      return Globals.darkModeNotifier.value ? "dark-v11" : "streets-v12";
    }
  }

  String? get _mapboxToken => dotenv.env['MAPBOX_TOKEN'];

  bool get _hasValidToken => _mapboxToken != null && _mapboxToken!.isNotEmpty;

  Widget _buildMapControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: isLast ? null : Border(
              bottom: BorderSide(
                color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: Globals.COLOR_TEXT_DARK,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Globals.COLOR_TEXT_DARK,
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        title: Text(widget.command.pharmacy.name),
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: Globals.darkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Stack(
            children: [
              // Fond sombre pour le mode dark
              if (isDarkMode)
                Container(
                  color: Globals.COLOR_BACKGROUND,
                ),
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: locationDepot,
                  initialZoom: 17.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  if (_hasValidToken)
                    TileLayer(
                      key: ValueKey(tileLayerKey),
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/mapbox/${_getMapStyle()}/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken",
                      maxZoom: 18,
                      userAgentPackageName: 'com.movix.app',
                    )
                  else
                    // Fallback vers OpenStreetMap si pas de token MapBox
                    TileLayer(
                      key: ValueKey(tileLayerKey),
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.movix.app',
                      maxZoom: 18,
                    ),
              if (currentUserLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: currentUserLocation!,
                      radius: 10,
                      color: Globals.COLOR_MOVIX,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: locationDepot,
                    width: 40.0,
                    height: 40.0,
                    child: Icon(
                      Icons.location_on_sharp,
                      color: _colorAdap,
                      size: 40.0,
                    ),
                  ),
                  if (currentUserLocation != null)
                    Marker(
                      point: currentUserLocation!,
                      width: 40,
                      height: 40,
                      child: Transform.rotate(
                        angle: ((currentHeading ?? 0) * (math.pi / 180) * -1),
                        child: Icon(
                          Icons.navigation,
                          color: Globals.COLOR_MOVIX,
                          size: 36,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMapControlButton(
                    icon: sateliteMode ? Icons.public : Icons.map,
                    tooltip: "Style",
                    onPressed: _toggleMapStyle,
                    isFirst: true,
                  ),
                  _buildMapControlButton(
                    icon: Icons.local_hospital,
                    tooltip: "Pharmacie",
                    onPressed: _centerOnPharmacy,
                  ),
                  _buildMapControlButton(
                    icon: Icons.my_location,
                    tooltip: "Ma position",
                    onPressed: _centerOnUserLocation,
                  ),
                  _buildMapControlButton(
                    icon: Icons.zoom_in,
                    tooltip: "Zoom +",
                    onPressed: _zoomIn,
                  ),
                  _buildMapControlButton(
                    icon: Icons.zoom_out,
                    tooltip: "Zoom -",
                    onPressed: _zoomOut,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _colorAdap.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_hospital,
                                color: _colorAdap,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.command.pharmacy.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Globals.COLOR_TEXT_DARK,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          text: "${widget.command.pharmacy.address1}, ${widget.command.pharmacy.postalCode} ${widget.command.pharmacy.city}",
                        ),
                        if (widget.command.pharmacy.phone.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            text: widget.command.pharmacy.phone,
                          ),
                        ],
                        if (widget.command.pharmacy.email.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            text: widget.command.pharmacy.email,
                          ),
                        ],
                        if (widget.command.pharmacy.informations.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.info_outline,
                            text: widget.command.pharmacy.informations,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
            ],
          );
        },
      ),
    );
  }
}
