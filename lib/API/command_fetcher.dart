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
