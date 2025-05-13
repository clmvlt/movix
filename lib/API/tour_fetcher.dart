import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/API/base.dart';

Future<bool> getProfilTours() async {
  try {
    final response = await ApiBase.get('/tour/getProfilTours');

    if (!ApiBase.isSuccess(response.statusCode)) return false;

    final data = ApiBase.decodeResponse(response)['data'];
    final List<Tour> tours = [];

    for (var tourJson in data) {
      final tour = await getTour(tourJson['id_tour']);
      if (tour != null) {
        tours.add(tour);
      }
    }

    await storeTours(tours);
    return true;
  } catch (_) {
    return false;
  }
}

Future<Tour?> getTour(String id) async {
  try {
    final response = await ApiBase.get('/tour/getTour/$id');

    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final responseData = ApiBase.decodeResponse(response);
    if (responseData['data'] == null) {
      print("Error: Invalid response data");
      return null;
    }

    final tourData = responseData['data']['tour'];
    if (tourData == null) {
      print("Error: Tour data is missing");
      return null;
    }

    tourData['commands'] = responseData['data']['commands'];
    final tour = Tour.fromJson(tourData);

    return tour;
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

Future<bool> assignTour(String id) async {
  try {
    final response = await ApiBase.get('/tour/assignTour/$id');
    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> setTourState(String id, String status) async {
  try {
    final response =
        await ApiBase.post('/tour/setTourState/$id', {'status': status});
    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> setTourData(String id, String type, String data) async {
  try {
    final response = await ApiBase.post('/tour/setTourData/$id', {type: data});
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
        'id_command': command.id,
        'id_status': command.idStatus,
        'created_at': Globals.getSqlDate(),
        'packages': command.packages.values.map((package) {
          return {
            'barcode': package.barcode,
            'id_status': package.idStatus,
            'created_at': Globals.getSqlDate(),
          };
        }).toList(),
      };
    }).toList();

    final response = await ApiBase.post(
      '/tour/validateLoading/${tour.id}',
      {'commands': commandList},
    );

    final responseData = ApiBase.decodeResponse(response);
    if (response.statusCode == 200) {
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
