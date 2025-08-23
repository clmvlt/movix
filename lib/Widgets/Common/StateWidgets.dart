import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({
    super.key,
    this.message = 'Chargement...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Globals.COLOR_MOVIX),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Globals.COLOR_TEXT_SECONDARY,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.title = 'Erreur de chargement',
    required this.message,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Globals.COLOR_MOVIX_RED.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Globals.COLOR_MOVIX_RED,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Globals.COLOR_TEXT_DARK,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Globals.COLOR_TEXT_SECONDARY,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;

  const EmptyStateWidget({
    super.key,
    this.title = 'Aucune donnée disponible',
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Globals.COLOR_TEXT_SECONDARY,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Globals.COLOR_TEXT_DARK,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Globals.COLOR_TEXT_SECONDARY,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}