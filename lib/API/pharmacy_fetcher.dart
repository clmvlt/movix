import 'package:movix/API/base.dart';

Future<Map<String, dynamic>?> getPharmacyInfos(String cip) async {
  try {
    final response = await ApiBase.post('/getPharmacyInfos/$cip', {});
    
    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final responseData = ApiBase.decodeResponse(response);
    print(responseData);
    return responseData['data'] as Map<String, dynamic>;
  } catch (e) {
    print(e);
    return null;
  }
}