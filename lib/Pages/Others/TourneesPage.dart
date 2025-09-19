import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Scanning/Scan.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';

class TourneesPage extends StatefulWidget {
  const TourneesPage({super.key});

  @override
  _TourneesPageState createState() => _TourneesPageState();
}

class _TourneesPageState extends State<TourneesPage> with RouteAware {
  bool _isLoading = false;

  Future<ScanResult> validateCode(String code) async {
    bool assigned = await assignTour(code);
    if (assigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Récupération de la tournée.', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
          backgroundColor: Globals.COLOR_MOVIX_GREEN,
          duration: const Duration(milliseconds: 800),
        ),
      );
      await _refreshTours();
      return ScanResult.SCAN_SUCCESS;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tournée introuvable.', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
          backgroundColor: Globals.COLOR_MOVIX_RED,
          duration: const Duration(milliseconds: 800),
        ),
      );
      return ScanResult.SCAN_ERROR;
    }
  }

  bool _updating = false;
  
  void onPageUpdate() {
    if (_updating || !mounted) return;
    _updating = true;
    
    Future.microtask(() {
      if (mounted) {
        setState(() {});
        _updating = false;
      }
    });
  }

  Future<void> _refreshTours() async {
    if (_isLoading) return; // Éviter les appels multiples
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final previousTours = Map<String, Tour>.from(Globals.tours);
      bool success = await getProfilTours();
      
      if (!success) {
        // Restaurer seulement si les tours ont été vidées
        if (Globals.tours.isEmpty && previousTours.isNotEmpty) {
          Globals.tours = previousTours;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de connexion lors du rafraîchissement', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
              backgroundColor: Globals.COLOR_MOVIX_RED,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      
      // Mettre à jour les états des commandes seulement si on a des tours
      if (Globals.tours.isNotEmpty) {
        for (var tour in Globals.tours.values) {
          if (tour.status.id == 2) {
          for (var command in tour.commands.values) {
            updateCommandState(command, onPageUpdate, false);
          }
          }
        }
      }
    } catch (e) {
      print('Erreur lors du refresh: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String getSubtitle(Tour tour) {
    if (tour.status.id == 2) {
      return '${tour.commands.values.where((command) => command.status.id == 2 || command.status.id == 6 || command.status.id == 7).length}/${tour.commands.length}';
    } else if (tour.status.id == 3) {
      return '${tour.commands.values.where((command) => command.status.id == 3 || command.status.id == 4 || command.status.id == 5 || command.status.id == 8 || command.status.id == 9).length}/${tour.commands.values.where((command) => command.status.id != 7).length}';
    }
    return '${tour.commands.length}/${tour.commands.length}';
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Globals.COLOR_MOVIX),
          const SizedBox(height: 20),
          Text(
            'Chargement des tournées...',
            style: TextStyle(
              fontSize: 16,
              color: Globals.COLOR_TEXT_SECONDARY,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Globals.COLOR_TEXT_SECONDARY,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune tournée disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Globals.COLOR_TEXT_DARK,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tirez vers le bas pour actualiser',
            style: TextStyle(
              fontSize: 14,
              color: Globals.COLOR_TEXT_SECONDARY,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTourCard(Tour tour) {
    final isChargement = tour.status.id == 2;
    final statusColor = isChargement 
        ? Globals.COLOR_MOVIX_YELLOW 
        : Globals.COLOR_MOVIX_GREEN;
    final statusText = getTourStatusText(tour.status.id);
    final tourColor = Color(int.parse("0xff${tour.color.substring(1)}"));

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (tour.status.id == 2) {
              context.go('/tour/chargement', extra: {'tour': tour});
            } else if (tour.status.id == 3) {
              context.go('/tour/livraison', extra: {'tour': tour});
            } else {
              Globals.showSnackbar(
                'Erreur status de la tournée',
                backgroundColor: Globals.COLOR_MOVIX_RED,
              );
              return;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: tourColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tourColor,
                        borderRadius: BorderRadius.circular(3),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Globals.COLOR_TEXT_DARK,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                                .format(DateTime.parse(tour.initialDate)),
                            style: TextStyle(
                              fontSize: 13,
                              color: Globals.COLOR_TEXT_DARK,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_SURFACE_SECONDARY,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.assignment_outlined,
                        label: 'Commandes',
                        value: getSubtitle(tour),
                        color: Globals.COLOR_MOVIX,
                      ),
                      const Spacer(),
                      _buildStatChip(
                        icon: Icons.inventory_2_outlined,
                        label: 'Colis',
                        value: tour.commands.values
                            .fold<int>(0, (sum, command) => 
                                sum + command.packages.length)
                            .toString(),
                        color: tourColor,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tourColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: tourColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Globals.COLOR_TEXT_DARK,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Globals.COLOR_TEXT_DARK,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(
          "Mes Tournées",
          style: TextStyle(
            color: Globals.COLOR_TEXT_LIGHT,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        backgroundColor: Globals.COLOR_MOVIX,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh,
                  color: Globals.COLOR_TEXT_LIGHT,
                  size: 20,
                ),
              ),
              onPressed: _refreshTours,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RefreshIndicator(
            onRefresh: _refreshTours,
            color: Globals.COLOR_MOVIX,
            backgroundColor: Globals.COLOR_SURFACE,
            child: CustomScrollView(
              slivers: [
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: _buildLoadingState(),
                  )
                else if (Globals.tours.values
                    .where((tour) => [2, 3].contains(tour.status.id))
                    .isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tours = Globals.tours.values
                              .where((tour) => [2, 3].contains(tour.status.id))
                              .toList();
                          return _buildModernTourCard(tours[index]);
                        },
                        childCount: Globals.tours.values
                            .where((tour) => [2, 3].contains(tour.status.id))
                            .length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120), // Space for scanner + margin
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScannerWidget(
                validateCode: validateCode,
                isActive: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
