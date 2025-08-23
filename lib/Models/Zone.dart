class Zone {
  String id;
  String name;

  Zone({
    required this.id,
    required this.name,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String? ?? '',
      name: (json['name'] is String) ? json['name'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
} 