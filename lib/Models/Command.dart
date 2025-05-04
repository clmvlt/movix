import 'package:movix/Models/Package.dart';

class Command {
  String cip;
  String id;
  String cNumberOfPackages;
  String cCloseDate;
  String cWeight;
  String cVolume;
  String cNumTransport;
  int tourOrder;
  String idTour;
  String expDate;
  String expCode;
  String pharmacyCip;
  String pharmacyName;
  String pharmacyAddress1;
  String pharmacyAddress2;
  String pharmacyAddress3;
  String pharmacyPostalCode;
  String pharmacyCity;
  String pharmacyCountry;
  String pharmacyInformations;
  String pharmacyPhone;
  String pharmacyFax;
  String pharmacyEmail;
  String pharmacyLatitude;
  String pharmacyLongitude;
  String pharmacyQuality;
  String pharmacyFirstName;
  String pharmacyLastName;
  String mezTourExpCode;
  String mezTourExpName;
  String mezTourExpAddress1;
  String mezTourExpAddress2;
  String mezTourExpAddress3;
  String mezTourExpPostalCode;
  String mezTourExpCity;
  String mezTourExpCountry;
  String mezTourExpInformations;
  String mezTourExpPhone;
  String mezTourExpFax;
  String mezTourExpEmail;
  String mezTourExpLatitude;
  String mezTourExpLongitude;
  String calculatedWeight;
  String calculatedPackages;
  String tourName;
  String tourColor;
  String statusDate;
  String statusName;
  String idStatus;
  bool pNew;
  Map<String, Package> packages;

  Command({
    this.cip = "",
    this.id = "",
    this.cNumberOfPackages = "",
    this.cCloseDate = "",
    this.cWeight = "",
    this.cVolume = "",
    this.cNumTransport = "",
    this.tourOrder = 0,
    this.idTour = "",
    this.expDate = "",
    this.expCode = "",
    this.pharmacyCip = "",
    this.pharmacyName = "",
    this.pharmacyAddress1 = "",
    this.pharmacyAddress2 = "",
    this.pharmacyAddress3 = "",
    this.pharmacyPostalCode = "",
    this.pharmacyCity = "",
    this.pharmacyCountry = "",
    this.pharmacyInformations = "",
    this.pharmacyPhone = "",
    this.pharmacyFax = "",
    this.pharmacyEmail = "",
    this.pharmacyLatitude = "",
    this.pharmacyLongitude = "",
    this.pharmacyQuality = "",
    this.pharmacyFirstName = "",
    this.pharmacyLastName = "",
    this.mezTourExpCode = "",
    this.mezTourExpName = "",
    this.mezTourExpAddress1 = "",
    this.mezTourExpAddress2 = "",
    this.mezTourExpAddress3 = "",
    this.mezTourExpPostalCode = "",
    this.mezTourExpCity = "",
    this.mezTourExpCountry = "",
    this.mezTourExpInformations = "",
    this.mezTourExpPhone = "",
    this.mezTourExpFax = "",
    this.mezTourExpEmail = "",
    this.mezTourExpLatitude = "",
    this.mezTourExpLongitude = "",
    this.calculatedWeight = "",
    this.calculatedPackages = "",
    this.tourName = "",
    this.tourColor = "",
    this.statusDate = "",
    this.statusName = "",
    this.idStatus = "",
    this.pNew = false,
    this.packages = const {},
  });

