import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/command_fetcher.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Common/AppBarWidget.dart';
import 'package:movix/Widgets/Livraison/ModernCardWidget.dart';

class StatusOption {
  final int id;
  final String name;

  StatusOption({required this.id, required this.name});
}

class CommandDetailPage extends StatefulWidget {
  final Command command;
  final List<Tour>? availableTours;
  final VoidCallback? onUpdate;

  const CommandDetailPage({
    super.key,
    required this.command,
    this.availableTours,
    this.onUpdate,
  });

  @override
  State<CommandDetailPage> createState() => _CommandDetailPageState();
}

class _CommandDetailPageState extends State<CommandDetailPage> {
  late Command _command;

  final List<StatusOption> _statuses = [
    StatusOption(id: 1, name: 'À enlever'),
    StatusOption(id: 2, name: 'Chargé'),
    StatusOption(id: 3, name: 'Livré'),
    StatusOption(id: 4, name: 'Non Livré'),
    StatusOption(id: 5, name: 'Livré incomplet'),
    StatusOption(id: 6, name: 'Chargé incomplet'),
    StatusOption(id: 7, name: 'Non chargé - MANQUANT'),
    StatusOption(id: 8, name: 'Non livré - Inaccessible'),
    StatusOption(id: 9, name: 'Non livré - Instructions invalides'),
  ];

