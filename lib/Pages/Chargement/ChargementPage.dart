import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';

class ChargementPage extends StatefulWidget {
  final Tour tour;

  const ChargementPage({super.key, required this.tour});

  @override
  _ChargementPage createState() => _ChargementPage();
}

class _ChargementPage extends State<ChargementPage> {
  final ScrollController _scrollController = ScrollController();
  late String selectedId;
  late PackageSearcher packageSearcher;

  void onUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    showDialogs(context, widget.tour);
    if (widget.tour.commands.isNotEmpty) {
      selectedId = widget.tour.commands.values.last.id;
    }

    packageSearcher = PackageSearcher(widget.tour.commands);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(
          widget.tour.name,
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/tours');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              '${countValidCommands(widget.tour)}/${widget.tour.commands.length}',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.tour.commands.length,
                itemBuilder: (context, index) {
                  final command = widget.tour.commands.values
                      .elementAt(widget.tour.commands.length - 1 - index);
                  final isSelected = selectedId == command.id;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: isSelected ? Colors.white : const Color.fromARGB(255, 240, 240, 240),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        splashColor: Colors.grey[300],
                        onTap: () {
                          setState(() {
                            selectedId = command.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 70),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GetChargementIconCommandStatus(command, 24),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          command.pharmacyName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (command.pNew) ...[
                                    newBadge(),
                                    const SizedBox(width: 2),
                                  ],
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Globals.COLOR_MOVIX,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "${command.packages.length} 📦",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${command.pharmacyAddress1} ${command.pharmacyAddress2} ${command.pharmacyAddress3}"
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              ),
                              Text(
                                "${command.pharmacyPostalCode} ${command.pharmacyCity}",
                                style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              ),
                              if (isSelected &&
                                  command.packages.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: command.packages.length,
                                  itemBuilder: (context, index) {
                                    final package = command.packages.values
                                        .elementAt(index);
                                    final zoneName = package.zoneName.isEmpty
                                        ? "00"
                                        : package.zoneName;

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Row(
                                        children: [
                                          getIconPackageStatus(package, 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            package.barcode,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const Spacer(),
                                          Text(
                                            zoneName,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 70),
                                transitionBuilder: (child, animation) {
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: isSelected
                                    ? Column(
                                        key: ValueKey("actions_$index"),
                                        children: [
                                          const Divider(),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              customToolButton(
                                                color: Globals.COLOR_MOVIX_RED,
                                                iconData:
                                                    FontAwesomeIcons.xmark,
                                                text: "Non chargé",
                                                onPressed: () {
                                                  ShowChargementAnomalieManu(
                                                    context,
                                                    command,
                                                    onUpdate,
                                                  );
                                                },
                                              ),
                                              customToolButton(
                                                color: Globals.COLOR_MOVIX,
                                                iconAssetPath:
                                                    'assets/svg/barcode.svg',
                                                text: "Scanner",
                                                onPressed: () {
                                                  context.push(
                                                      "/tour/fschargement",
                                                      extra: {
                                                        "onUpdate": onUpdate,
                                                        'tour': widget.tour,
                                                        'packageSearcher':
                                                            packageSearcher,
                                                        "command": command
                                                      });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                controller: _scrollController,
                cacheExtent: 1000,
              ),
            ),
            if (isChargementComplet(widget.tour))
              customButton(
                label: "Valider le chargement",
                onPressed: () {
                  context.go('/tour/validateChargement', extra: {
                    'packageSearcher': packageSearcher,
                    'tour': widget.tour
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
