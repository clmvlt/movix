import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';

class LivraisonPage extends StatefulWidget {
  final Tour tour;

  const LivraisonPage({super.key, required this.tour});

  @override
  _LivraisonPage createState() => _LivraisonPage();
}

class _LivraisonPage extends State<LivraisonPage> {
  late String selectedId = 'depot';
  bool validationLoading = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, Command> commands = {};

  void onUpdate() {
    _updateCommands();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _updateCommands();
  }

  void _updateCommands() {
    final isShowEnded = Globals.showEnded;

    final filteredMap = <String, Command>{};

    widget.tour.commands.forEach((key, command) {
      final status = command.idStatus;
      if (isShowEnded
          ? status != "7"
          : (status == "1" || status == "2" || status == "6")) {
        filteredMap[key] = command;
      }
    });

    final sortedEntries = filteredMap.entries.toList()
      ..sort((a, b) => a.value.tourOrder.compareTo(b.value.tourOrder));

    commands = {
      for (final entry in sortedEntries) entry.key: entry.value,
      'depot': Command(id: 'depot'),
    };

    for (var command in commands.values) {
      if (command.idStatus != '7') {
        selectedId = command.id;
        break;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(widget.tour.name),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/tours');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              '${countValidCommands(widget.tour)}/${countTotalCommands(widget.tour)}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'spooler') {
                context.push('/spooler');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            Globals.showEnded = !Globals.showEnded;
                            _updateCommands();
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Globals.showEnded
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Globals.COLOR_MOVIX,
                            ),
                            const SizedBox(width: 10),
                            const Text('Afficher les terminés'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'spooler',
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, color: Globals.COLOR_MOVIX),
                      SizedBox(width: 10),
                      Text('Voir le spooler'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final key = commands.keys.elementAt(index);
                  final command = commands[key]!;
                  final isSelected = command.id == selectedId;

                  if (command.id == 'depot') {
                    return buildDepotCard(command, isSelected, index);
                  }

                  return buildLivraisonCard(command, isSelected, index);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDepotCard(Command command, bool isSelected, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: isSelected ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.grey[300],
          onTap: () {
            setState(() {
              selectedId = command.id;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home_work,
                        size: 24, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Globals.profil!.societe,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${Globals.profil!.address1} ${Globals.profil!.address2}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 70),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: isSelected
                      ? buildDepotActions(command)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDepotActions(Command command) {
    return Column(
      key: const ValueKey("depot_actions"),
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (Globals.MAP_APP == "Waze")
              customRoundIconButton(
                  iconData: FontAwesomeIcons.waze,
                  color: Globals.COLOR_MOVIX_YELLOW,
                  onPressed: () => openMap(
                      latitude: Globals.profil?.latitude,
                      longitude: Globals.profil?.longitude)),
            if (Globals.MAP_APP == "Google Maps")
              customRoundIconButton(
                iconData: Icons.fmd_good,
                color: Globals.COLOR_MOVIX_YELLOW,
                onPressed: () => openMap(
                    latitude: Globals.profil?.latitude,
                    longitude: Globals.profil?.longitude),
              ),
            validationLoading
                ? const Center(child: CircularProgressIndicator())
                : customToolButton(
                    iconData: FontAwesomeIcons.flagCheckered,
                    text: "Valider",
                    color: Globals.COLOR_MOVIX,
                    onPressed: () async {
                      if (isTourComplet(widget.tour)) {
                        setState(() {
                          validationLoading = true;
                        });
                        await ValidLivraisonTour(
                            context, widget.tour, onUpdate);
                        setState(() {
                          validationLoading = false;
                        });
                      } else {
                        Globals.showSnackbar(
                          'Merci de renseigner toutes les positions.',
                          backgroundColor: Globals.COLOR_MOVIX_RED,
                        );
                      }
                    },
                  ),
          ],
        ),
      ],
    );
  }

  Widget buildLivraisonCard(Command command, bool isSelected, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: isSelected ? Colors.white : const Color.fromARGB(255, 240, 240, 240),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.grey[300],
          onTap: () {
            setState(() {
              selectedId = command.id;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GetLivraisonIconCommandStatus(command, 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        command.pharmacyName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (command.pNew) ...[
                      newBadge(),
                    ],
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "${command.packages.length} 📦",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${command.pharmacyAddress1} ${command.pharmacyAddress2} ${command.pharmacyAddress3}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                Text(
                  command.pharmacyCity,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 70),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: isSelected
                      ? buildLivraisonActions(command)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLivraisonActions(Command command) {
    return Column(
      key: ValueKey("actions_${command.id}"),
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (Globals.MAP_APP == "Waze")
              customRoundIconButton(
                  iconData: FontAwesomeIcons.waze,
                  color: Globals.COLOR_MOVIX_YELLOW,
                  onPressed: () => openMap(command: command)),
            if (Globals.MAP_APP == "Google Maps")
              customRoundIconButton(
                iconData: Icons.fmd_good,
                color: Globals.COLOR_MOVIX_YELLOW,
                onPressed: () => openMap(command: command),
              ),
            customRoundIconButton(
              iconData: FontAwesomeIcons.mapLocation,
              color: Globals.COLOR_MOVIX_GREEN,
              onPressed: () {
                context.push('/mapbox', extra: {'command': command});
              },
            ),
            customRoundIconButton(
              iconData: FontAwesomeIcons.xmark,
              color: Globals.COLOR_MOVIX_RED,
              onPressed: () {
                ShowLivraisonAnomalieManu(context, command, onUpdate);
              },
            ),
            customToolButton(
              iconData: FontAwesomeIcons.solidFlag,
              text: "Livrer",
              color: Globals.COLOR_MOVIX,
              onPressed: () {
                context.push('/tour/fslivraison', extra: {
                  'command': command,
                  'onUpdate': onUpdate,
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
