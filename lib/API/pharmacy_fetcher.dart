import 'package:movix/API/base.dart';
import 'package:movix/Models/Pharmacy.dart';

Future<Pharmacy?> getPharmacyInfos(String cip) async {
  try {
    final response = await ApiBase.get('/pharmacies/$cip');
    
    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final responseData = ApiBase.decodeResponse(response);
    
    if (responseData is! Map<String, dynamic>) return null;
    
    return Pharmacy.fromJson(responseData);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<List<Pharmacy>> searchPharmacies({
  String? name,
  String? address,
  String? city,
  String? postalCode,
  String? cip,
}) async {
  try {
    // Construire le body de la requête
    final Map<String, dynamic> searchBody = {};
    
    if (name != null && name.isNotEmpty) searchBody['name'] = name;
    if (address != null && address.isNotEmpty) searchBody['address'] = address;
    if (city != null && city.isNotEmpty) searchBody['city'] = city;
    if (postalCode != null && postalCode.isNotEmpty) searchBody['postalCode'] = postalCode;
    if (cip != null && cip.isNotEmpty) searchBody['cip'] = cip;
    
    // Si aucun critère n'est fourni, retourner une liste vide
    if (searchBody.isEmpty) return [];
    
    final response = await ApiBase.post('/pharmacies/search', searchBody);
    
    if (!ApiBase.isSuccess(response.statusCode)) return [];

    final responseData = ApiBase.decodeResponse(response);
    
    if (responseData is! List) return [];
    
    return responseData
        .map((json) => Pharmacy.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Erreur lors de la recherche de pharmacies: $e');
    return [];
  }
}

Future<List<Pharmacy>> searchPharmaciesGlobal(String query) async {
  // Pour une recherche globale, on essaie de deviner le type de recherche
  // Si c'est uniquement des chiffres, on cherche par code postal
  // Sinon on cherche par nom et par ville
  if (query.trim().isEmpty) return [];
  
  final trimmedQuery = query.trim();
  
  // Si c'est uniquement des chiffres (probablement un code postal)
  if (RegExp(r'^\d+$').hasMatch(trimmedQuery)) {
    return await searchPharmacies(postalCode: trimmedQuery);
  }
  
  // Sinon, on cherche par nom ET par ville pour avoir plus de résultats
  final results = await searchPharmacies(name: trimmedQuery);
  if (results.isNotEmpty) return results;
  
  // Si pas de résultats par nom, essayer par ville
  return await searchPharmacies(city: trimmedQuery);
} 