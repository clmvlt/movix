import 'package:flutter/material.dart';
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
          ? status != 7
          : (status == 1 || status == 2 || status == 6)) {
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
      if (command.status.id != 7) {
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
