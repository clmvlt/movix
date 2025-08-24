import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/Chargement/index.dart';

class ChargementPage extends StatefulWidget {
  final Tour tour;

  const ChargementPage({super.key, required this.tour});

  @override
  _ChargementPage createState() => _ChargementPage();
}

class _ChargementPage extends State<ChargementPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late String selectedId;
  late PackageSearcher packageSearcher;
  final Map<String, AnimationController> _cardAnimations = {};

  void onUpdate() {
    setState(() {});
  }

  Widget _buildProgressHeader() {
    return const SizedBox.shrink();
  }

  Widget _buildModernCommandCard(Command command, bool isSelected, int index) {
    return ModernCommandCardWidget(
      command: command,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          if (selectedId == command.id) {
            selectedId = "";
          } else {
            selectedId = command.id;
          }
        });
      },
      onUpdate: onUpdate,
      animationController: _cardAnimations[command.id]!,
      tour: widget.tour,
      packageSearcher: packageSearcher,
    );
  }


  @override
  void initState() {
    super.initState();
    showDialogs(context, widget.tour);
    if (widget.tour.commands.isNotEmpty) {
      selectedId = widget.tour.commands.values.last.id;
    }

    packageSearcher = PackageSearcher(widget.tour.commands);
    
    // Initialize animations for each command
    for (var command in widget.tour.commands.values) {
      _cardAnimations[command.id] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _cardAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tour.name,
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              'Chargement en cours',
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () {
            context.go('/tours');
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${countValidCommands(widget.tour)}/${widget.tour.commands.length}',
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 120, left: 8, right: 8),
                  itemCount: widget.tour.commands.length,
                  itemBuilder: (context, index) {
                    final command = widget.tour.commands.values
                        .elementAt(widget.tour.commands.length - 1 - index);
                    final isSelected = selectedId == command.id;
                    
                    // Trigger animations
                    if (isSelected) {
                      _cardAnimations[command.id]?.forward();
                    } else {
                      _cardAnimations[command.id]?.reverse();
                    }

                    return _buildModernCommandCard(command, isSelected, index);
                  },
                  controller: _scrollController,
                  cacheExtent: 1000,
                ),
              ),
            ],
          ),
          if (isChargementComplet(widget.tour))
            Positioned(
              left: 0,
              right: 0,
              bottom: Platform.isIOS ? 16 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: customButton(
                    label: "Valider le chargement",
                    onPressed: () {
                      context.go('/tour/validateChargement', extra: {
                        'packageSearcher': packageSearcher,
                        'tour': widget.tour
                      });
                    },
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
