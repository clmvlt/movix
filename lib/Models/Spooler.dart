import 'dart:convert';

import 'package:hive/hive.dart';

class Spooler extends HiveObject {
  final String url;
  final Map<String, String> headers;
  final Map<String, dynamic> body;
  final String? formType;

  Spooler({
    required this.url,
    required this.headers,
    required this.body,
    required this.formType,
  });

  factory Spooler.fromJson(Map<String, dynamic> json) {
    return Spooler(
      url: (json['url'] is String) ? json['url'] as String : '',
      headers: (json['headers'] is Map) ? Map<String, String>.from(json['headers'] as Map) : {},
      body: (json['body'] is Map) ? Map<String, dynamic>.from(json['body'] as Map) : {},
      formType: (json['formType'] is String) ? json['formType'] as String : 'post',
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'headers': headers,
        'body': body,
        'formType': formType,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
