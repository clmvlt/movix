import 'package:movix/Models/Profil.dart';

class Status {
  int id;
  String name;
  String createdAt;
  Profil profil;

  Status({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.profil,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: (json['id'] is int) ? json['id'] as int : 0,
      name: (json['name'] is String) ? json['name'] as String : '',
      createdAt: (json['createdAt'] is String) ? json['createdAt'] as String : '',
      profil: Profil.fromJson(json['profil'] is Map<String, dynamic> ? json['profil'] as Map<String, dynamic> : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'profil': profil.toJson(),
    };
  }
} 