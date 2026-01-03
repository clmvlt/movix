import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
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
  Map<String, Command> commands = {};
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

  void _updateCommands() {
    final isShowEnded = Globals.showEnded;

    final filteredMap = <String, Command>{};

    widget.tour.commands.forEach((key, command) {
      final status = command.status.id;
      if (isShowEnded
          ? true  // Afficher toutes les commandes quand showEnded est true
          : (status != 7 && status != 5 && status != 3 && status != 4)) {  // Masquer 5, 6, 7 quand showEnded est false
        filteredMap[key] = command;
      }
    });

    final sortedEntries = filteredMap.entries.toList()
      ..sort((a, b) => a.value.tourOrder.compareTo(b.value.tourOrder));

    commands = {
      for (final entry in sortedEntries) entry.key: entry.value,
      'depot': Command(id: 'depot'),
    };

    // Initialize animations for each command
    for (var command in commands.values) {
      if (!_cardAnimations.containsKey(command.id)) {
        _cardAnimations[command.id] = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
      }
    }

    for (var command in commands.values) {
      if (command.status.id != 7 && command.status.id != 5 && command.status.id != 3 && command.status.id != 4) {
        selectedId = command.id;
        break;
      }
    }

    setState(() {});
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
          itemCount: commands.length,
          itemBuilder: (context, index) {
            final key = commands.keys.elementAt(index);
            final command = commands[key]!;
            final isSelected = command.id == selectedId;

            // Trigger animations
            if (isSelected) {
              _cardAnimations[command.id]?.forward();
            } else {
              _cardAnimations[command.id]?.reverse();
            }

            if (command.id == 'depot') {
              return DepotCardWidget(
                command: command,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (selectedId == command.id) {
                      selectedId = "";
                    } else {
                      selectedId = command.id;
                    }
                  });
                },
                tour: widget.tour,
                onUpdate: onUpdate,
              );
            }

            return ModernCommandCardWidget(
              command: command,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (selectedId == command.id) {
                    selectedId = "";
                  } else {
                    selectedId = command.id;
                  }
                });
              },
              expandedContent: LivraisonActionsWidget(
                command: command,
                onUpdate: onUpdate,
              ),
            );
          },
        ),
    );
  }
}
