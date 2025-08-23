
class Update {
  final String id;
  final String version;
  final String filePath;
  final DateTime createdAt;

  Update({
    required this.id,
    required this.version,
    required this.filePath,
    required this.createdAt,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      id: json['id'] as String,
      version: json['version'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}