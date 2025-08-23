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

class PharmacyInfosPage extends StatefulWidget {
  final Command command;

  const PharmacyInfosPage({super.key, required this.command});

  @override
  _PharmacyInfosPageState createState() => _PharmacyInfosPageState();
}

class _PharmacyInfosPageState extends State<PharmacyInfosPage> {
  late Future<Pharmacy?> _pharmacyInfo;

  @override
  void initState() {
    super.initState();
    _pharmacyInfo = getPharmacyInfos(widget.command.pharmacy.cip);
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
      body: FutureBuilder<Pharmacy?>(
        future: _pharmacyInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingStateWidget(message: 'Chargement des informations...');
          } else if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          } else if (snapshot.hasData && snapshot.data != null) {
            final pharmacy = snapshot.data!;
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
          } else {
            return const EmptyStateWidget(
              message: 'Les informations de cette pharmacie ne sont pas encore renseignées',
            );
          }
        },
      ),
    );
  }


  Widget _buildModernInstructionsCard(String informations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Globals.COLOR_MOVIX.withOpacity(0.15),
                        Globals.COLOR_MOVIX.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Globals.COLOR_MOVIX,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Instructions de livraison",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_TEXT_DARK,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }

  Widget _buildModernPhotosCard(Pharmacy pharmacy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Globals.COLOR_MOVIX_GREEN.withOpacity(0.15),
                        Globals.COLOR_MOVIX_GREEN.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Globals.COLOR_MOVIX_GREEN,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Photos (${pharmacy.pictures.length})",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_TEXT_DARK,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
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
              itemCount: pharmacy.pictures.length,
              itemBuilder: (context, index) {
                return _buildModernPhotoItem(
                  pharmacy.pictures[index].imagePath, 
                  index, 
                  pharmacy.pictures.map((p) => p.imagePath).toList(),
                );
              },
            ),
          ],
        ),
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

