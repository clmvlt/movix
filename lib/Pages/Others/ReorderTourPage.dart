import 'package:flutter/material.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';

class ReorderTourPage extends StatefulWidget {
  final Tour tour;
  final VoidCallback? onOrderChanged;

  const ReorderTourPage({super.key, required this.tour, this.onOrderChanged});

  @override
  State<ReorderTourPage> createState() => _ReorderTourPageState();
}

class _ReorderTourPageState extends State<ReorderTourPage> {
  late List<Command> _editableCommands;
  late List<String> _originalOrder;
  bool _isSaving = false;

  bool get _hasChanges {
    if (_editableCommands.length != _originalOrder.length) return true;
    for (int i = 0; i < _editableCommands.length; i++) {
      if (_editableCommands[i].id != _originalOrder[i]) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final commands = widget.tour.commands.values.toList()
      ..sort((a, b) => a.tourOrder.compareTo(b.tourOrder));
    _editableCommands = List.from(commands);
    _originalOrder = commands.map((c) => c.id).toList();
  }

  Future<void> _saveOrder() async {
    setState(() {
      _isSaving = true;
    });

    final List<Map<String, dynamic>> commandsOrder = [];
    for (int i = 0; i < _editableCommands.length; i++) {
      commandsOrder.add({
        "commandId": _editableCommands[i].id,
        "tourOrder": i + 1,
      });
    }

    final success = await updateTourOrder(widget.tour.id, commandsOrder);

    if (success) {
      // Mettre à jour les tourOrder localement
      for (int i = 0; i < _editableCommands.length; i++) {
        _editableCommands[i].tourOrder = i + 1;
        widget.tour.commands[_editableCommands[i].id]?.tourOrder = i + 1;
      }

      Globals.showSnackbar(
        'Ordre sauvegardé',
        icon: Icons.check_circle_outline,
      );

      if (mounted) {
        widget.onOrderChanged?.call();
        Navigator.of(context).pop();
      }
    } else {
      Globals.showSnackbar(
        'Erreur lors de la sauvegarde',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(
          'Réorganiser',
          style: TextStyle(
            color: Globals.COLOR_TEXT_LIGHT,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.COLOR_MOVIX_GREEN,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Info header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Globals.COLOR_MOVIX_YELLOW,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ordre affiché dans le sens de livraison. Glissez les éléments pour réorganiser.',
                    style: TextStyle(
                      color: Globals.COLOR_MOVIX_YELLOW,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tour name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Globals.COLOR_MOVIX,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.tour.name,
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_DARK,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_MOVIX.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_editableCommands.length} commandes',
                    style: TextStyle(
                      color: Globals.COLOR_MOVIX,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Reorderable list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _editableCommands.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _editableCommands.removeAt(oldIndex);
                  _editableCommands.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final command = _editableCommands[index];
                return _buildCommandCard(command, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(Command command, int index) {
    return Container(
      key: ValueKey(command.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Numéro d'ordre
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Globals.COLOR_MOVIX.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Globals.COLOR_MOVIX,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info commande
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    command.pharmacy.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Globals.COLOR_TEXT_DARK,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${command.pharmacy.postalCode} ${command.pharmacy.city}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Globals.COLOR_TEXT_SECONDARY,
                    ),
                  ),
                  if (command.pharmacy.address1.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      command.pharmacy.address1,
                      style: TextStyle(
                        fontSize: 12,
                        color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Nombre de colis
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${command.packages.length} colis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Globals.COLOR_TEXT_SECONDARY,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Handle de drag
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Globals.COLOR_TEXT_SECONDARY,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
