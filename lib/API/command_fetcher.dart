import 'package:movix/API/base.dart';
import 'package:movix/Services/globals.dart';

Future<bool> setPackageState(String barcode, String status) async {
  try {
    final response = await ApiBase.post(
      '/setPackageState/$barcode',
      {
        "status": status,
        "created_at": Globals.getSqlDate(),
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> setCommandState(String id, String status) async {
  try {
    final response = await ApiBase.post(
      '/setCommandState/$id',
      {
        "status": status,
        "created_at": Globals.getSqlDate(),
      },
    );

    return ApiBase.isSuccess(response.statusCode);
  } catch (e) {
    print(e);
    return false;
  }
}
