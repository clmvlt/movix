import 'Command.dart';

class Tour {
  String id;
  String name;
  String immat;
  String startKm;
  String endKm;
  String initialDate;
  String startDate;
  String endDate;
  String deliveryMode;
  String totalKm;
  String color;
  String idAccount;
  String idProfil;
  String idStatus;
  Map<String, Command> commands;

  Tour({
    this.id = "",
    this.name = "",
    this.immat = "",
    this.startKm = "",
    this.endKm = "",
    this.initialDate = "",
    this.startDate = "",
    this.endDate = "",
    this.deliveryMode = "",
    this.totalKm = "",
    this.color = "",
    this.idAccount = "",
    this.idProfil = "",
    this.idStatus = "",
    this.commands = const {},
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    Map<String, Command> commandMap = {};

    if (json['commands'] != null && json['commands'] is List<dynamic>) {
      json['commands'].forEach((value) {
        commandMap[value['id']] = Command.fromJson(value);
      });
    }

    return Tour(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      immat: json['immat'] ?? "",
      startKm: json['startkm'] ?? "",
      endKm: json['endkm'] ?? "",
      initialDate: json['initial_date'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      deliveryMode: json['delivery_mode'] ?? "",
      totalKm: json['totalkm'] ?? "",
      color: json['color'] ?? "",
      idAccount: json['id_account'] ?? "",
      idProfil: json['id_profil'] ?? "",
      idStatus: json['id_status'] ?? "",
      commands: commandMap,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> commandsJson = [];
    commands.forEach((key, command) {
      commandsJson.add(command.toJson());
    });

    return {
      'id': id,
      'name': name,
      'immat': immat,
      'startkm': startKm,
      'endkm': endKm,
      'initial_date': initialDate,
      'start_date': startDate,
      'end_date': endDate,
      'delivery_mode': deliveryMode,
      'totalkm': totalKm,
      'color': color,
      'id_account': idAccount,
      'id_profil': idProfil,
      'id_status': idStatus,
      'commands': commandsJson,
    };
  }
}
