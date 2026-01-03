import 'dart:convert';

import 'package:movix/API/base.dart';
import 'package:movix/Models/Command.dart';
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

Future<bool> setCommandState(
  String id,
  int status, {
  String? comment,
  double? latitude,
  double? longitude,
  bool isWeb = false,
}) async {
  try {
    Map<String, dynamic> body = {
      "commandIds": [id],
      "statusId": status,
      "createdAt": Globals.getSqlDate(),
      "isWeb": isWeb,
    };

    if (comment != null && comment.isNotEmpty) {
      body["comment"] = comment;
    }
    if (latitude != null) {
      body["latitude"] = latitude;
    }
    if (longitude != null) {
      body["longitude"] = longitude;
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

/// Désassigne des commandes de leur tournée
Future<bool> unassignCommands(List<String> commandIds) async {
  try {
    final response = await ApiBase.put(
      '/commands/unassign',
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

/// Récupère les détails d'une commande par ID
Future<Command?> getCommandById(String id) async {
  try {
    final response = await ApiBase.get('/commands/$id');
    if (ApiBase.isSuccess(response.statusCode)) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Command.fromJson(json);
    }
    return null;
  } catch (e) {
    print(e);
    return null;
  }
}

/// Met à jour les informations d'une commande (expDate, comment)
Future<bool> updateCommand({
  required List<String> commandIds,
  String? expDate,
  String? comment,
  bool? isForced,
}) async {
  try {
    Map<String, dynamic> body = {
      "commandIds": commandIds,
      "createdAt": Globals.getSqlDate(),
    };

    if (expDate != null) {
      body["expDate"] = expDate;
    }
    if (comment != null) {
      body["comment"] = comment;
    }
    if (isForced != null) {
      body["isForced"] = isForced;
    }

    final response = await ApiBase.put(
      '/commands',
      body,
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}
