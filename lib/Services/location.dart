import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  LocationData? _currentLocation;
  final _locationStreamController = StreamController<LocationData>.broadcast();
  StreamSubscription<LocationData>? _locationSubscription;

  LocationService() {
    _initialize();
  }

  Future<void> _initialize() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }

    if (permission == PermissionStatus.granted) {
      _locationSubscription =
          _location.onLocationChanged.listen((locationData) {
        _currentLocation = locationData;
        _locationStreamController.add(locationData);
      });
    }
  }

  LocationData? get currentLocation => _currentLocation;

  Stream<LocationData> get locationStream => _locationStreamController.stream;

  void dispose() {
    _locationSubscription?.cancel();
    _locationStreamController.close();
  }
}

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<LocationService>(() => LocationService());
}
