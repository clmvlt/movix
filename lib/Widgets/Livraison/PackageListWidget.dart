import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Widgets/PackagesWidget.dart';

class PackageListWidget extends StatelessWidget {
  final Map<String, Package> packages;
  final void Function(Package)? onPackageRemove;
  final String emptyMessage;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const PackageListWidget({
    super.key,
    required this.packages,
    this.onPackageRemove,
    this.emptyMessage = 'Scannez pour ajouter un colis',
    this.title = 'Colis concernés',
    this.subtitle = 'Scannez les colis affectés',
    this.icon = Icons.inventory_2_outlined,
    this.iconColor = const Color(0xFFFF9800), // Globals.COLOR_MOVIX_YELLOW
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
                        iconColor.withOpacity(0.15),
                        iconColor.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
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
                    color: packages.isNotEmpty 
                        ? Globals.COLOR_MOVIX_GREEN.withOpacity(0.1)
                        : Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${packages.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: packages.isNotEmpty 
                          ? Globals.COLOR_MOVIX_GREEN
                          : Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                minHeight: 60,
                maxHeight: packages.length > 3 ? 160 : double.infinity,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: packages.isEmpty
                  ? _buildEmptyState()
                  : _buildPackageList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner_outlined,
            size: 28,
            color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 14,
              color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: packages.values.map((package) {
          return _buildPackageItem(package);
        }).toList(),
      ),
    );
  }

  Widget _buildPackageItem(Package package) {
    final emote = getPackageEmote(package.type);
    final isFresh = package.fresh ? '❄️' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Globals.COLOR_MOVIX.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              emote,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.barcode,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Globals.COLOR_TEXT_DARK,
                  ),
                ),
                if (isFresh.isNotEmpty)
                  Text(
                    'Produit frais $isFresh',
                    style: TextStyle(
                      fontSize: 12,
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (onPackageRemove != null)
            GestureDetector(
              onTap: () => onPackageRemove?.call(package),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Globals.COLOR_MOVIX_RED,
                ),
              ),
            ),
        ],
      ),
    );
  }
}