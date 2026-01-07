import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Router/app_router.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TourneesPage extends StatefulWidget {
  const TourneesPage({super.key});

  @override
  _TourneesPageState createState() => _TourneesPageState();
}

class _TourneesPageState extends State<TourneesPage> with RouteAware, SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isInitialLoad = true;
  final SpoolerManager _spoolerManager = SpoolerManager();
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
    initialRefreshStatus: RefreshStatus.idle,
  );

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _shimmerController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Appelé quand on revient sur cette page (après un pop)
    // Rafraîchit l'affichage sans appeler l'API
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _showSpoolerWarningDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Globals.COLOR_SURFACE,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Globals.COLOR_MOVIX_YELLOW,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Attention',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_DARK,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vous avez ${_spoolerManager.getTasksCount()} élément(s) en attente dans le spooler.',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_DARK,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Actualiser maintenant risque de causer des décalages avec les données en attente d\'envoi.',
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_DARK,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Voulez-vous continuer ?',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_DARK,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_SECONDARY,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Globals.COLOR_MOVIX_YELLOW,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Actualiser quand même',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
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

  Future<void> _refreshTours({bool showSkeleton = false}) async {
    if (_isLoading) {
      _refreshController.refreshCompleted();
      return; // Éviter les appels multiples
    }

    // Vérifier si le spooler contient des éléments avant d'actualiser
    if (_spoolerManager.getTasksCount() > 0) {
      bool shouldContinue = await _showSpoolerWarningDialog();
      if (!shouldContinue) {
        _refreshController.refreshCompleted();
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _isInitialLoad = showSkeleton;
    });

    // Sauvegarder les tournées actuelles avant l'actualisation
    final previousTours = Map<String, Tour>.from(Globals.tours);

    try {
      bool success = await getProfilTours();

      if (!success) {
        // Restaurer les anciennes tournées en cas d'erreur réseau
        Globals.tours = previousTours;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de connexion lors du rafraîchissement', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
              backgroundColor: Globals.COLOR_MOVIX_RED,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Succès de l'actualisation
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
      }
    } catch (e) {
      // En cas d'exception, restaurer les anciennes tournées
      Globals.tours = previousTours;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'actualisation: ${e.toString()}', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
            backgroundColor: Globals.COLOR_MOVIX_RED,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        // Mettre à jour l'état de loading et reconstruire l'UI avec les nouvelles données
        setState(() {
          _isLoading = false;
        });
        // Attendre que le frame soit rendu avant de terminer le refresh indicator
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshController.refreshCompleted();
          }
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

  String _formatDuration(double minutes) {
    final int totalMins = minutes.round();
    final int hours = totalMins ~/ 60;
    final int mins = totalMins % 60;
    if (hours > 0) {
      return '${hours}h${mins.toString().padLeft(2, '0')}';
    }
    return '${mins} min';
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    required BorderRadius borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2),
                Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
              ],
              stops: [
                0.0,
                _shimmerAnimation.value.clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Barre de couleur skeleton
              _buildShimmerBox(
                height: 40,
                width: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre skeleton
                    _buildShimmerBox(
                      height: 18,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    // Date skeleton
                    _buildShimmerBox(
                      height: 14,
                      width: 180,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              // Badge status skeleton
              _buildShimmerBox(
                height: 28,
                width: 90,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats container skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE_SECONDARY,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Première ligne : Commandes, Colis
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildShimmerBox(
                                  height: 16,
                                  width: 60,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                _buildShimmerBox(
                                  height: 12,
                                  width: 80,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                _buildShimmerBox(
                                  height: 16,
                                  width: 40,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                _buildShimmerBox(
                                  height: 12,
                                  width: 50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Deuxième ligne : Distance, Durée
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildShimmerBox(
                                  height: 16,
                                  width: 50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                _buildShimmerBox(
                                  height: 12,
                                  width: 60,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                _buildShimmerBox(
                                  height: 16,
                                  width: 50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                _buildShimmerBox(
                                  height: 12,
                                  width: 45,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Arrow skeleton centré
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Globals.COLOR_TEXT_SECONDARY.withOpacity(0.05),
                            Globals.COLOR_TEXT_SECONDARY.withOpacity(0.15),
                            Globals.COLOR_TEXT_SECONDARY.withOpacity(0.05),
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value.clamp(0.0, 1.0),
                            1.0,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3, // Afficher 3 cartes skeleton
        (index) => _buildSkeletonCard(),
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
              context.push('/tour/chargement', extra: {'tour': tour});
            } else if (tour.status.id == 3) {
              context.push('/tour/livraison', extra: {'tour': tour});
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
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatChip(
                                    icon: Icons.assignment_outlined,
                                    label: 'Commandes',
                                    value: getSubtitle(tour),
                                    color: tourColor,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatChip(
                                    icon: Icons.inventory_2_outlined,
                                    label: 'Colis',
                                    value: tour.commands.values
                                        .fold<int>(0, (sum, command) =>
                                            sum + command.packages.length)
                                        .toString(),
                                    color: tourColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatChip(
                                    icon: Icons.route_outlined,
                                    label: 'Distance',
                                    value: '${tour.estimateKm.toStringAsFixed(0)} km',
                                    color: tourColor,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatChip(
                                    icon: Icons.schedule_outlined,
                                    label: 'Durée',
                                    value: _formatDuration(tour.estimateMins),
                                    color: tourColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
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
              onPressed: () => _refreshTours(showSkeleton: true),
            ),
          ),
        ],
      ),
      body: RefreshConfiguration(
        springDescription: const SpringDescription(
          mass: 1,
          stiffness: 300,
          damping: 30,
        ),
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _refreshTours,
          enablePullDown: true,
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          header: CustomHeader(
            height: 80,
            completeDuration: Duration.zero,
            refreshStyle: RefreshStyle.UnFollow,
          builder: (BuildContext context, RefreshStatus? mode) {
            Widget body;
            if (mode == RefreshStatus.idle) {
              body = Text(
                'Tirer pour actualiser',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_SECONDARY,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            } else if (mode == RefreshStatus.canRefresh) {
              body = Text(
                'Relâcher pour actualiser',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_SECONDARY,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            } else if (mode == RefreshStatus.refreshing) {
              body = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Globals.COLOR_TEXT_SECONDARY),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Actualisation...',
                    style: TextStyle(
                      color: Globals.COLOR_TEXT_DARK,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            } else {
              body = const SizedBox.shrink();
            }
            return Container(
              height: 80,
              padding: const EdgeInsets.only(top: 20),
              child: Center(child: body),
            );
          },
        ),
        child: CustomScrollView(
          slivers: [
            if (_isLoading && _isInitialLoad)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _buildLoadingState(),
                ),
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
              child: SizedBox(height: 20),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
