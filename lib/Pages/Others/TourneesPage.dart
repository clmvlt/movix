import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/ScannerWidget.dart';

class TourneesPage extends StatefulWidget {
  const TourneesPage({super.key});

  @override
  _TourneesPageState createState() => _TourneesPageState();
}

class _TourneesPageState extends State<TourneesPage> with RouteAware {
  bool _isLoading = false;
  final GlobalKey<ScannerWidgetState> _scannerKey =
      GlobalKey<ScannerWidgetState>();

  Future<ScanResult> validateCode(String code) async {
    bool assigned = await assignTour(code);
    if (assigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Récupération de la tournée.'),
          backgroundColor: Globals.COLOR_MOVIX_GREEN,
          duration: Duration(milliseconds: 800),
        ),
      );
      await _refreshTours();
      return Globals.isScannerMode ? ScanResult.NOTHING : ScanResult.SCAN_SUCCESS;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournée introuvable.'),
          backgroundColor: Globals.COLOR_MOVIX_RED,
          duration: Duration(milliseconds: 800),
        ),
      );
      return ScanResult.SCAN_ERROR;
    }
  }

  void onPageUpdate() {
    setState(() {});
  }

  Future<void> _refreshTours() async {
    setState(() {
      _isLoading = true;
    });
    await getProfilTours();
    for (var tour in Globals.tours.values) {
      for (var command in tour.commands.values) {
        updateCommandState(command, onPageUpdate, false);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  String getSubtitle(Tour tour) {
    if (tour.idStatus == "2") {
      return '${tour.commands.values.where((command) => command.idStatus == "2" || command.idStatus == "6" || command.idStatus == "7").length}/${tour.commands.length}';
    } else if (tour.idStatus == "3") {
      return '${tour.commands.values.where((command) => command.idStatus == "3" || command.idStatus == "4" || command.idStatus == "5" || command.idStatus == "8" || command.idStatus == "9").length}/${tour.commands.values.where((command) => command.idStatus != "7").length}';
    }
    return '${tour.commands.length}/${tour.commands.length}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text(
          "Tournées",
        ),
        foregroundColor: Colors.white,
        backgroundColor: Globals.COLOR_MOVIX,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTours,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Globals.tours.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune tournée',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: Globals.tours.values
                            .where((tour) => ["2", "3"].contains(tour.idStatus))
                            .length,
                        itemBuilder: (context, index) {
                          List<Tour> filteredTours = Globals.tours.values
                              .where(
                                  (tour) => ["2", "3"].contains(tour.idStatus))
                              .toList();
                          Tour tour = filteredTours[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                if (tour.idStatus == "2") {
                                  context.go('/tour/chargement',
                                      extra: {
                                        'tour': tour
                                      });
                                } else if (tour.idStatus == "3") {
                                  context.go('/tour/livraison', extra: {
                                    'tour': tour
                                  });
                                } else {
                                  Globals.showSnackbar(
                                    'Erreur status de la tournée',
                                    backgroundColor: Globals.COLOR_MOVIX_RED,
                                  );
                                  return;
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(
                                            "0xff${tour.color.substring(1)}")),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tour.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: tour.idStatus == "2"
                                                      ? Colors.orange[100]
                                                      : Colors.green[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  getTourStatusText(
                                                      tour.idStatus),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: tour.idStatus == "2"
                                                        ? Colors.orange[800]
                                                        : Colors.green[800],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "📦 Commandes : ${getSubtitle(tour)}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "📅 ${DateFormat('dd MMM yyyy').format(DateTime.parse(tour.initialDate))}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Globals.COLOR_MOVIX,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            "${tour.commands.values.fold<int>(0, (sum, command) => sum + command.packages.length)} 📦",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: Globals.COLOR_MOVIX,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScannerWidget(
              key: _scannerKey,
              validateCode: validateCode,
            ),
          ),
        ],
      ),
    );
  }
}
