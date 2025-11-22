import 'base.dart';

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
