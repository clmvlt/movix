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
      return {
        'commandId': command.id,
        'status': {'id': command.status.id},
        'packages': command.packages.values.map((package) {
          return {
            'barcode': package.barcode,
            'status': {'id': package.status.id},
          };
        }).toList(),
      };
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
