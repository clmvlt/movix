import 'package:movix/API/base.dart';
import 'package:movix/Models/Profil.dart';

Future<Profil?> login(String identifiant, String password) async {
  try {
    final response = await ApiBase.post('/auth/login', {
      'identifiant': identifiant,
      'password': password
    });

    if (ApiBase.isSuccess(response.statusCode)) {
      final responseData = ApiBase.decodeResponse(response) as Map<String, dynamic>;
      return Profil.fromJson(responseData);
    }

    return null;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<Profil?> me() async {
  try {
    final response = await ApiBase.get('/auth/me');

    if (ApiBase.isSuccess(response.statusCode)) {
      final responseData = ApiBase.decodeResponse(response) as Map<String, dynamic>;
      return Profil.fromJson(responseData);
    }

    return null;
  } catch (e) {
    print(e);
    return null;
  }
} 