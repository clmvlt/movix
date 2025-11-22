class Account {
  String id;
  String societe;
  String address1;
  String address2;
  String postalCode;
  String city;
  String country;
  bool isActive;
  String createdAt;
  String updatedAt;
  double latitude;
  double longitude;
  int maxProfiles;
  String anomaliesEmails;
  bool isScanCIP;
  bool autoSendAnomalieEmails;
  bool autoCreateTour;
  String logoUrl;

  Account({
    required this.id,
    required this.societe,
    required this.address1,
    required this.address2,
    required this.postalCode,
    required this.city,
    required this.country,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
    required this.maxProfiles,
    required this.anomaliesEmails,
    required this.isScanCIP,
    required this.autoSendAnomalieEmails,
    required this.autoCreateTour,
    required this.logoUrl,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: (json['id'] is String) ? json['id'] as String : '',
      societe: (json['societe'] is String) ? json['societe'] as String : '',
      address1: (json['address1'] is String) ? json['address1'] as String : '',
      address2: (json['address2'] is String) ? json['address2'] as String : '',
      postalCode: (json['postalCode'] is String) ? json['postalCode'] as String : '',
      city: (json['city'] is String) ? json['city'] as String : '',
      country: (json['country'] is String) ? json['country'] as String : '',
      isActive: (json['isActive'] is bool) ? json['isActive'] as bool : false,
      createdAt: (json['createdAt'] is String) ? json['createdAt'] as String : '',
      updatedAt: (json['updatedAt'] is String) ? json['updatedAt'] as String : '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      maxProfiles: (json['maxProfiles'] is int) ? json['maxProfiles'] as int : 0,
      anomaliesEmails: (json['anomaliesEmails'] is String) ? json['anomaliesEmails'] as String : '',
      isScanCIP: (json['isScanCIP'] is bool) ? json['isScanCIP'] as bool : false,
      autoSendAnomalieEmails: (json['autoSendAnomalieEmails'] is bool) ? json['autoSendAnomalieEmails'] as bool : false,
      autoCreateTour: (json['autoCreateTour'] is bool) ? json['autoCreateTour'] as bool : false,
      logoUrl: (json['logoUrl'] is String) ? json['logoUrl'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'societe': societe,
      'address1': address1,
      'address2': address2,
      'postalCode': postalCode,
      'city': city,
      'country': country,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
      'maxProfiles': maxProfiles,
      'anomaliesEmails': anomaliesEmails,
      'isScanCIP': isScanCIP,
      'autoSendAnomalieEmails': autoSendAnomalieEmails,
      'autoCreateTour': autoCreateTour,
      'logoUrl': logoUrl,
    };
  }
}
