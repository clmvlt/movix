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

Future<bool> setCommandState(String id, int status) async {
  try {
    final response = await ApiBase.put(
      '/commands/state',
      {
        "commandIds": [id],
        "statusId": status,
        "createdAt": Globals.getSqlDate(),
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}
