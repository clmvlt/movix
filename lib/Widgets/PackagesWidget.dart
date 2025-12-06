import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Services/globals.dart';

class CustomListePackages extends StatefulWidget {
  final Command command;
  final bool isLivraison;

  const CustomListePackages({
    super.key,
    required this.command,
    required this.isLivraison,
  });

  @override
  State<CustomListePackages> createState() => _CustomListePackagesState();
}

class _CustomListePackagesState extends State<CustomListePackages> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.command.packages.isNotEmpty
        ? Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Globals.COLOR_SURFACE_SECONDARY,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.command.packages.values.map((package) {
                          final emote = getPackageEmote(package.type);
                          final isFresh = package.fresh ? '❄️' : '';
                          final hasZone = package.zoneName.isNotEmpty;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                if (hasZone) ...[
                                  Text(
                                    package.zoneName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Globals.COLOR_TEXT_GRAY,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                widget.isLivraison ? getLivraisonIconPackageStatus(package, 15) : getCargementIconPackageStatus(package, 15),
                                const SizedBox(width: 8),
                                Text(
                                  package.barcode,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Globals.COLOR_TEXT_DARK,
                                  ),
                                ),
                                Text(
                                  " $emote$isFresh",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Globals.COLOR_TEXT_DARK,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 10,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "${PackageSearcher.countPackageStatusInCommand(widget.command)[widget.isLivraison ? 3 : 2]}/${widget.command.packages.length}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Globals.COLOR_TEXT_DARK,
                    ),
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Aucun package disponible',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Globals.COLOR_TEXT_DARK_SECONDARY,
                ),
              ),
            ),
          );
  }
}

String getPackageEmote(String type) {
  switch (type) {
    case "BAC":
      return "💊";
    case "COLIS":
      return "📦";
    default:
      return type;
  }
}

Widget getCargementIconPackageStatus(Package package, double size) {
  Icon icon;
  Color circleColor = Globals.COLOR_LIGHT_GRAY;

  if (package.status.id == 2) {
    icon = Icon(
      Icons.check,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
  } else if (package.status.id == 5) {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_RED;
  } else {
    icon = Icon(
      Icons.question_mark,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: circleColor,
    ),
    child: Center(child: icon),
  );
}

Widget getLivraisonIconPackageStatus(Package package, double size) {
  Icon icon;
  Color circleColor = Globals.COLOR_LIGHT_GRAY;

  if (package.status.id == 1 || package.status.id == 2) {
    icon = Icon(
      Icons.question_mark,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
  } else if (package.status.id == 3) {
    icon = Icon(
      Icons.check,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_GREEN;
    } else if (package.status.id == 6) {
    icon = Icon(
      Icons.warning_amber_outlined,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_YELLOW;
  } else {
    icon = Icon(
      FontAwesomeIcons.xmark,
      color: Globals.COLOR_TEXT_LIGHT,
      size: size * 0.6,
    );
    circleColor = Globals.COLOR_MOVIX_RED;
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: circleColor,
    ),
    child: Center(child: icon),
  );
}