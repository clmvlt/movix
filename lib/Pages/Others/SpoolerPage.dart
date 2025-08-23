import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomPopup.dart';

class SpoolerPage extends StatefulWidget {
  const SpoolerPage({super.key});

  @override
  _SpoolerPageState createState() => _SpoolerPageState();
}

class _SpoolerPageState extends State<SpoolerPage> {
  final SpoolerManager _spoolerManager = SpoolerManager();
  List<Spooler> _spoolerList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSpoolerQueue().then((_) {
      if (_spoolerManager.isProcessing) {
        _monitorProcessing();
      }
    });
  }

  Future<void> _loadSpoolerQueue() async {
    setState(() {
      _isLoading = true;
    });
    await _spoolerManager.loadQueue();
    setState(() {
      _spoolerList = List.from(_spoolerManager.queue);
      _isLoading = false;
    });
  }

  Future<void> _processAllTasks() async {
    setState(() {
      _isLoading = true;
    });

    while (_spoolerList.isNotEmpty) {
      Spooler task = _spoolerList.first;
      bool success = await _spoolerManager.processSingleTask(task);

      if (success) {
        setState(() {
          _spoolerList.remove(task);
        });
      } else {
        break;
      }
    }

    setState(() {
      _isLoading = false;
    });

    Globals.showSnackbar(
      _spoolerList.isEmpty
          ? 'Tous les messages ont été renvoyés !'
          : 'Certains messages n\'ont pas pu être renvoyés.',
      backgroundColor: _spoolerList.isEmpty
          ? Globals.COLOR_MOVIX_GREEN
          : Globals.COLOR_MOVIX_RED,
    );
  }

  void _showDeleteDialog(Spooler task) async {
    bool? res = await showConfirmationPopup(
        context: context,
        title: "Supprimer l'élement",
        message: "Souhaitez-vous supprimer cette tâche du spooler ?",
        cancelText: "Annuler",
        confirmText: "Supprimer");
    if (res == true) {
      setState(() {
        _spoolerList.remove(task);
        _spoolerManager.queue.remove(task);
      });
      await _spoolerManager.saveQueue();
      Globals.showSnackbar("Tâche supprimée.");
    }
  }

  void _showDetailsDialog(Spooler task) {
    String bodyContent = task.body.toString();
    // Check if body contains base64 content
    if (bodyContent.contains('base64')) {
      bodyContent = '[base64 content]';
    }

    showInfoPopup(
        context: context,
        title: "Détails de la tâche",
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("URL : ${task.url}",
                  style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
              const SizedBox(height: 8),
              Text("Type de formulaire : ${task.formType ?? 'Non spécifié'}",
                  style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
              const SizedBox(height: 8),
              Text("Headers :",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Globals.COLOR_TEXT_DARK)),
              ...task.headers.entries
                  .map((entry) => Text("${entry.key}: ${entry.value}",
                      style: TextStyle(color: Globals.COLOR_TEXT_DARK))),
              const SizedBox(height: 8),
              Text("Body :",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Globals.COLOR_TEXT_DARK)),
              Text(bodyContent,
                  style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
            ],
          ),
        ));
  }

  Future<void> _monitorProcessing() async {
    while (_spoolerManager.isProcessing) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      setState(() {
        _spoolerList = List.from(_spoolerManager.queue);
      });
    }
    setState(() {
      _spoolerList = List.from(_spoolerManager.queue);
      _isLoading = false;
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              FontAwesomeIcons.checkDouble,
              size: 48,
              color: Globals.COLOR_MOVIX,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Aucune tâche en attente",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Globals.COLOR_TEXT_DARK,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Toutes les données sont synchronisées",
            style: TextStyle(
              fontSize: 14,
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Spooler task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetailsDialog(task),
          onLongPress: () => _showDeleteDialog(task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTaskIcon(task),
                    size: 18,
                    color: _getTaskStatusColor(task),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTaskTitle(task),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.url,
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.formType ?? 'GET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getTaskStatusColor(task),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTaskStatusColor(Spooler task) {
    switch (task.formType?.toLowerCase()) {
      case 'post':
        return Globals.COLOR_MOVIX_GREEN;
      case 'put':
        return Globals.COLOR_MOVIX_YELLOW;
      case 'delete':
        return Globals.COLOR_MOVIX_RED;
      default:
        return Globals.COLOR_MOVIX;
    }
  }

  IconData _getTaskIcon(Spooler task) {
    switch (task.formType?.toLowerCase()) {
      case 'post':
        return FontAwesomeIcons.plus;
      case 'put':
        return FontAwesomeIcons.penToSquare;
      case 'delete':
        return FontAwesomeIcons.trash;
      default:
        return FontAwesomeIcons.download;
    }
  }

  String _getTaskTitle(Spooler task) {
    if (task.url.contains('/anomalies')) {
      return 'Anomalie à synchroniser';
    } else if (task.url.contains('/commands')) {
      return 'Commande à synchroniser';
    } else if (task.url.contains('/tours')) {
      return 'Tournée à synchroniser';
    }
    return 'Tâche à synchroniser';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FontAwesomeIcons.clockRotateLeft,
                size: 20,
                color: Globals.COLOR_TEXT_LIGHT,
              ),
            ),
            const SizedBox(width: 12),
            const Text("Spooler"),
          ],
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_spoolerList.length}',
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_MOVIX.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.listCheck,
                    color: Globals.COLOR_MOVIX,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_spoolerList.length} tâche${_spoolerList.length > 1 ? 's' : ''} en attente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _spoolerList.isEmpty 
                          ? 'Aucune tâche à traiter'
                          : 'Prêt à être synchronisé',
                        style: TextStyle(
                          fontSize: 14,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading || _spoolerManager.isProcessing)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Globals.COLOR_MOVIX.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Globals.COLOR_MOVIX.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Globals.COLOR_MOVIX,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _spoolerManager.isProcessing 
                        ? "Synchronisation en cours..."
                        : "Chargement...",
                      style: TextStyle(
                        color: Globals.COLOR_MOVIX,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_spoolerManager.lastError.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Globals.COLOR_MOVIX_RED.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.triangleExclamation,
                        color: Globals.COLOR_MOVIX_RED,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Erreur de synchronisation",
                        style: TextStyle(
                          color: Globals.COLOR_MOVIX_RED,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _spoolerManager.lastError.length > 100
                        ? '${_spoolerManager.lastError.substring(0, 100)}...'
                        : _spoolerManager.lastError,
                    style: TextStyle(
                      color: Globals.COLOR_MOVIX_RED.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  if (_spoolerManager.lastError.length > 100)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          showErrorPopup(
                            context: context,
                            title: "Erreur complète",
                            message: _spoolerManager.lastError,
                          );
                        },
                        icon: Icon(
                          FontAwesomeIcons.eye,
                          size: 14,
                          color: Globals.COLOR_MOVIX_RED,
                        ),
                        label: Text(
                          'Voir le détail',
                          style: TextStyle(
                            color: Globals.COLOR_MOVIX_RED,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _spoolerList.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _spoolerList.length,
                    itemBuilder: (context, index) {
                      Spooler task = _spoolerList[index];
                      return _buildTaskCard(task, index);
                    },
                  ),
          ),
          if (_spoolerList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: (_spoolerManager.isProcessing || _isLoading)
                      ? null
                      : () {
                          _processAllTasks();
                        },
                  icon: Icon(
                    FontAwesomeIcons.arrowsRotate,
                    size: 18,
                  ),
                  label: Text(
                    "Synchroniser tout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Globals.COLOR_MOVIX,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
