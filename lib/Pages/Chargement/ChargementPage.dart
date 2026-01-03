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

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Globals.COLOR_SURFACE,
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'reorder':
            context.push('/tour/reorder', extra: {
              'tour': widget.tour,
              'onOrderChanged': () {
                if (mounted) setState(() {});
              },
            });
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'reorder',
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.reorder,
                    color: Globals.COLOR_ADAPTIVE_ACCENT,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Réorganiser la tournée',
                        style: TextStyle(
                          color: Globals.COLOR_TEXT_DARK,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Modifier l\'ordre des commandes',
                        style: TextStyle(
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.3),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert,
          color: Globals.COLOR_TEXT_LIGHT,
          size: 20,
        ),
      ),
    );
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
        title: Text(
          widget.tour.name,
          style: TextStyle(
            color: Globals.COLOR_TEXT_LIGHT,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildPopupMenu(),
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
                      context.push('/tour/validateChargement', extra: {
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
