import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:get_it/get_it.dart';
import 'package:movix/Services/location.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

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
  late final FMTCTileProvider _tileProvider;

  bool sateliteMode = false;
  LatLng? currentUserLocation;
  double? currentHeading;

  StreamSubscription? _locationSub;
  StreamSubscription? _compassSub;

  @override
  void initState() {
    super.initState();
    locationDepot = LatLng(
      double.parse(widget.command.pharmacyLatitude),
      double.parse(widget.command.pharmacyLongitude),
    );
    _tileProvider = FMTCTileProvider(
      stores: const {
        'mapStore': BrowseStoreStrategy.readUpdateCreate,
      },
      loadingStrategy: BrowseLoadingStrategy.cacheFirst,
    );
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
    setState(() {
      sateliteMode = !sateliteMode;
    });
  }

  Future<void> _centerOnUserLocation() async {
    final loc = _locationService.currentLocation;
    if (loc != null && loc.latitude != null && loc.longitude != null) {
      mapController.move(LatLng(loc.latitude!, loc.longitude!), 17);
    } else {
      Globals.showSnackbar("Localisation non disponible",
          backgroundColor: Colors.red);
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

  @override
  void dispose() {
    _locationSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.command.pharmacyName),
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
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
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/${sateliteMode ? "satellite-streets-v12" : "streets-v12"}/tiles/{z}/{x}/{y}@2x?access_token=${dotenv.env['MAPBOX_TOKEN']}",
                tileProvider: _tileProvider,
              ),
              if (currentUserLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: currentUserLocation!,
                      radius: 10,
                      color: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blueAccent,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: locationDepot,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(
                      Icons.location_on_sharp,
                      color: Globals.COLOR_MOVIX,
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
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.blue,
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
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Globals.COLOR_MOVIX,
                  onPressed: _toggleMapStyle,
                  tooltip: "Style",
                  child: Icon(sateliteMode ? Icons.public : Icons.map),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Globals.COLOR_MOVIX,
                  onPressed: _centerOnPharmacy,
                  tooltip: "Pharmacie",
                  child: const Icon(Icons.local_hospital),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Globals.COLOR_MOVIX,
                  onPressed: _centerOnUserLocation,
                  tooltip: "Ma position",
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Globals.COLOR_MOVIX,
                  onPressed: _zoomIn,
                  tooltip: "Zoom +",
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Globals.COLOR_MOVIX,
                  onPressed: _zoomOut,
                  tooltip: "Zoom -",
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.command.pharmacyName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    "${widget.command.pharmacyAddress1}, ${widget.command.pharmacyPostalCode} ${widget.command.pharmacyCity}",
                  ),
                  if (widget.command.pharmacyPhone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text("📞 ${widget.command.pharmacyPhone}"),
                    ),
                  if (widget.command.pharmacyEmail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("✉️ ${widget.command.pharmacyEmail}"),
                    ),
                  if (widget.command.pharmacyInformations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("ℹ️ ${widget.command.pharmacyInformations}"),
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
