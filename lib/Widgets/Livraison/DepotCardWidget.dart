import 'package:flutter/material.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Livraison/DepotActionsWidget.dart';

class DepotCardWidget extends StatelessWidget {
  final Command command;
  final bool isSelected;
  final VoidCallback onTap;
  final Tour tour;
  final VoidCallback onUpdate;

  const DepotCardWidget({
    super.key,
    required this.command,
    required this.isSelected,
    required this.onTap,
    required this.tour,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? Globals.COLOR_SURFACE 
                  : Globals.COLOR_SURFACE.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                    : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: _buildDepotHeader(),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: isSelected
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          decoration: BoxDecoration(
                            color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              DepotActionsWidget(
                                tour: tour,
                                onUpdate: onUpdate,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepotHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.home_work,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Globals.profil!.account.societe,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Globals.COLOR_TEXT_DARK,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${Globals.profil!.account.address1} ${Globals.profil!.account.address2}",
                style: TextStyle(
                  fontSize: 13,
                  color: Globals.COLOR_TEXT_DARK_SECONDARY,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}