import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:movix/Services/globals.dart';

/// Widget overlay qui affiche des effets festifs subtils pour l'anniversaire
class BirthdayOverlay extends StatefulWidget {
  final Widget child;

  const BirthdayOverlay({super.key, required this.child});

  @override
  State<BirthdayOverlay> createState() => _BirthdayOverlayState();
}

class _BirthdayOverlayState extends State<BirthdayOverlay> {
  late ConfettiController _confettiController;
  Timer? _confettiTimer;
  bool _showBanner = true;

  bool get _isBirthday => Globals.profil?.isBirthday() ?? false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    if (_isBirthday) {
      // Lance les confettis au démarrage
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _confettiController.play();
      });

      // Confettis périodiques subtils (toutes les 45 secondes)
      _confettiTimer = Timer.periodic(const Duration(seconds: 45), (_) {
        if (mounted && _isBirthday) {
          _confettiController.play();
        }
      });

      // Cache la bannière après 5 secondes
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showBanner = false);
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBirthday) return widget.child;

    return Stack(
      children: [
        widget.child,

        // Confettis depuis le haut
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // vers le bas
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.03,
            numberOfParticles: 10,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Color(0xFFFFD700), // Or
              Color(0xFFFF69B4), // Rose
              Color(0xFF87CEEB), // Bleu ciel
              Color(0xFF98FB98), // Vert menthe
              Color(0xFFDDA0DD), // Prune
            ],
            createParticlePath: (size) => _drawStar(size),
          ),
        ),

        // Bannière de joyeux anniversaire (temporaire)
        if (_showBanner)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              opacity: _showBanner ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _BirthdayBanner(
                firstName: Globals.profil?.firstName ?? '',
                onClose: () => setState(() => _showBanner = false),
              ),
            ),
          ),
      ],
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * pi / 180;

      final outerPoint = Offset(
        center.dx + radius * cos(outerAngle),
        center.dy + radius * sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    return path;
  }
}

class _BirthdayBanner extends StatelessWidget {
  final String firstName;
  final VoidCallback onClose;

  const _BirthdayBanner({required this.firstName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.9),
            const Color(0xFFFFA500).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎂', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Joyeux anniversaire${firstName.isNotEmpty ? ' $firstName' : ''} !',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Toute l\'équipe Movix te souhaite une excellente journée !',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('🎁', style: TextStyle(fontSize: 24)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une icône cadeau subtile sur les éléments
class BirthdayGiftIcon extends StatelessWidget {
  final double size;

  const BirthdayGiftIcon({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final isBirthday = Globals.profil?.isBirthday() ?? false;
    if (!isBirthday) return const SizedBox.shrink();

    return Text('🎁', style: TextStyle(fontSize: size));
  }
}

/// Widget pour afficher des étoiles/confettis subtils sur certains éléments
class BirthdaySparkle extends StatefulWidget {
  final Widget child;

  const BirthdaySparkle({super.key, required this.child});

  @override
  State<BirthdaySparkle> createState() => _BirthdaySparkleState();
}

class _BirthdaySparkleState extends State<BirthdaySparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _isBirthday => Globals.profil?.isBirthday() ?? false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (_isBirthday) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBirthday) return widget.child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: -4,
          right: -4,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + (_controller.value * 0.5),
                child: Transform.scale(
                  scale: 0.8 + (_controller.value * 0.2),
                  child: const Text('✨', style: TextStyle(fontSize: 12)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
