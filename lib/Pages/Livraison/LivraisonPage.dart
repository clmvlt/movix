import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/CommandGroup.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Livraison/GroupedCommandCardWidget.dart';
import 'package:movix/Widgets/Livraison/index.dart';

class LivraisonPage extends StatefulWidget {
  final Tour tour;

  const LivraisonPage({super.key, required this.tour});

  @override
  _LivraisonPage createState() => _LivraisonPage();
}

class _LivraisonPage extends State<LivraisonPage> with TickerProviderStateMixin {
  late String selectedId = 'depot';
  bool validationLoading = false;
  final ScrollController _scrollController = ScrollController();
  List<CommandGroup> commandGroups = [];
  final Map<String, AnimationController> _cardAnimations = {};

  void onUpdate() {
    _updateCommands();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _updateCommands();
    _checkStartKm();
  }

  Future<void> _checkStartKm() async {
    await Future<void>.delayed(Duration.zero);

    // Si les startKm ne sont pas renseignés, demander obligatoirement
    if (widget.tour.startKm == 0) {
      int? startKm = await askForKilometers(context, allowSkip: false);
      if (startKm != null && startKm > 0) {
        await setTourData(widget.tour.id, {"startKm": startKm});
        widget.tour.startKm = startKm;
        await saveToursToHive();
      } else if (startKm == null) {
        // L'utilisateur a cliqué sur "Fermer", retour à la page des tournées
        if (mounted) {
          context.pop();
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _cardAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Regroupe les commandes consécutives ayant le même CIP
  List<CommandGroup> _groupCommandsByCIP(List<Command> sortedCommands) {
    List<CommandGroup> groups = [];
    List<Command> currentGroup = [];
    String? currentCIP;

    for (var command in sortedCommands) {
      if (currentCIP == null || command.pharmacy.cip == currentCIP) {
        currentGroup.add(command);
        currentCIP = command.pharmacy.cip;
      } else {
        groups.add(CommandGroup(commands: List.from(currentGroup)));
        currentGroup = [command];
        currentCIP = command.pharmacy.cip;
      }
    }

    if (currentGroup.isNotEmpty) {
      groups.add(CommandGroup(commands: List.from(currentGroup)));
    }

    return groups;
  }

  void _updateCommands() {
    final isShowEnded = Globals.showEnded;

    final filteredList = <Command>[];

    widget.tour.commands.forEach((key, command) {
      final status = command.status.id;
      if (isShowEnded
          ? true  // Afficher toutes les commandes quand showEnded est true
          : (status != 7 && status != 5 && status != 3 && status != 4)) {  // Masquer 5, 6, 7 quand showEnded est false
        filteredList.add(command);
      }
    });

    // Trier par tourOrder
    filteredList.sort((a, b) => a.tourOrder.compareTo(b.tourOrder));

    // Regrouper par CIP consécutif
    commandGroups = _groupCommandsByCIP(filteredList);

    // Ajouter le depot à la fin comme un groupe spécial
    commandGroups.add(CommandGroup(commands: [Command(id: 'depot')]));

    // Initialize animations for each group
    for (var group in commandGroups) {
      final groupId = _getGroupId(group);
      if (!_cardAnimations.containsKey(groupId)) {
        _cardAnimations[groupId] = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
      }
    }

    // Sélectionner le premier groupe non terminé
    for (var group in commandGroups) {
      final firstCommand = group.firstCommand;
      if (firstCommand.id != 'depot' &&
          firstCommand.status.id != 7 &&
          firstCommand.status.id != 5 &&
          firstCommand.status.id != 3 &&
          firstCommand.status.id != 4) {
        selectedId = _getGroupId(group);
        break;
      }
    }

    setState(() {});
  }

  /// Génère un ID unique pour un groupe basé sur les IDs des commandes
  String _getGroupId(CommandGroup group) {
    return group.commands.map((c) => c.id).join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: LivraisonAppBarWidget(
        tour: widget.tour,
        onShowEndedChanged: _updateCommands,
      ),
      body: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 8, bottom: 120, left: 8, right: 8),
          itemCount: commandGroups.length,
          itemBuilder: (context, index) {
            final group = commandGroups[index];
            final groupId = _getGroupId(group);
            final isSelected = groupId == selectedId;

            // Trigger animations
            if (isSelected) {
              _cardAnimations[groupId]?.forward();
            } else {
              _cardAnimations[groupId]?.reverse();
            }

            // Depot card
            if (group.firstCommand.id == 'depot') {
              return DepotCardWidget(
                command: group.firstCommand,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (selectedId == groupId) {
                      selectedId = "";
                    } else {
                      selectedId = groupId;
                    }
                  });
                },
                tour: widget.tour,
                onUpdate: onUpdate,
              );
            }

            // Groupe avec plusieurs commandes
            if (group.isGroup) {
              return GroupedCommandCardWidget(
                group: group,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (selectedId == groupId) {
                      selectedId = "";
                    } else {
                      selectedId = groupId;
                    }
                  });
                },
                onUpdate: onUpdate,
              );
            }

            // Commande simple (pas de groupe)
            return ModernCommandCardWidget(
              command: group.firstCommand,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (selectedId == groupId) {
                    selectedId = "";
                  } else {
                    selectedId = groupId;
                  }
                });
              },
              expandedContent: LivraisonActionsWidget(
                command: group.firstCommand,
                onUpdate: onUpdate,
              ),
            );
          },
        ),
    );
  }
}
