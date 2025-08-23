import 'Status.dart';

class Package {
  String type;
  String designation;
  int quantity;
  double weight;
  double volume;
  double length;
  double width;
  double height;
  String barcode;
  bool fresh;
  String num;
  String zoneName;
  String labelUrl;
  String cnumTransport;
  Status status;
  String id;
  String commandId;

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
    required this.num,
    required this.zoneName,
    required this.labelUrl,
    required this.cnumTransport,
    required this.status,
    required this.id,
    required this.commandId,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      type: (json['type'] is String) ? json['type'] as String : '',
      designation: (json['designation'] is String) ? json['designation'] as String : '',
      quantity: (json['quantity'] is int) ? json['quantity'] as int : 0,
      weight: (json['weight'] is double) ? json['weight'] as double : 0.0,
      volume: (json['volume'] is double) ? json['volume'] as double : 0.0,
      length: (json['length'] is double) ? json['length'] as double : 0.0,
      width: (json['width'] is double) ? json['width'] as double : 0.0,
      height: (json['height'] is double) ? json['height'] as double : 0.0,
      barcode: (json['barcode'] is String) ? json['barcode'] as String : '',
      fresh: (json['fresh'] is bool) ? json['fresh'] as bool : false,
      num: (json['num'] is String) ? json['num'] as String : '',
      zoneName: (json['zoneName'] is String) ? json['zoneName'] as String : '',
      labelUrl: (json['labelUrl'] is String) ? json['labelUrl'] as String : '',
      cnumTransport: (json['cnumTransport'] is String) ? json['cnumTransport'] as String : '',
      status: Status.fromJson(json['status'] is Map<String, dynamic> ? json['status'] as Map<String, dynamic> : {}),
      id: (json['id'] is String) ? json['id'] as String : '',
      commandId: (json['commandId'] is String) ? json['commandId'] as String : '',
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
      'num': num,
      'zoneName': zoneName,
      'labelUrl': labelUrl,
      'cnumTransport': cnumTransport,
      'status': status.toJson(),
      'id': id,
      'commandId': commandId,
    };
  }
}
