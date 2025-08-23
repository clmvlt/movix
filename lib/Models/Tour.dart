import 'Command.dart';
import 'Profil.dart';
import 'Status.dart';

class Tour {
  String id;
  String tourId;
  String name;
  String immat;
  int startKm;
  int endKm;
  String initialDate;
  String startDate;
  String endDate;
  String color;
  double estimateMins;
  double estimateKm;
  String geometry;
  Profil profil;
  Status status;
  Map<String, Command> commands;

  Tour({
    required this.id,
    this.tourId = '',
    required this.name,
    required this.immat,
    required this.startKm,
    required this.endKm,
    required this.initialDate,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.estimateMins,
    required this.estimateKm,
    required this.geometry,
    required this.profil,
    required this.status,
    required this.commands,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    Map<String, Command> commandsMap = {};
    if (json['commands'] != null && json['commands'] is List) {
      final commandsList = json['commands'] as List;
      for (var command in commandsList) {
        if (command is Map<String, dynamic>) {
          command['tourId'] = json['id'];
          if (command['id'] is String) {
            commandsMap[command['id'] as String] = Command.fromJson(command);
          }
        }
      }
    }

    return Tour(
      id: (json['id'] is String) ? json['id'] as String : '',
      tourId: (json['tourId'] is String) ? json['tourId'] as String : '',
      name: (json['name'] is String) ? json['name'] as String : '',
      immat: (json['immat'] is String) ? json['immat'] as String : '',
      startKm: (json['startKm'] is int) ? json['startKm'] as int : 0,
      endKm: (json['endKm'] is int) ? json['endKm'] as int : 0,
      initialDate: (json['initialDate'] is String) ? json['initialDate'] as String : '',
      startDate: (json['startDate'] is String) ? json['startDate'] as String : '',
      endDate: (json['endDate'] is String) ? json['endDate'] as String : '',
      color: (json['color'] is String) ? json['color'] as String : '',
      estimateMins: (json['estimateMins'] is double) ? json['estimateMins'] as double : 0.0,
      estimateKm: (json['estimateKm'] is double) ? json['estimateKm'] as double : 0.0,
      geometry: (json['geometry'] is String) ? json['geometry'] as String : '',
      profil: Profil.fromJson(json['profil'] is Map<String, dynamic> ? json['profil'] as Map<String, dynamic> : {}),
      status: Status.fromJson(json['status'] is Map<String, dynamic> ? json['status'] as Map<String, dynamic> : {}),
      commands: commandsMap,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> commandsList = [];
    commands.forEach((id, command) {
      commandsList.add(command.toJson());
    });

    return {
      'id': id,
      'tourId': tourId,
      'name': name,
      'immat': immat,
      'startKm': startKm,
      'endKm': endKm,
      'initialDate': initialDate,
      'startDate': startDate,
      'endDate': endDate,
      'color': color,
      'estimateMins': estimateMins,
      'estimateKm': estimateKm,
      'geometry': geometry,
      'profil': profil.toJson(),
      'status': status.toJson(),
      'commands': commandsList,
    };
  }
}
