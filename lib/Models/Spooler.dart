import 'package:hive/hive.dart';

part 'Spooler.g.dart';

@HiveType(typeId: 0)
class Spooler extends HiveObject {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final Map<String, String> headers;

  @HiveField(2)
  final Map<String, dynamic> body;

  Spooler({
    required this.url,
    required this.headers,
    required this.body,
  });

  factory Spooler.fromJson(Map<String, dynamic> json) {
    return Spooler(
      url: json['url'],
      headers: Map<String, String>.from(json['headers'] ?? {}),
      body: Map<String, dynamic>.from(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'headers': headers,
        'body': body,
      };
}
