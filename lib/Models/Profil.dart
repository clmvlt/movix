import 'Account.dart';

class Profil {
  String id;
  String identifiant;
  String firstName;
  String lastName;
  String birthday;
  String createdAt;
  String updatedAt;
  bool isAdmin;
  bool isWeb;
  bool isMobile;
  String email;
  bool isStock;
  bool isAvtrans;
  String token;
  String passwordHash;
  Account account;

  Profil({
    required this.id,
    required this.identifiant,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.createdAt,
    required this.updatedAt,
    required this.isAdmin,
    required this.isWeb,
    required this.isMobile,
    required this.email,
    required this.isStock,
    required this.isAvtrans,
    required this.token,
    required this.passwordHash,
    required this.account,
  });

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      id: (json['id'] is String) ? json['id'] as String : '',
      identifiant: (json['identifiant'] is String) ? json['identifiant'] as String : '',
      firstName: (json['firstName'] is String) ? json['firstName'] as String : '',
      lastName: (json['lastName'] is String) ? json['lastName'] as String : '',
      birthday: (json['birthday'] is String) ? json['birthday'] as String : '',
      createdAt: (json['createdAt'] is String) ? json['createdAt'] as String : '',
      updatedAt: (json['updatedAt'] is String) ? json['updatedAt'] as String : '',
      isAdmin: (json['isAdmin'] is bool) ? json['isAdmin'] as bool : false,
      isWeb: (json['isWeb'] is bool) ? json['isWeb'] as bool : false,
      isMobile: (json['isMobile'] is bool) ? json['isMobile'] as bool : false,
      email: (json['email'] is String) ? json['email'] as String : '',
      isStock: (json['isStock'] is bool) ? json['isStock'] as bool : false,
      isAvtrans: (json['isAvtrans'] is bool) ? json['isAvtrans'] as bool : false,
      token: (json['token'] is String) ? json['token'] as String : '',
      passwordHash: (json['passwordHash'] is String) ? json['passwordHash'] as String : '',
      account: Account.fromJson(json['account'] is Map<String, dynamic> ? json['account'] as Map<String, dynamic> : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifiant': identifiant,
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isAdmin': isAdmin,
      'isWeb': isWeb,
      'isMobile': isMobile,
      'email': email,
      'isStock': isStock,
      'isAvtrans': isAvtrans,
      'token': token,
      'passwordHash': passwordHash,
      'account': account.toJson(),
    };
  }
}
