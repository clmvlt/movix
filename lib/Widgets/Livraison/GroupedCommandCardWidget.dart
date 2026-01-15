import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/CommandGroup.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/map_service.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';
import 'package:movix/Widgets/BadgeWidget.dart';
import 'package:movix/Widgets/CommandWidget.dart';
import 'package:movix/Widgets/Livraison/ModernButtonWidget.dart';

class GroupedCommandCardWidget extends StatefulWidget {
  final CommandGroup group;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback onUpdate;

  const GroupedCommandCardWidget({
    super.key,
    required this.group,
    this.isSelected = false,
    this.onTap,
    required this.onUpdate,
  });

  @override
  State<GroupedCommandCardWidget> createState() => _GroupedCommandCardWidgetState();
}

class _GroupedCommandCardWidgetState extends State<GroupedCommandCardWidget> {
  bool _isExpanded = false;

  IconData _getMapButtonIcon() {
    switch (Globals.MAP_APP) {
      case MapApp.waze:
        return FontAwesomeIcons.waze;
      case MapApp.appleMaps:
        return Icons.map;
      case MapApp.googleMaps:
        return Icons.fmd_good;
    }
  }

  @override
  Widget build(BuildContext context) {
    final command = widget.group.firstCommand;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Globals.COLOR_SURFACE
                : Globals.COLOR_SURFACE.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                  : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Header cliquable
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(command),
                      const SizedBox(height: 6),
                      customCity(command),
                    ],
                  ),
                ),
              ),
              // Contenu expandable
              if (widget.isSelected)
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Container(
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
                        // Bouton expand/collapse
                        _buildExpandButton(),
                        // Liste des commandes si expandé
                        if (_isExpanded) ...[
                          const SizedBox(height: 12),
                          _buildExpandedCommands(),
                        ],
                        const SizedBox(height: 16),
                        // Boutons d'action
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Command command) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              child: GetLivraisonIconCommandStatus(command, 20),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 80),
                child: Text(
                  command.pharmacy.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Globals.COLOR_TEXT_DARK,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Row(
            children: [
              if (command.newPharmacy) ...[
                newBadge(size: BadgeSize.small),
                const SizedBox(width: 2),
              ],
              otCountBadge(widget.group.commands.length, size: BadgeSize.small),
              const SizedBox(width: 2),
              packagesNumberBadge(widget.group.totalPackages, size: BadgeSize.small),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: Globals.COLOR_TEXT_DARK_SECONDARY,
            ),
            const SizedBox(width: 4),
            Text(
              _isExpanded
                  ? "Masquer"
                  : "${widget.group.commands.length} commandes",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Globals.COLOR_TEXT_DARK_SECONDARY,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCommands() {
    return Column(
      children: widget.group.commands.map((command) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne verticale à gauche
              Container(
                width: 4,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Globals.COLOR_MOVIX_YELLOW,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Carte de commande
              Expanded(
                child: _buildCommandCard(command),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommandCard(Command command) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            child: GetLivraisonIconCommandStatus(command, 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  command.pharmacy.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Globals.COLOR_TEXT_DARK,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${command.pharmacy.address1} ${command.pharmacy.postalCode} ${command.pharmacy.city}".trim(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Globals.COLOR_TEXT_DARK_SECONDARY,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          packagesNumberBadge(command.packages.length, size: BadgeSize.small),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final command = widget.group.firstCommand;

    return Row(
      children: [
        ModernIconButtonWidget(
          icon: _getMapButtonIcon(),
          color: Globals.COLOR_MOVIX_YELLOW,
          onPressed: () => MapService.instance.openNavigation(
            latitude: command.pharmacy.latitude,
            longitude: command.pharmacy.longitude,
          ),
        ),
        const SizedBox(width: 8),
        ModernIconButtonWidget(
          icon: FontAwesomeIcons.mapLocation,
          color: Globals.COLOR_MOVIX_GREEN,
          onPressed: () {
            context.push('/mapbox', extra: {'command': command});
          },
        ),
        const SizedBox(width: 8),
        ModernIconButtonWidget(
          icon: FontAwesomeIcons.xmark,
          color: Globals.COLOR_MOVIX_RED,
          onPressed: () {
            // Pour les anomalies sur un groupe, on utilise la première commande
            ShowLivraisonAnomalieManu(context, command, widget.onUpdate);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernActionButtonWidget(
            label: "Livrer",
            icon: FontAwesomeIcons.solidFlag,
            color: Globals.COLOR_MOVIX,
            onPressed: () {
              context.push('/tour/fslivraison', extra: {
                'commands': widget.group.commands,
                'onUpdate': widget.onUpdate,
              });
            },
            iconSize: 16,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
