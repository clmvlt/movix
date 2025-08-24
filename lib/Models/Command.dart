import 'package:movix/Models/Account.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Pharmacy.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Models/Status.dart';
import 'package:movix/Models/Zone.dart';

class Command {
  String id;
  String tourId;
  String closeDate;
  int tourOrder;
  String tourColor;
  String expDate;
  String comment;
  String deliveryComment;
  bool newPharmacy;
  double latitude;
  double longitude;
  Map<String, Package> packages;
  Pharmacy pharmacy;
  Status status;

  Command({
    required this.id,
    this.tourId = '',
    this.closeDate = '',
    this.tourOrder = 0,
    this.tourColor = '',
    this.expDate = '',
    this.comment = '',
    this.deliveryComment = '',
    this.newPharmacy = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    Map<String, Package>? packages,
    Pharmacy? pharmacy,
    Status? status,
  }) : packages = packages ?? {},
       pharmacy = pharmacy ?? Pharmacy(
         cip: '',
         name: '',
         address1: '',
         address2: '',
         address3: '',
         postalCode: '',
         city: '',
         country: '',
         informations: '',
         phone: '',
         fax: '',
         email: '',
         latitude: 0.0,
         longitude: 0.0,
         quality: '',
         firstName: '',
         lastName: '',
         neverOrdered: false,
         zone: Zone(id: '', name: ''),
         pictures: []
       ),
       status = status ?? Status(
         id: 0,
         name: '',
         createdAt: '',
         profil: Profil(
           id: '',
           identifiant: '',
           firstName: '',
           lastName: '',
           birthday: '',
           createdAt: '',
           updatedAt: '',
           isAdmin: false,
           isWeb: false,
           isMobile: false,
           email: '',
           isStock: false,
           isAvtrans: false,
           token: '',
           passwordHash: '',
           account: Account(
             id: '',
             societe: '',
             address1: '',
             address2: '',
             isActive: false,
             createdAt: '',
             updatedAt: '',
             latitude: 0.0,
             longitude: 0.0,
           ),
         ),
       );

  factory Command.fromJson(Map<String, dynamic> json) {
    Map<String, Package> packagesMap = {};
    if (json['packages'] != null && json['packages'] is List) {
      final packagesList = json['packages'] as List;
      for (var package in packagesList) {
        if (package is Map<String, dynamic>) {
          package['commandId'] = json['id'];
          if (package['barcode'] is String) {
            packagesMap[package['barcode'] as String] = Package.fromJson(package);
          }
        }
      }
    }

    return Command(
      id: (json['id'] is String) ? json['id'] as String : '',
      tourId: (json['tourId'] is String) ? json['tourId'] as String : '',
      closeDate: (json['closeDate'] is String) ? json['closeDate'] as String : '',
      tourOrder: (json['tourOrder'] is int) ? json['tourOrder'] as int : 0,
      tourColor: (json['tourColor'] is String) ? json['tourColor'] as String : '',
      expDate: (json['expDate'] is String) ? json['expDate'] as String : '',
      comment: (json['comment'] is String) ? json['comment'] as String : '',
      deliveryComment: (json['deliveryComment'] is String) ? json['deliveryComment'] as String : '',
      newPharmacy: (json['newPharmacy'] is bool) ? json['newPharmacy'] as bool : false,
      latitude: (json['latitude'] is double) ? json['latitude'] as double : 0.0,
      longitude: (json['longitude'] is double) ? json['longitude'] as double : 0.0,
      packages: packagesMap,
      pharmacy: Pharmacy.fromJson(json['pharmacy'] is Map<String, dynamic> ? json['pharmacy'] as Map<String, dynamic> : {}),
      status: Status.fromJson(json['status'] is Map<String, dynamic> ? json['status'] as Map<String, dynamic> : {}),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> packagesList = [];
    packages.forEach((barcode, package) {
      packagesList.add(package.toJson());
    });

    return {
      'id': id,
      'tourId': tourId,
      'closeDate': closeDate,
      'tourOrder': tourOrder,
      'tourColor': tourColor,
      'expDate': expDate,
      'comment': comment,
      'deliveryComment': deliveryComment,
      'newPharmacy': newPharmacy,
      'latitude': latitude,
      'longitude': longitude,
      'packages': packagesList,
      'pharmacy': pharmacy.toJson(),
      'status': status.toJson(),
    };
  }
}
