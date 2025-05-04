class Spooler {
  final String url;
  final Map<String, String> headers;
  final dynamic body;

  Spooler({required this.url, required this.headers, required this.body});

  Map<String, dynamic> toJson() => {
        "url": url,
        "headers": headers,
        "body": body,
      };

  factory Spooler.fromJson(Map<String, dynamic> json) {
    return Spooler(
      url: json["url"],
      headers: Map<String, String>.from(json["headers"] ?? {}),
      body: json["body"],
    );
  }
}