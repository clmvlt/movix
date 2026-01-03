import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/profile_fetcher.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/settings.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManageToursPage extends StatefulWidget {
  const ManageToursPage({super.key});

  @override
  State<ManageToursPage> createState() => _ManageToursPageState();
}

class _ManageToursPageState extends State<ManageToursPage> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<Tour> _tours = [];
  bool _isLoading = true;
  bool _isInitialLoad = true;
  Tour? _selectedTour;
  bool _isEditMode = false;
  bool _isSaving = false;
  List<Command> _editableCommands = [];

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

    _loadSavedDate();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDate() async {
    final savedDate = await getManageToursSelectedDate();
    setState(() {
      _selectedDate = savedDate;
    });
    await _loadTours(showSkeleton: true);
  }

  Future<void> _loadTours({bool showSkeleton = false}) async {
    if (_isLoading && !showSkeleton) {
      _refreshController.refreshCompleted();
      return;
    }

    setState(() {
      _isLoading = true;
      _isInitialLoad = showSkeleton;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final tours = await getToursByDate(dateStr);

    if (mounted) {
      setState(() {
        _tours = tours ?? [];
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshController.refreshCompleted();
        }
      });
    }
  }

  Future<void> _changeDate(DateTime newDate) async {
    setState(() {
      _selectedDate = newDate;
      _selectedTour = null;
    });
    await setManageToursSelectedDate(newDate);
    await _loadTours(showSkeleton: true);
  }

  void _previousDay() {
    _changeDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void _nextDay() {
    _changeDate(_selectedDate.add(const Duration(days: 1)));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Globals.COLOR_MOVIX,
              onPrimary: Globals.COLOR_TEXT_LIGHT,
              surface: Globals.COLOR_SURFACE,
              onSurface: Globals.COLOR_TEXT_DARK,
            ),
            dialogBackgroundColor: Globals.COLOR_SURFACE,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _changeDate(picked);
    }
  }

  String _getDeliveredCount(Tour tour) {
    final delivered = tour.commands.values
        .where((cmd) => [3, 4, 5, 8, 9].contains(cmd.status.id))
        .length;
    final total = tour.commands.values
        .where((cmd) => cmd.status.id != 7)
        .length;
    return '$delivered/$total';
  }

  String _formatDuration(double minutes) {
    final int totalMins = minutes.round();
    final int hours = totalMins ~/ 60;
    final int mins = totalMins % 60;
    if (hours > 0) {
      return '${hours}h${mins.toString().padLeft(2, '0')}';
    }
    return '$mins min';
  }

  Widget _buildPopupMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Globals.COLOR_TEXT_DARK,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Globals.COLOR_TEXT_SECONDARY,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              _buildShimmerBox(
                height: 50,
                width: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(
                      height: 18,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    _buildShimmerBox(
                      height: 14,
                      width: 150,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              _buildShimmerBox(
                height: 28,
                width: 90,
                borderRadius: BorderRadius.circular(16),
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
        3,
        (index) => _buildSkeletonCard(),
      ),
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
          _selectedTour != null ? _selectedTour!.name : "Gestion des tournées",
          style: TextStyle(
            color: Globals.COLOR_TEXT_LIGHT,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        backgroundColor: Globals.COLOR_MOVIX,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () {
            if (_isEditMode) {
              _exitEditMode();
            } else if (_selectedTour != null) {
              setState(() {
                _selectedTour = null;
              });
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (_selectedTour == null)
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
                onPressed: () => _loadTours(showSkeleton: true),
              ),
            ),
          if (_selectedTour != null && !_isEditMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Globals.COLOR_SURFACE,
                elevation: 8,
                onSelected: (value) {
                  if (value == 'reorder') {
                    _enterEditMode();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'reorder',
                    padding: EdgeInsets.zero,
                    child: _buildPopupMenuItem(
                      icon: Icons.reorder,
                      iconColor: Globals.COLOR_ADAPTIVE_ACCENT,
                      title: 'Réorganiser',
                      subtitle: 'Modifier l\'ordre des commandes',
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.more_vert, color: Globals.COLOR_TEXT_LIGHT, size: 20),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedTour == null) _buildDateSelector(),
          Expanded(
            child: _selectedTour != null
                ? _buildTourDetail()
                : _buildToursList(),
          ),
        ],
      ),
    );
  }

  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Widget _buildDateSelector() {
    final isToday = _isToday();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: Icon(
              Icons.chevron_left,
              color: Globals.COLOR_ADAPTIVE_ACCENT,
              size: 28,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? Globals.COLOR_SURFACE_SECONDARY
                      : Globals.COLOR_MOVIX_YELLOW.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? null
                      : Border.all(
                          color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.3),
                          width: 1,
                        ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isToday) ...[
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Globals.COLOR_MOVIX_YELLOW,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      Icons.calendar_today,
                      color: isToday
                          ? Globals.COLOR_ADAPTIVE_ACCENT
                          : Globals.COLOR_MOVIX_YELLOW,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: TextStyle(
                        color: isToday
                            ? Globals.COLOR_TEXT_DARK
                            : Globals.COLOR_MOVIX_YELLOW,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _nextDay,
            icon: Icon(
              Icons.chevron_right,
              color: Globals.COLOR_ADAPTIVE_ACCENT,
              size: 28,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildToursList() {
    return RefreshConfiguration(
      springDescription: const SpringDescription(
        mass: 1,
        stiffness: 300,
        damping: 30,
      ),
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _loadTours,
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
            else if (_tours.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildTourCard(_tours[index]),
                      );
                    },
                    childCount: _tours.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
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
              'Aucune tournée pour cette date',
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
      ),
    );
  }

  Widget _buildTourCard(Tour tour) {
    final statusColor = tour.status.id == 2
        ? Globals.COLOR_MOVIX_YELLOW
        : tour.status.id == 3
            ? Globals.COLOR_MOVIX_GREEN
            : Globals.COLOR_TEXT_SECONDARY;
    final statusText = getTourStatusText(tour.status.id);
    final tourColor = Color(int.parse("0xff${tour.color.substring(1)}"));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _selectedTour = tour;
            });
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
                      height: 50,
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
                            tour.profil.firstName.isNotEmpty || tour.profil.lastName.isNotEmpty
                                ? '${tour.profil.firstName} ${tour.profil.lastName}'
                                : 'Non attribué',
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.COLOR_TEXT_SECONDARY,
                              fontWeight: FontWeight.w500,
                              fontStyle: tour.profil.firstName.isEmpty && tour.profil.lastName.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showAssignProfileDialog(tour),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_outlined,
                              color: Globals.COLOR_ADAPTIVE_ACCENT,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
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
                                    label: 'Livrées',
                                    value: _getDeliveredCount(tour),
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

  void _enterEditMode() {
    final commands = _selectedTour!.commands.values.toList()
      ..sort((a, b) => a.tourOrder.compareTo(b.tourOrder));
    setState(() {
      _isEditMode = true;
      _editableCommands = List.from(commands);
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
      _editableCommands = [];
    });
  }

  Future<void> _saveOrder() async {
    if (_selectedTour == null || _editableCommands.isEmpty) return;

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

    final success = await updateTourOrder(_selectedTour!.id, commandsOrder);

    if (success) {
      // Mettre à jour les tourOrder localement
      for (int i = 0; i < _editableCommands.length; i++) {
        _editableCommands[i].tourOrder = i + 1;
        _selectedTour!.commands[_editableCommands[i].id]?.tourOrder = i + 1;
      }

      Globals.showSnackbar(
        'Ordre sauvegardé',
        icon: Icons.check_circle_outline,
      );

      setState(() {
        _isEditMode = false;
        _isSaving = false;
      });
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

  Widget _buildTourDetail() {
    if (_selectedTour == null) return const SizedBox.shrink();

    if (_isEditMode) {
      return _buildEditModeList();
    }

    final commands = _selectedTour!.commands.values.toList()
      ..sort((a, b) => a.tourOrder.compareTo(b.tourOrder));

    return Column(
      children: [
        // Info commandes
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Globals.COLOR_SURFACE,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Globals.COLOR_TEXT_SECONDARY,
              ),
              const SizedBox(width: 8),
              Text(
                '${commands.length} commandes',
                style: TextStyle(
                  fontSize: 14,
                  color: Globals.COLOR_TEXT_SECONDARY,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final command = commands[index];
              return _buildCommandCard(command);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditModeList() {
    return Column(
      children: [
        // Header mode édition
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.drag_indicator,
                size: 20,
                color: Globals.COLOR_MOVIX_YELLOW,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Glissez pour réorganiser',
                  style: TextStyle(
                    fontSize: 14,
                    color: Globals.COLOR_TEXT_DARK,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _exitEditMode,
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_SECONDARY,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.COLOR_MOVIX_GREEN,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
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
              return _buildEditableCommandCard(command, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditableCommandCard(Command command, int index) {
    return Container(
      key: ValueKey(command.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.3),
          width: 1.5,
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Numéro d'ordre
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_ADAPTIVE_ACCENT,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info commande
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
                      "${command.pharmacy.postalCode} ${command.pharmacy.city}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Globals.COLOR_TEXT_SECONDARY,
                      ),
                    ),
                  ],
                ),
              ),
              // Handle de drag
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  Future<void> _showAssignProfileDialog(Tour tour) async {
    // Récupérer tous les profils via l'API
    final allProfiles = await getAllProfiles();

    if (allProfiles == null) {
      Globals.showSnackbar(
        'Erreur lors du chargement des chauffeurs',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
      return;
    }

    // Filtrer pour exclure le profil actuellement assigné à cette tournée
    final availableProfiles = allProfiles
        .where((p) => p.id != tour.profil.id && p.isMobile && p.isActive)
        .toList();

    final hasCurrentProfile = tour.profil.id.isNotEmpty;

    if (!mounted) return;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Globals.COLOR_SURFACE,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Assigner un chauffeur',
          style: TextStyle(
            color: Globals.COLOR_TEXT_DARK,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option pour désassigner
              if (hasCurrentProfile) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Globals.COLOR_MOVIX_RED.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_remove_outlined,
                        color: Globals.COLOR_MOVIX_RED,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Désassigner',
                      style: TextStyle(
                        color: Globals.COLOR_MOVIX_RED,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Retirer ${tour.profil.firstName} ${tour.profil.lastName}',
                      style: TextStyle(
                        color: Globals.COLOR_MOVIX_RED.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop('unassign'),
                  ),
                ),
                if (availableProfiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Ou assigner à',
                            style: TextStyle(
                              color: Globals.COLOR_TEXT_SECONDARY,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2))),
                      ],
                    ),
                  ),
              ],
              // Liste des profils disponibles
              if (availableProfiles.isEmpty && !hasCurrentProfile)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun chauffeur disponible',
                        style: TextStyle(
                          color: Globals.COLOR_TEXT_SECONDARY,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: availableProfiles.map((profile) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Globals.COLOR_SURFACE_SECONDARY,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'.toUpperCase(),
                                  style: TextStyle(
                                    color: Globals.COLOR_ADAPTIVE_ACCENT,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              '${profile.firstName} ${profile.lastName}',
                              style: TextStyle(
                                color: Globals.COLOR_TEXT_DARK,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Globals.COLOR_ADAPTIVE_ACCENT,
                            ),
                            onTap: () => Navigator.of(context).pop(profile.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Globals.COLOR_TEXT_SECONDARY,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      final String? profilId = result == 'unassign' ? null : result;
      final success = await assignTourToProfile(tour.id, profilId);

      if (success) {
        Globals.showSnackbar(
          profilId == null ? 'Chauffeur désassigné' : 'Chauffeur assigné',
          icon: profilId == null ? Icons.person_remove_outlined : Icons.person_add_outlined,
        );
        await _loadTours(showSkeleton: false);
      } else {
        Globals.showSnackbar(
          'Erreur lors de l\'assignation',
          backgroundColor: Globals.COLOR_MOVIX_RED,
          icon: Icons.error_outline,
        );
      }
    }
  }

  Future<void> _openCommandDetail(Command command) async {
    // Filtrer les autres tournées (exclure la tournée actuelle)
    final otherTours = _tours.where((t) => t.id != _selectedTour?.id).toList();

    await context.push(
      '/command-detail',
      extra: {
        'command': command,
        'availableTours': otherTours,
        'onUpdate': () async {
          await _loadTours(showSkeleton: false);
          if (_selectedTour != null) {
            final updatedTour = _tours.firstWhere(
              (t) => t.id == _selectedTour!.id,
              orElse: () => _selectedTour!,
            );
            setState(() {
              _selectedTour = updatedTour;
            });
          }
        },
      },
    );
  }

  Widget _buildCommandCard(Command command) {
    final statusText = command.status.name;
    final statusTime = command.status.createdAt.isNotEmpty
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(command.status.createdAt))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openCommandDetail(command),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            child: GetLivraisonIconCommandStatus(command, 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              command.pharmacy.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Globals.COLOR_TEXT_DARK,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${command.packages.length} colis',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Globals.COLOR_ADAPTIVE_ACCENT,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${command.pharmacy.address1} ${command.pharmacy.address2} ${command.pharmacy.address3}".trim(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.COLOR_TEXT_DARK_SECONDARY,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${command.pharmacy.postalCode} ${command.pharmacy.city}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.COLOR_TEXT_DARK_SECONDARY,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (statusText.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(command.status.id).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(command.status.id),
                                ),
                              ),
                            ),
                          ],
                          if (statusTime.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Globals.COLOR_TEXT_SECONDARY,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Globals.COLOR_TEXT_SECONDARY,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right,
                  color: Globals.COLOR_TEXT_SECONDARY,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
