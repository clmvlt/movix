import 'package:movix/API/base.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Tour.dart';

Future<bool> getProfilTours() async {
  try {
    final response = await ApiBase.get('/tours/by-profile');

    if (!ApiBase.isSuccess(response.statusCode)) return false;

    final data = ApiBase.decodeResponse(response);
    final List<Tour> tours = [];
    
    if (data is List) {
      for (var tourJson in data) {
        if (tourJson is Map<String, dynamic>) {
          final tour = Tour.fromJson(tourJson);
          tours.add(tour);
        }
      }
    }

    await storeTours(tours);
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> assignTour(String id) async {
  try {
    final response = await ApiBase.post('/tours/assign/$id', {});
    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> setTourState(String id, int status) async {
  try {
    final response = await ApiBase.put('/tours/state', {
      'tourIds': [id],
      'statusId': status,
    });
    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> setTourData(String id, Map<String, dynamic> data) async {
  try {
    final response = await ApiBase.put('/tours/$id', data);
    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<Map<String, dynamic>> validateLoading(Tour tour) async {
  try {
    final commandList = tour.commands.values.map((command) {
      // Check if this command has missing packages (status 5)
      bool hasMissingPackages = command.packages.values.any((package) => package.status.id == 5);
      
      Map<String, dynamic> commandData = {
        'commandId': command.id,
        'status': {'id': command.status.id},
        'packages': command.packages.values.map((package) {
          return {
            'barcode': package.barcode,
            'status': {'id': package.status.id},
          };
        }).toList(),
      };
      
      // Add comment if command has missing packages and comment is available
      if (hasMissingPackages && command.deliveryComment.isNotEmpty) {
        commandData['comment'] = command.deliveryComment;
      }
      
      return commandData;
    }).toList();

    final response = await ApiBase.post(
      '/tours/validate-loading/${tour.id}',
      {'commands': commandList},
    );

    final responseData = ApiBase.decodeResponse(response);
    if (response.statusCode == 201) {
      return {
        'success': true,
        'status': responseData['status'],
        'errors': '',
      };
    } else if (response.statusCode == 207) {
      return {
        'success': false,
        'status': responseData['status'],
        'errors': responseData['errors'] ??
            "Impossible de déterminer la source de l'erreur"
      };
    } else {
      return {
        'success': false,
        'status': responseData['status'],
        'errors': "Impossible de déterminer la source de l'erreur"
      };
    }
  } catch (e) {
    return {
      'success': false,
      'status': 'error',
      'errors': e.toString(),
    };
  }
}

/// Récupère les tournées pour une date spécifique
/// [date] doit être au format yyyy-MM-dd
Future<List<Tour>?> getToursByDate(String date) async {
  try {
    final response = await ApiBase.get('/tours/by-date/$date');

    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final data = ApiBase.decodeResponse(response);
    final List<Tour> tours = [];

    if (data is List) {
      for (var tourJson in data) {
        if (tourJson is Map<String, dynamic>) {
          final tour = Tour.fromJson(tourJson);
          tours.add(tour);
        }
      }
    }

    return tours;
  } catch (e) {
    print(e);
    return null;
  }
}

/// Assigne une tournée à un profil spécifique
/// [tourId] ID de la tournée
/// [profilId] ID du profil (null pour désassigner)
Future<bool> assignTourToProfile(String tourId, String? profilId) async {
  try {
    final response = await ApiBase.put(
      '/tours/assign/$tourId',
      {
        "profilId": profilId,
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

/// Met à jour l'ordre des commandes d'une tournée
/// [tourId] ID de la tournée
/// [commands] Liste de maps avec commandId et tourOrder
Future<bool> updateTourOrder(String tourId, List<Map<String, dynamic>> commands) async {
  try {
    final response = await ApiBase.put(
      '/tours/update-order/$tourId',
      {
        "commands": commands,
        "autoUpdateRoute": true,
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}
