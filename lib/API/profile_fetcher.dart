import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/globals.dart';
import 'base.dart';

/// Met à jour le profil de l'utilisateur connecté
/// Retourne le profil mis à jour si succès, null si échec
Future<({Profil? profil, String? error})> updateProfil({
  required String firstName,
  required String lastName,
  required String birthday,
  required String email,
  String? profilPicture,
}) async {
  final body = <String, dynamic>{
    'firstName': firstName,
    'lastName': lastName,
    'birthday': birthday,
    'email': email,
  };

  if (profilPicture != null && profilPicture.isNotEmpty) {
    body['profilPicture'] = profilPicture;
  }

  final response = await ApiBase.put('/profiles/update-profil', body);

  if (ApiBase.isSuccess(response.statusCode)) {
    final responseData = ApiBase.decodeResponse(response) as Map<String, dynamic>;
    // Conserver le token et l'account actuels
    responseData['token'] = Globals.profil?.token ?? '';
    responseData['passwordHash'] = Globals.profil?.passwordHash ?? '';
    responseData['account'] = Globals.profil?.account.toJson() ?? {};
    return (profil: Profil.fromJson(responseData), error: null);
  } else if (response.statusCode == 400) {
    return (profil: null, error: "Données invalides. Vérifiez vos entrées.");
  } else if (response.statusCode == 401) {
    return (profil: null, error: "Non autorisé.");
  } else if (response.statusCode == 403) {
    return (profil: null, error: "Action non autorisée.");
  } else if (response.statusCode == 409) {
    return (profil: null, error: "Cet email est déjà utilisé.");
  } else {
    return (profil: null, error: "Erreur lors de la mise à jour du profil.");
  }
}

/// Change le mot de passe de l'utilisateur connecté
/// Retourne un message d'erreur si échec, null si succès
Future<String?> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  final response = await ApiBase.put('/profiles/change-password', {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  });

  if (response.statusCode == 204) {
    return null; // Succès
  } else if (response.statusCode == 400) {
    return "Données invalides. Vérifiez vos entrées.";
  } else if (response.statusCode == 401) {
    return "Mot de passe actuel incorrect.";
  } else if (response.statusCode == 403) {
    return "Action non autorisée.";
  } else {
    return "Erreur lors du changement de mot de passe.";
  }
}
