import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';

class CommandGroup {
  final List<Command> commands;

  CommandGroup({required this.commands});

  /// CIP de la pharmacie (identique pour toutes les commandes du groupe)
  String get cip => commands.first.pharmacy.cip;

  /// Première commande du groupe (utilisée pour les infos pharmacie)
  Command get firstCommand => commands.first;

  /// Indique si c'est un groupe (plus d'une commande)
  bool get isGroup => commands.length > 1;

  /// Nombre total de colis dans le groupe
  int get totalPackages => commands.fold(0, (sum, cmd) => sum + cmd.packages.length);

  /// Tous les colis de toutes les commandes (clé = barcode)
  Map<String, Package> get allPackages {
    final Map<String, Package> packages = {};
    for (final command in commands) {
      packages.addAll(command.packages);
    }
    return packages;
  }

  /// Vérifie si tous les colis de toutes les commandes sont scannés (status 3)
  bool get isAllScanned {
    for (final command in commands) {
      for (final package in command.packages.values) {
        if (package.status.id != 3) return false;
      }
    }
    return true;
  }

  /// Vérifie si toutes les commandes sont valides (status 3, 4, 5, 6)
  bool get isValid {
    for (final command in commands) {
      for (final package in command.packages.values) {
        final s = package.status.id;
        if (s != 3 && s != 4 && s != 5 && s != 6) return false;
      }
    }
    return true;
  }

  /// Trouve un colis par son barcode dans toutes les commandes
  /// Retourne un tuple (Command, Package) ou null si non trouvé
  (Command, Package)? findPackage(String barcode) {
    for (final command in commands) {
      final package = command.packages[barcode];
      if (package != null) {
        return (command, package);
      }
    }
    return null;
  }
}
