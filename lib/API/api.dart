// lib/API/api.dart

library api;

import 'command_fetcher.dart' as _command;
import 'tour_fetcher.dart' as _tour;
import 'pharmacy_fetcher.dart' as _pharmacy;

import 'package:movix/Models/Tour.dart';

class API {
  static Future<bool> setCommandState(String id, String status) {
    return _command.setCommandState(id, status);
  }

  static Future<bool> setPackageState(String barcode, String status) {
    return _command.setPackageState(barcode, status);
  }

  static Future<bool> getProfilTours() {
    return _tour.getProfilTours();
  }

  static Future<Tour?> getTour(String id) {
    return _tour.getTour(id);
  }

  static Future<bool> assignTour(String id) {
    return _tour.assignTour(id);
  }

  static Future<bool> setTourState(String id, String status) {
    return _tour.setTourState(id, status);
  }

  static Future<bool> setTourData(String id, String type, String data) {
    return _tour.setTourData(id, type, data);
  }

  static Future<Map<String, dynamic>> validateLoading(Tour tour) {
    return _tour.validateLoading(tour);
  }

  static Future<Map<String, dynamic>?> getPharmacyInfos(String cip) {
    return _pharmacy.getPharmacyInfos(cip);
  }
}
