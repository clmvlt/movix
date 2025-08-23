import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/PhotoPickerWidget.dart';

class PhotoSectionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> photosBase64;
  final Function(List<String>) onImagesChanged;
  final bool isRequired;
  final String emptyMessage;
  final double height;

  const PhotoSectionWidget({
    super.key,
    this.title = "Photos",
    this.subtitle = "Ajoutez vos photos",
    required this.photosBase64,
    required this.onImagesChanged,
    this.isRequired = false,
    this.emptyMessage = "Aucune photo prise",
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                    Icons.camera_alt_outlined,
                    color: Globals.COLOR_MOVIX_GREEN,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: photosBase64.isNotEmpty 
                        ? Globals.COLOR_MOVIX_GREEN.withOpacity(0.1)
                        : (isRequired 
                          ? Globals.COLOR_MOVIX_RED.withOpacity(0.1)
                          : Globals.COLOR_TEXT_DARK.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${photosBase64.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: photosBase64.isNotEmpty 
                          ? Globals.COLOR_MOVIX_GREEN
                          : (isRequired 
                            ? Globals.COLOR_MOVIX_RED
                            : Globals.COLOR_TEXT_DARK.withOpacity(0.6)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: PhotoPickerWidget(
                base64Images: photosBase64,
                onImagesChanged: onImagesChanged,
                isRequired: isRequired,
                emptyMessage: emptyMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}