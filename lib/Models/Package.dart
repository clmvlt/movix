class Package {
  String type;
  String designation;
  String quantity;
  String weight;
  String volume;
  String length;
  String width;
  String height;
  String barcode;
  String fresh;
  String statusName;
  String statusDate;
  String idStatus;
  String idCommand;
  String zoneName;

  Package({
    required this.type,
    required this.designation,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.length,
    required this.width,
    required this.height,
    required this.barcode,
    required this.fresh,
    required this.statusName,
    required this.statusDate,
    required this.idStatus,
    required this.idCommand,
    required this.zoneName,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      type: json['type'] ?? "",
      designation: json['designation'] ?? "",
      quantity: json['quantity'] ?? "",
      weight: json['weight'] ?? "",
      volume: json['volume'] ?? "",
      length: json['length'] ?? "",
      width: json['width'] ?? "",
      height: json['height'] ?? "",
      barcode: json['barcode'] ?? "",
      fresh: json['fresh'] ?? "",
      statusName: json['status_name'] ?? "",
      statusDate: json['status_date'] ?? "",
      idStatus: json['id_status'] ?? "",
      idCommand: json['id_command'] ?? "",
      zoneName: json['zone_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'designation': designation,
      'quantity': quantity,
      'weight': weight,
      'volume': volume,
      'length': length,
      'width': width,
      'height': height,
      'barcode': barcode,
      'fresh': fresh,
      'status_name': statusName,
      'status_date': statusDate,
      'id_status': idStatus,
      'id_command': idCommand,
      'zone_name': zoneName
    };
  }
}
