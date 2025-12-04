import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/API/pharmacy_fetcher.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Pharmacy.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/Common/AppBarWidget.dart';
import 'package:movix/Widgets/Common/StateWidgets.dart';
import 'package:movix/Widgets/Common/ImageGalleryWidget.dart';
import 'package:movix/Widgets/Livraison/ModernCardWidget.dart';

class PharmacyInfosPage extends StatefulWidget {
  final Command command;

  const PharmacyInfosPage({super.key, required this.command});

  @override
  _PharmacyInfosPageState createState() => _PharmacyInfosPageState();
}

class _PharmacyInfosPageState extends State<PharmacyInfosPage> with SingleTickerProviderStateMixin {
  Pharmacy? _currentPharmacy;
  bool _isLoading = true;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser l'animation shimmer
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

    // Charger les données locales immédiatement
    _currentPharmacy = widget.command.pharmacy;
    _isLoading = false;

    // En parallèle, récupérer les données depuis l'API
    _refreshPharmacyFromApi();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _refreshPharmacyFromApi() async {
    try {
      final apiPharmacy = await getPharmacyInfos(widget.command.pharmacy.cip);

      if (apiPharmacy != null && mounted) {
        setState(() {
          _currentPharmacy = apiPharmacy;
        });
      }
      // Si l'API échoue (null), on garde les données locales
    } catch (e) {
      // En cas d'erreur, on garde les données locales
      print('Erreur lors du refresh API: $e');
    }
  }

  TextSpan parseText(String? text) {
    if (text == null || text.isEmpty) {
      return TextSpan(
        text: "Aucune information disponible",
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Globals.COLOR_TEXT_DARK),
      );
    }

    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Globals.COLOR_TEXT_DARK),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Globals.COLOR_MOVIX_RED,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Globals.COLOR_TEXT_DARK),
      ));
    }

    return TextSpan(children: spans);
  }

  void showImageFullscreen(String imageUrl, int initialIndex, List<String> allImages) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ImageGalleryWidget(
        images: allImages,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    double? width,
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

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Instructions card skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header skeleton
                  Row(
                    children: [
                      _buildShimmerBox(
                        height: 24,
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(width: 12),
                      _buildShimmerBox(
                        height: 20,
                        width: 200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Content skeleton
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(
                          height: 16,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        _buildShimmerBox(
                          height: 16,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        _buildShimmerBox(
                          height: 16,
                          width: 250,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Photos card skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header skeleton
                  Row(
                    children: [
                      _buildShimmerBox(
                        height: 24,
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(width: 12),
                      _buildShimmerBox(
                        height: 20,
                        width: 120,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Grid skeleton
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return _buildShimmerBox(
                        height: double.infinity,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: CustomAppBarWidget(
        title: widget.command.pharmacy.name,
        subtitle: 'Informations pharmacie',
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? _buildSkeletonLoading()
          : _currentPharmacy != null
              ? _buildPharmacyContent(_currentPharmacy!)
              : const EmptyStateWidget(
                  message: 'Les informations de cette pharmacie ne sont pas encore renseignées',
                ),
    );
  }

  Widget _buildPharmacyContent(Pharmacy pharmacy) {
    final String informations = pharmacy.informations.isNotEmpty
        ? pharmacy.informations
        : 'Aucune information disponible';

    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildModernInstructionsCard(informations),
              if (pharmacy.pictures.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildModernPhotosCard(pharmacy),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: customButton(
          bottomPadding: 32,
          onPressed: () {
            context.push('/addinfospharmacy',
                extra: {'command': widget.command});
          },
          label: "Ajouter des instructions"),
    );
  }


  Widget _buildModernInstructionsCard(String informations) {
    return ModernCardWidget(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernCardHeader(
            icon: Icons.info_outline,
            iconColor: Globals.COLOR_MOVIX,
            title: "Instructions de livraison",
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: RichText(
              text: parseText(informations),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPhotosCard(Pharmacy pharmacy) {
    // Trier les photos par displayOrder
    final sortedPictures = List<PharmacyPicture>.from(pharmacy.pictures)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return ModernCardWidget(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernCardHeader(
            icon: Icons.photo_library_outlined,
            iconColor: Globals.COLOR_MOVIX_GREEN,
            title: "Photos (${sortedPictures.length})",
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: sortedPictures.length,
            itemBuilder: (context, index) {
              return _buildModernPhotoItem(
                sortedPictures[index].imagePath,
                index,
                sortedPictures.map((p) => p.imagePath).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernPhotoItem(String imagePath, int index, List<String> allImages) {
    return GestureDetector(
      onTap: () => showImageFullscreen(imagePath, index, allImages),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Globals.COLOR_MOVIX,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: Globals.COLOR_TEXT_SECONDARY,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erreur de chargement',
                          style: TextStyle(
                            fontSize: 12,
                            color: Globals.COLOR_TEXT_SECONDARY,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => showImageFullscreen(imagePath, index, allImages),
                    splashColor: Globals.COLOR_MOVIX.withOpacity(0.1),
                    highlightColor: Globals.COLOR_MOVIX.withOpacity(0.05),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

