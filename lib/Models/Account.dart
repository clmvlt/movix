class Account {
  String id;
  String societe;
  String address1;
  String address2;
  bool isActive;
  String createdAt;
  String updatedAt;
  double latitude;
  double longitude;
  bool isScanCIP;
  bool autoSendAnomalieEmails;

  Account({
    required this.id,
    required this.societe,
    required this.address1,
    required this.address2,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
    required this.isScanCIP,
    required this.autoSendAnomalieEmails,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: (json['id'] is String) ? json['id'] as String : '',
      societe: (json['societe'] is String) ? json['societe'] as String : '',
      address1: (json['address1'] is String) ? json['address1'] as String : '',
      address2: (json['address2'] is String) ? json['address2'] as String : '',
      isActive: (json['isActive'] is bool) ? json['isActive'] as bool : false,
      createdAt: (json['createdAt'] is String) ? json['createdAt'] as String : '',
      updatedAt: (json['updatedAt'] is String) ? json['updatedAt'] as String : '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      isScanCIP: (json['isScanCIP'] is bool) ? json['isScanCIP'] as bool : false,
      autoSendAnomalieEmails: (json['autoSendAnomalieEmails'] is bool) ? json['autoSendAnomalieEmails'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'societe': societe,
      'address1': address1,
      'address2': address2,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
      'isScanCIP': isScanCIP,
      'autoSendAnomalieEmails': autoSendAnomalieEmails,
    };
  }
} 