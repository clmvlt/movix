import 'package:movix/API/base.dart';
import 'package:movix/Services/globals.dart';

Future<bool> setPackageState(String barcode, int status) async {
  try {
    final response = await ApiBase.put(
      '/packages/state',
      {
        "statusId": status,
        "packageBarcodes": [barcode],
        "createdAt": Globals.getSqlDate(),
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> setCommandState(String id, int status, {String? comment}) async {
  try {
    Map<String, dynamic> body = {
      "commandIds": [id],
      "statusId": status,
      "createdAt": Globals.getSqlDate(),
    };

    if (comment != null && comment.isNotEmpty) {
      body["comment"] = comment;
    }

    final response = await ApiBase.put(
      '/commands/state',
      body,
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

/// Met à jour le champ isForced d'une ou plusieurs commandes
Future<bool> updateCommandIsForced(List<String> commandIds, bool isForced) async {
  try {
    final response = await ApiBase.put(
      '/commands',
      {
        "commandIds": commandIds,
        "isForced": isForced,
        "createdAt": Globals.getSqlDate(),
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

/// Assigne des commandes à une tournée spécifique
Future<bool> assignCommandsToTour(String tourId, List<String> commandIds) async {
  try {
    final response = await ApiBase.put(
      '/commands/assign/$tourId',
      {
        "commandIds": commandIds,
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}
