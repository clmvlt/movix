import 'Zone.dart';

class PharmacyPicture {
  String id;
  String name;
  String createdAt;
  String imagePath;
  int displayOrder;

  PharmacyPicture({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.imagePath,
    required this.displayOrder,
  });

  factory PharmacyPicture.fromJson(Map<String, dynamic> json) {
    return PharmacyPicture(
      id: (json['id'] is String) ? json['id'] as String : '',
      name: (json['name'] is String) ? json['name'] as String : '',
      createdAt: (json['createdAt'] is String) ? json['createdAt'] as String : '',
      imagePath: (json['imagePath'] is String) ? json['imagePath'] as String : '',
      displayOrder: (json['displayOrder'] is int) ? json['displayOrder'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'imagePath': imagePath,
      'displayOrder': displayOrder,
    };
  }
}

class Pharmacy {
  String cip;
  String name;
  String address1;
  String address2;
  String address3;
  String postalCode;
  String city;
  String country;
  String informations;
  String phone;
  String fax;
  String email;
  double latitude;
  double longitude;
  String quality;
  String firstName;
  String lastName;
  bool neverOrdered;
  Zone? zone;
  List<PharmacyPicture> pictures;

  Pharmacy({
    required this.cip,
    required this.name,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.postalCode,
    required this.city,
    required this.country,
    required this.informations,
    required this.phone,
    required this.fax,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.quality,
    required this.firstName,
    required this.lastName,
    required this.neverOrdered,
    this.zone,
    required this.pictures,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      cip: (json['cip'] is String) ? json['cip'] as String : '',
      name: (json['name'] is String) ? json['name'] as String : '',
      address1: (json['address1'] is String) ? json['address1'] as String : '',
      address2: (json['address2'] is String) ? json['address2'] as String : '',
      address3: (json['address3'] is String) ? json['address3'] as String : '',
      postalCode: (json['postalCode'] is String) ? json['postalCode'] as String : '',
      city: (json['city'] is String) ? json['city'] as String : '',
      country: (json['country'] is String) ? json['country'] as String : '',
      informations: (json['informations'] is String) ? json['informations'] as String : '',
      phone: (json['phone'] is String) ? json['phone'] as String : '',
      fax: (json['fax'] is String) ? json['fax'] as String : '',
      email: (json['email'] is String) ? json['email'] as String : '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      quality: (json['quality'] is String) ? json['quality'] as String : '',
      firstName: (json['firstName'] is String) ? json['firstName'] as String : '',
      lastName: (json['lastName'] is String) ? json['lastName'] as String : '',
      neverOrdered: (json['neverOrdered'] is bool) ? json['neverOrdered'] as bool : false,
      zone: json['zone'] != null ? Zone.fromJson(json['zone'] as Map<String, dynamic>) : null,
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((e) => PharmacyPicture.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cip': cip,
      'name': name,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'postalCode': postalCode,
      'city': city,
      'country': country,
      'informations': informations,
      'phone': phone,
      'fax': fax,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'quality': quality,
      'firstName': firstName,
      'lastName': lastName,
      'neverOrdered': neverOrdered,
      'zone': zone?.toJson(),
      'pictures': pictures.map((e) => e.toJson()).toList(),
    };
  }
} 