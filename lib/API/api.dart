// lib/API/api.dart

library api;

import 'package:movix/Models/Pharmacy.dart';
import 'package:movix/Models/Tour.dart';

import 'command_fetcher.dart' as _command;
import 'pharmacy_fetcher.dart' as _pharmacy;
import 'tour_fetcher.dart' as _tour;

class API {
  static Future<bool> setCommandState(String id, int status) {
    return _command.setCommandState(id, status);
  }

  static Future<bool> setPackageState(String barcode, int status) {
    return _command.setPackageState(barcode, status);
  }

  static Future<bool> getProfilTours() {
    return _tour.getProfilTours();
  }

  static Future<bool> assignTour(String id) {
    return _tour.assignTour(id);
  }

  static Future<bool> setTourState(String id, int status) {
    return _tour.setTourState(id, status);
  }

  static Future<bool> setTourData(String id, Map<String, dynamic> data) {
    return _tour.setTourData(id, data);
  }

  static Future<Map<String, dynamic>> validateLoading(Tour tour) {
    return _tour.validateLoading(tour);
  }

  static Future<Pharmacy?> getPharmacyInfos(String cip) {
    return _pharmacy.getPharmacyInfos(cip);
  }
}
