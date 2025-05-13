import 'package:flutter/material.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
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
    showInfoPopup(
        context: context,
        title: "Détails de la tâche",
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("URL : ${task.url}"),
              const SizedBox(height: 8),
              const Text("Headers :",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...task.headers.entries
                  .map((entry) => Text("${entry.key}: ${entry.value}")),
              const SizedBox(height: 8),
              const Text("Body :",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.body.toString()),
            ],
          ),
        ));
  }

  Future<void> _monitorProcessing() async {
    while (_spoolerManager.isProcessing) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _spoolerList = List.from(_spoolerManager.queue);
      });
    }
    setState(() {
      _spoolerList = List.from(_spoolerManager.queue);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text("Spooler"),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Text('${_spoolerList.length} dans le spooler'),
          if (_isLoading || _spoolerManager.isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text("Chargement ou traitement en cours...")
                ],
              ),
            ),
          if (_spoolerManager.lastError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Erreur: ${_spoolerManager.lastError}",
                  style: const TextStyle(color: Globals.COLOR_MOVIX_RED)),
            ),
          Expanded(
            child: _spoolerList.isEmpty && !_isLoading
                ? const Center(child: Text("Aucune tâche dans le spooler"))
                : ListView.builder(
                    itemCount: _spoolerList.length,
                    itemBuilder: (context, index) {
                      Spooler task = _spoolerList[index];
                      return Card(
                        margin: const EdgeInsets.all(2),
                        child: ListTile(
                          title: Text(task.url,
                              style: const TextStyle(fontSize: 12)),
                          onTap: () => _showDetailsDialog(task),
                          onLongPress: () => _showDeleteDialog(task),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0)
                .copyWith(bottom: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: customButton(
                label: "Tout renvoyer",
                onPressed: (_spoolerManager.isProcessing || _isLoading)
                    ? () {}
                    : () {
                        _processAllTasks();
                      },
              ),
            ),
          )
        ],
      ),
    );
  }
}
