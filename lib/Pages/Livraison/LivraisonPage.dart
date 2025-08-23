import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';
import 'package:movix/Widgets/CommandWidget.dart';

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
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tour.name,
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              'Livraison en cours',
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () {
            context.go('/tours');
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${countValidCommands(widget.tour)}/${countTotalCommands(widget.tour)}',
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert, 
                color: Globals.COLOR_TEXT_LIGHT,
                size: 20,
              ),
            ),
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 8),
            onSelected: (value) {
              if (value == 'spooler') {
                context.push('/spooler');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Globals.COLOR_SURFACE,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Globals.showEnded = !Globals.showEnded;
                                    _updateCommands();
                                  });
                                },
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Globals.COLOR_MOVIX.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Globals.showEnded
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Globals.COLOR_MOVIX,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Globals.showEnded ? 'Masquer les terminés' : 'Afficher les terminés',
                                              style: TextStyle(
                                                color: Globals.COLOR_TEXT_DARK,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              Globals.showEnded 
                                                ? 'Afficher seulement les actifs' 
                                                : 'Voir toutes les commandes',
                                              style: TextStyle(
                                                color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Globals.showEnded 
                                            ? Globals.COLOR_MOVIX_GREEN.withOpacity(0.2)
                                            : Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Globals.showEnded
                                              ? Icons.check
                                              : Icons.check_box_outline_blank,
                                          color: Globals.showEnded 
                                            ? Globals.COLOR_MOVIX_GREEN
                                            : Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          height: 1,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/spooler');
                            },
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.clockRotateLeft,
                                      color: Globals.COLOR_MOVIX_YELLOW,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Voir le spooler',
                                          style: TextStyle(
                                            color: Globals.COLOR_TEXT_DARK,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Gérer les tâches en attente',
                                          style: TextStyle(
                                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Globals.COLOR_TEXT_DARK.withOpacity(0.3),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
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
              return _buildModernDepotCard(command, isSelected, index);
            }

            return _buildModernLivraisonCard(command, isSelected, index);
          },
        ),
    );
  }

  Widget _buildModernDepotCard(Command command, bool isSelected, int index) {
    return AnimatedBuilder(
      animation: _cardAnimations[command.id]!,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  if (selectedId == command.id) {
                    selectedId = "";
                  } else {
                    selectedId = command.id;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Globals.COLOR_SURFACE 
                      : Globals.COLOR_SURFACE.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                        : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.home_work,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Globals.profil!.account.societe,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Globals.COLOR_TEXT_DARK,
                                        letterSpacing: -0.3,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${Globals.profil!.account.address1} ${Globals.profil!.account.address2}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Globals.COLOR_TEXT_DARK_SECONDARY,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: isSelected
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              decoration: BoxDecoration(
                                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  _buildModernDepotActions(command),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernLivraisonCard(Command command, bool isSelected, int index) {
    return AnimatedBuilder(
      animation: _cardAnimations[command.id]!,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  if (selectedId == command.id) {
                    selectedId = "";
                  } else {
                    selectedId = command.id;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Globals.COLOR_SURFACE 
                      : Globals.COLOR_SURFACE.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                        : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    customCardHeader(command, true, false),
                                    const SizedBox(height: 6),
                                    customCity(command),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: isSelected
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              decoration: BoxDecoration(
                                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  _buildModernLivraisonActions(command),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernDepotActions(Command command) {
    return Row(
      children: [
        if (Globals.MAP_APP == "Waze")
          Expanded(
            child: _buildModernActionButton(
              label: "Waze",
              icon: FontAwesomeIcons.waze,
              color: Globals.COLOR_MOVIX_YELLOW,
              onPressed: () => openMap(
                latitude: Globals.profil?.account.latitude,
                longitude: Globals.profil?.account.longitude),
            ),
          ),
        if (Globals.MAP_APP == "Google Maps")
          Expanded(
            child: _buildModernActionButton(
              label: "Maps",
              icon: Icons.fmd_good,
              color: Globals.COLOR_MOVIX_YELLOW,
              onPressed: () => openMap(
                latitude: Globals.profil?.account.latitude,
                longitude: Globals.profil?.account.longitude),
            ),
          ),
        if (Globals.MAP_APP == "Waze" || Globals.MAP_APP == "Google Maps")
          const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: validationLoading
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : _buildModernActionButton(
                  label: "Valider",
                  icon: FontAwesomeIcons.flagCheckered,
                  color: Globals.COLOR_MOVIX,
                  onPressed: () async {
                    if (isTourComplet(widget.tour)) {
                      setState(() {
                        validationLoading = true;
                      });
                      await ValidLivraisonTour(context, widget.tour, onUpdate);
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
        ),
      ],
    );
  }

  Widget _buildModernLivraisonActions(Command command) {
    return Row(
      children: [
        if (Globals.MAP_APP == "Waze")
          _buildModernIconButton(
            icon: FontAwesomeIcons.waze,
            color: Globals.COLOR_MOVIX_YELLOW,
            onPressed: () => openMap(command: command),
          ),
        if (Globals.MAP_APP == "Google Maps")
          _buildModernIconButton(
            icon: Icons.fmd_good,
            color: Globals.COLOR_MOVIX_YELLOW,
            onPressed: () => openMap(command: command),
          ),
        if (Globals.MAP_APP == "Waze" || Globals.MAP_APP == "Google Maps")
          const SizedBox(width: 8),
        _buildModernIconButton(
          icon: FontAwesomeIcons.mapLocation,
          color: Globals.COLOR_MOVIX_GREEN,
          onPressed: () {
            context.push('/mapbox', extra: {'command': command});
          },
        ),
        const SizedBox(width: 8),
        _buildModernIconButton(
          icon: FontAwesomeIcons.xmark,
          color: Globals.COLOR_MOVIX_RED,
          onPressed: () {
            ShowLivraisonAnomalieManu(context, command, onUpdate);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModernActionButton(
            label: "Livrer",
            icon: FontAwesomeIcons.solidFlag,
            color: Globals.COLOR_MOVIX,
            onPressed: () {
              context.push('/tour/fslivraison', extra: {
                'command': command,
                'onUpdate': onUpdate,
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double fontSize = 12,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildModernIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          minimumSize: const Size(48, 48),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }



}
