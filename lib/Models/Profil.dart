class Profil {
  String id;
  String identifiant;
  String token;
  String firstName;
  String lastName;
  String birthday;
  String idAccount;
  bool isAdmin;
  bool isWeb;
  bool isMobile;
  bool isStock;
  bool isAVTrans;
  String email;
  String createdAt;
  String updatedAt;
  double latitude;
  double longitude;
  String societe;
  String address1;
  String address2;

  Profil({
    this.id = '',
    this.identifiant = '',
    this.token = '',
    this.firstName = '',
    this.lastName = '',
    this.birthday = '',
    this.idAccount = '',
    this.isAdmin = false,
    this.isWeb = false,
    this.isMobile = false,
    this.isStock = false,
    this.isAVTrans = false,
    this.email = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.latitude = 0.00,
    this.longitude = 0.00,
    this.societe = '',
    this.address1 = '',
    this.address2 = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifiant': identifiant,
      'token': token,
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'id_account': idAccount,
      'is_admin': isAdmin,
      'is_web': isWeb,
      'is_mobile': isMobile,
      'is_stock': isStock,
      'is_avtrans': isAVTrans,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'societe': societe,
      'address1': address1,
      'address2': address2,
    };
  }

  factory Profil.fromJson(Map<String, dynamic> map) {
    return Profil(
      id: map['id'] ?? '',
      identifiant: map['identifiant'] ?? '',
      token: map['token'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      birthday: map['birthday'] ?? '',
      idAccount: map['id_account'] ?? '',
      isAdmin: map['is_admin'] ?? false,
      isWeb: map['is_web'] ?? false,
      isMobile: map['is_mobile'] ?? false,
      isStock: map['is_stock'] ?? false,
      isAVTrans: map['is_avtrans'] ?? false,
      email: map['email'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      latitude: (map['latitude'] is String)
          ? double.parse(map['latitude'])
          : map['latitude']?.toDouble() ?? 0.0,
      longitude: (map['longitude'] is String)
          ? double.parse(map['longitude'])
          : map['longitude']?.toDouble() ?? 0.0,
      societe: map['societe'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
    );
  }
}