  @override
  void initState() {
    super.initState();
    _command = widget.command;
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 3:
        return Globals.COLOR_MOVIX_GREEN;
      case 4:
      case 5:
      case 8:
      case 9:
        return Globals.COLOR_MOVIX_RED;
      case 2:
      case 6:
      case 7:
        return Globals.COLOR_MOVIX_YELLOW;
      default:
        return Globals.COLOR_TEXT_SECONDARY;
    }
  }

  Future<void> _toggleIsForced() async {
    // Mise à jour visuelle immédiate
    final newValue = !_command.isForced;
    setState(() {
      _command.isForced = newValue;
    });

    // Appel API en arrière-plan
    final success = await updateCommandIsForced([_command.id], newValue);

    if (success) {
      Globals.showSnackbar(
        newValue ? 'Scan CIP forcé activé' : 'Scan CIP forcé désactivé',
        icon: newValue ? Icons.check_circle_outline : Icons.cancel_outlined,
      );
      widget.onUpdate?.call();
    } else {
      // Rollback en cas d'erreur
      setState(() {
        _command.isForced = !newValue;
      });
      Globals.showSnackbar(
        'Erreur lors de la mise à jour',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _changeStatus(int newStatusId) async {
    // Sauvegarder l'ancien état pour rollback
    final oldStatusId = _command.status.id;
    final oldStatusName = _command.status.name;
    final oldStatusCreatedAt = _command.status.createdAt;

    // Mise à jour visuelle immédiate
    setState(() {
      _command.status.id = newStatusId;
      _command.status.name = _statuses.firstWhere((s) => s.id == newStatusId).name;
      _command.status.createdAt = DateTime.now().toIso8601String();
    });

    // Appel API en arrière-plan
    final success = await setCommandState(_command.id, newStatusId, isWeb: true);

    if (success) {
      Globals.showSnackbar(
        'Statut mis à jour',
        icon: Icons.check_circle_outline,
      );
      widget.onUpdate?.call();
    } else {
      // Rollback en cas d'erreur
      setState(() {
        _command.status.id = oldStatusId;
        _command.status.name = oldStatusName;
        _command.status.createdAt = oldStatusCreatedAt;
      });
      Globals.showSnackbar(
        'Erreur lors de la mise à jour du statut',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _showStatusDialog() async {
    final selectedStatus = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Globals.COLOR_SURFACE,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Changer le statut',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Globals.COLOR_TEXT_DARK,
                ),
              ),
            ),
            Divider(color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1), height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = status.id == _command.status.id;
                final statusColor = _getStatusColor(status.id);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(status.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? statusColor.withOpacity(0.1) : null,
                        border: Border(
                          bottom: BorderSide(
                            color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              status.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: Globals.COLOR_TEXT_DARK,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: statusColor, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );

    if (selectedStatus != null && selectedStatus != _command.status.id) {
      await _changeStatus(selectedStatus);
    }
  }

  Future<void> _showAssignTourDialog() async {
    String searchQuery = '';

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredTours = widget.availableTours?.where((tour) =>
            tour.name.toLowerCase().contains(searchQuery.toLowerCase())
          ).toList() ?? [];

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Gérer l\'attribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_TEXT_DARK,
                    ),
                  ),
                ),

                // Bouton Désassigner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop('unassign'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Globals.COLOR_MOVIX_RED.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_circle_outline,
                              color: Globals.COLOR_MOVIX_RED,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Désassigner de la tournée',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Globals.COLOR_MOVIX_RED,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Séparateur avec texte
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou attribuer à',
                          style: TextStyle(
                            fontSize: 13,
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Barre de recherche
                if (widget.availableTours != null && widget.availableTours!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        onChanged: (value) => setModalState(() => searchQuery = value),
                        style: TextStyle(
                          fontSize: 15,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une tournée...',
                          hintStyle: TextStyle(
                            color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.6),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Globals.COLOR_TEXT_SECONDARY,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                Divider(color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1), height: 1),

                // Liste des tournées
                if (widget.availableTours == null || widget.availableTours!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Globals.COLOR_TEXT_SECONDARY,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune autre tournée disponible',
                          style: TextStyle(
                            fontSize: 15,
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (filteredTours.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Globals.COLOR_TEXT_SECONDARY,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune tournée trouvée',
                          style: TextStyle(
                            fontSize: 15,
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredTours.length,
                      itemBuilder: (context, index) {
                        final tour = filteredTours[index];
                        final tourColor = Color(int.parse("0xff${tour.color.substring(1)}"));

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(tour.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: tourColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tour.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Globals.COLOR_TEXT_DARK,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tour.profil.firstName.isNotEmpty || tour.profil.lastName.isNotEmpty
                                              ? '${tour.profil.firstName} ${tour.profil.lastName}'
                                              : 'Non attribué',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Globals.COLOR_TEXT_SECONDARY,
                                            fontStyle: tour.profil.firstName.isEmpty && tour.profil.lastName.isEmpty
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: tourColor,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          );
        },
      ),
    );

    if (result == 'unassign') {
      await _performUnassign();
    } else if (result != null && result is String) {
      await _assignToTour(result);
    }
  }

  Future<void> _performUnassign() async {
    // Fermer la page immédiatement (optimiste)
    Globals.showSnackbar(
      'Commande désassignée',
      icon: Icons.check_circle_outline,
    );
    widget.onUpdate?.call();
    if (mounted) {
      context.pop();
    }

    // Appel API en arrière-plan
    final success = await unassignCommands([_command.id]);

    if (!success) {
      Globals.showSnackbar(
        'Erreur lors de la désassignation',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _assignToTour(String tourId) async {
    final tourName = widget.availableTours?.firstWhere((t) => t.id == tourId).name ?? 'la tournée';

    // Fermer la page immédiatement (optimiste)
    Globals.showSnackbar(
      'Commande assignée à $tourName',
      icon: Icons.check_circle_outline,
    );
    widget.onUpdate?.call();
    if (mounted) {
      context.pop();
    }

    // Appel API en arrière-plan
    final success = await assignCommandsToTour(tourId, [_command.id]);

    if (!success) {
      Globals.showSnackbar(
        'Erreur lors de l\'assignation',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusTime = _command.status.createdAt.isNotEmpty
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(_command.status.createdAt))
        : '';

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: CustomAppBarWidget(
          title: 'Détail commande',
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte Pharmacie
                    ModernCardWidget(
                      padding: const EdgeInsets.all(20),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ModernCardHeader(
                            icon: Icons.local_pharmacy_outlined,
                            iconColor: Globals.COLOR_ADAPTIVE_ACCENT,
                            title: _command.pharmacy.name,
                            subtitle: 'CIP: ${_command.pharmacy.cip}',
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(Icons.location_on_outlined,
                              "${_command.pharmacy.address1} ${_command.pharmacy.address2} ${_command.pharmacy.address3}".trim()),
                          const SizedBox(height: 10),
                          _buildInfoRow(Icons.pin_drop_outlined,
                              "${_command.pharmacy.postalCode} ${_command.pharmacy.city}"),
                          if (_command.pharmacy.phone.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.phone_outlined, _command.pharmacy.phone),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Carte Statut
                    ModernCardWidget(
                      padding: const EdgeInsets.all(20),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: GetLivraisonIconCommandStatus(_command, 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Statut actuel',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Globals.COLOR_TEXT_SECONDARY,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _command.status.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(_command.status.id),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.15),
                                      Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_command.packages.length} colis',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Globals.COLOR_ADAPTIVE_ACCENT,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (statusTime.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Globals.COLOR_TEXT_SECONDARY,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    statusTime,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Globals.COLOR_TEXT_SECONDARY,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Boutons d'action
                    _buildActionTile(
                      icon: Icons.sync_alt,
                      label: 'Changer le statut',
                      subtitle: _command.status.name,
                      color: _getStatusColor(_command.status.id),
                      onTap: _showStatusDialog,
                    ),

                    _buildActionTile(
                      icon: _command.isForced ? Icons.check_box : Icons.check_box_outline_blank,
                      label: 'Forcer le scan CIP',
                      subtitle: _command.isForced ? 'Activé' : 'Désactivé',
                      color: _command.isForced ? Globals.COLOR_MOVIX_GREEN : Globals.COLOR_TEXT_SECONDARY,
                      onTap: _toggleIsForced,
                    ),

                    _buildActionTile(
                      icon: Icons.swap_horiz,
                      label: 'Gérer l\'attribution',
                      subtitle: widget.availableTours != null && widget.availableTours!.isNotEmpty
                          ? '${widget.availableTours!.length} tournées disponibles'
                          : 'Désassigner de la tournée',
                      color: Globals.COLOR_ADAPTIVE_ACCENT,
                      onTap: _showAssignTourDialog,
                    ),

                    const SizedBox(height: 20),

                    // Liste des colis
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Colis (${_command.packages.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._command.packages.values.map((pkg) => _buildPackageCard(pkg)),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Globals.COLOR_TEXT_SECONDARY,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Globals.COLOR_TEXT_DARK,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(Package pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.15),
                  Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: Globals.COLOR_ADAPTIVE_ACCENT,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.type,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Globals.COLOR_TEXT_DARK,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pkg.barcode,
                  style: TextStyle(
                    fontSize: 12,
                    color: Globals.COLOR_TEXT_SECONDARY,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(pkg.status.id).withOpacity(0.15),
                  _getStatusColor(pkg.status.id).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              pkg.status.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(pkg.status.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