  factory Command.fromJson(Map<String, dynamic> json) {
    var packagesFromJson = json['packages'] as List<dynamic>? ?? {};
    Map<String, Package> packagesMap = {};
    for (var value in packagesFromJson) {
      packagesMap[value['barcode']] = Package.fromJson(value);
    }

    return Command(
      cip: json['cip'] ?? "",
      id: json['id'] ?? "",
      cNumberOfPackages: json['c_number_of_packages'] ?? "",
      cCloseDate: json['close_date'] ?? "",
      cWeight: json['c_weight'] ?? "",
      cVolume: json['c_volume'] ?? "",
      cNumTransport: json['c_num_transport'] ?? "",
      tourOrder: int.parse(json['tour_order'] ?? '0'),
      idTour: json['id_tour'] ?? "",
      expDate: json['exp_date'] ?? "",
      expCode: json['exp_code'] ?? "",
      pharmacyCip: json['pharmacy_cip'] ?? "",
      pharmacyName: json['pharmacy_name'] ?? "",
      pharmacyAddress1: json['pharmacy_address1'] ?? "",
      pharmacyAddress2: json['pharmacy_address2'] ?? "",
      pharmacyAddress3: json['pharmacy_address3'] ?? "",
      pharmacyPostalCode: json['pharmacy_postal_code'] ?? "",
      pharmacyCity: json['pharmacy_city'] ?? "",
      pharmacyCountry: json['pharmacy_country'] ?? "",
      pharmacyInformations: json['pharmacy_informations'] ?? "",
      pharmacyPhone: json['pharmacy_phone'] ?? "",
      pharmacyFax: json['pharmacy_fax'] ?? "",
      pharmacyEmail: json['pharmacy_email'] ?? "",
      pharmacyLatitude: json['pharmacy_latitude'] ?? "",
      pharmacyLongitude: json['pharmacy_longitude'] ?? "",
      pharmacyQuality: json['pharmacy_quality'] ?? "",
      pharmacyFirstName: json['pharmacy_first_name'] ?? "",
      pharmacyLastName: json['pharmacy_last_name'] ?? "",
      mezTourExpCode: json['mez_tour_exp_code'] ?? "",
      mezTourExpName: json['mez_tour_exp_name'] ?? "",
      mezTourExpAddress1: json['mez_tour_exp_address1'] ?? "",
      mezTourExpAddress2: json['mez_tour_exp_address2'] ?? "",
      mezTourExpAddress3: json['mez_tour_exp_address3'] ?? "",
      mezTourExpPostalCode: json['mez_tour_exp_postal_code'] ?? "",
      mezTourExpCity: json['mez_tour_exp_city'] ?? "",
      mezTourExpCountry: json['mez_tour_exp_country'] ?? "",
      mezTourExpInformations: json['mez_tour_exp_informations'] ?? "",
      mezTourExpPhone: json['mez_tour_exp_phone'] ?? "",
      mezTourExpFax: json['mez_tour_exp_fax'] ?? "",
      mezTourExpEmail: json['mez_tour_exp_email'] ?? "",
      mezTourExpLatitude: json['mez_tour_exp_latitude'] ?? "",
      mezTourExpLongitude: json['mez_tour_exp_longitude'] ?? "",
      calculatedWeight: json['calculated_weight'] ?? "",
      calculatedPackages: json['calculated_packages'] ?? "",
      tourName: json['tour_name'] ?? "",
      tourColor: json['tour_color'] ?? "",
      statusDate: json['status_date'] ?? "",
      statusName: json['status_name'] ?? "",
      idStatus: json['id_status'] ?? "",
      pNew: json['p_new'] ?? false,
      packages: packagesMap,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> packagesJson = [];
    packages.forEach((key, package) {
      packagesJson.add(package.toJson());
    });

    return {
      'cip': cip,
      'id': id,
      'c_number_of_packages': cNumberOfPackages,
      'close_date': cCloseDate,
      'c_weight': cWeight,
      'c_volume': cVolume,
      'c_num_transport': cNumTransport,
      'tour_order': tourOrder,
      'id_tour': idTour,
      'exp_date': expDate,
      'exp_code': expCode,
      'pharmacy_cip': pharmacyCip,
      'pharmacy_name': pharmacyName,
      'pharmacy_address1': pharmacyAddress1,
      'pharmacy_address2': pharmacyAddress2,
      'pharmacy_address3': pharmacyAddress3,
      'pharmacy_postal_code': pharmacyPostalCode,
      'pharmacy_city': pharmacyCity,
      'pharmacy_country': pharmacyCountry,
      'pharmacy_informations': pharmacyInformations,
      'pharmacy_phone': pharmacyPhone,
      'pharmacy_fax': pharmacyFax,
      'pharmacy_email': pharmacyEmail,
      'pharmacy_latitude': pharmacyLatitude,
      'pharmacy_longitude': pharmacyLongitude,
      'pharmacy_quality': pharmacyQuality,
      'pharmacy_first_name': pharmacyFirstName,
      'pharmacy_last_name': pharmacyLastName,
      'mez_tour_exp_code': mezTourExpCode,
      'mez_tour_exp_name': mezTourExpName,
      'mez_tour_exp_address1': mezTourExpAddress1,
      'mez_tour_exp_address2': mezTourExpAddress2,
      'mez_tour_exp_address3': mezTourExpAddress3,
      'mez_tour_exp_postal_code': mezTourExpPostalCode,
      'mez_tour_exp_city': mezTourExpCity,
      'mez_tour_exp_country': mezTourExpCountry,
      'mez_tour_exp_informations': mezTourExpInformations,
      'mez_tour_exp_phone': mezTourExpPhone,
      'mez_tour_exp_fax': mezTourExpFax,
      'mez_tour_exp_email': mezTourExpEmail,
      'mez_tour_exp_latitude': mezTourExpLatitude,
      'mez_tour_exp_longitude': mezTourExpLongitude,
      'calculated_weight': calculatedWeight,
      'calculated_packages': calculatedPackages,
      'tour_name': tourName,
      'tour_color': tourColor,
      'status_date': statusDate,
      'status_name': statusName,
      'id_status': idStatus,
      'p_new': pNew,
      'packages': packagesJson,
    };
  }
}
