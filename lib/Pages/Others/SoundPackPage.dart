import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/sound.dart';

class SoundPackPage extends StatefulWidget {
  final SoundPack soundPack;

  const SoundPackPage({super.key, required this.soundPack});

  @override
  State<SoundPackPage> createState() => _SoundPackPageState();
}

class _SoundPackPageState extends State<SoundPackPage> {
  String? _currentlyPlaying;
  late AudioPlayer _audioPlayer;

  final List<SoundItem> _sounds = [
    SoundItem(
      name: 'Succès',
      description: 'Son joué lors d\'un scan réussi',
      fileName: 'success',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    SoundItem(
      name: 'Erreur',
      description: 'Son joué lors d\'une erreur de scan',
      fileName: 'error',
      icon: Icons.error,
      color: Colors.red,
    ),
    SoundItem(
      name: 'Terminé',
      description: 'Son joué quand une tâche est terminée',
      fileName: 'finish',
      icon: Icons.flag,
      color: Colors.blue,
    ),
    SoundItem(
      name: 'Changement',
      description: 'Son joué lors d\'un changement de mode',
      fileName: 'switch',
      icon: Icons.swap_horiz,
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // Écouter la fin des sons pour réinitialiser l'état
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlaying = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(
          'Pack ${widget.soundPack.name}',
          style: TextStyle(color: Globals.COLOR_TEXT_LIGHT),
        ),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _stopAllSounds(),
            tooltip: 'Arrêter tous les sons',
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => _playAllSounds(),
            tooltip: 'Écouter tout le pack',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec informations du pack
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_MOVIX.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.music_note,
                    size: 32,
                    color: Globals.COLOR_ADAPTIVE_ACCENT,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.soundPack.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Globals.COLOR_TEXT_DARK,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pack de sons personnalisé',
                  style: TextStyle(
                    fontSize: 14,
                    color: Globals.COLOR_TEXT_GRAY,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des sons
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final sound = _sounds[index];
                final isPlaying = _currentlyPlaying == sound.fileName;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    color: Globals.COLOR_SURFACE,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sound.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          sound.icon,
                          color: sound.color,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        sound.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                      ),
                      subtitle: Text(
                        sound.description,
                        style: TextStyle(
                          color: Globals.COLOR_TEXT_GRAY,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: isPlaying
                            ? Globals.COLOR_ADAPTIVE_ACCENT
                            : Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            color: isPlaying
                              ? Colors.white
                              : Globals.COLOR_ADAPTIVE_ACCENT,
                          ),
                          onPressed: () => _playSound(sound),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _playSound(SoundItem sound) async {
    if (_currentlyPlaying == sound.fileName) {
      // Arrêter le son en cours
      try {
        await _audioPlayer.stop();
      } catch (_) {}

      setState(() {
        _currentlyPlaying = null;
      });
      return;
    }

    // Vérifier le mode silencieux (mais pas SOUND_ENABLED car c'est la preview)
    if (!await canPlaySound(ignoreSoundEnabled: true)) {
      return;
    }

    // Arrêter tout son en cours avant de jouer le nouveau
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    setState(() {
      _currentlyPlaying = sound.fileName;
    });

    try {
      final path = 'sounds/${widget.soundPack.name.toLowerCase()}/${sound.fileName}.mp3';
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentlyPlaying = null;
        });
      }
    }
  }

  Future<void> _playAllSounds() async {
    // Vérifier le mode silencieux (mais pas SOUND_ENABLED car c'est la preview)
    if (!await canPlaySound(ignoreSoundEnabled: true)) {
      return;
    }

    final sounds = ['success', 'error', 'finish', 'switch'];

    // Arrêter tout son en cours
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    setState(() {
      _currentlyPlaying = null;
    });

    for (final sound in sounds) {
      try {
        await _audioPlayer.stop();
        final path = 'sounds/${widget.soundPack.name.toLowerCase()}/$sound.mp3';
        await _audioPlayer.play(AssetSource(path));

        // Attendre que le son se termine avant de jouer le suivant
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      } catch (_) {}
    }
  }

  Future<void> _stopAllSounds() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    
    setState(() {
      _currentlyPlaying = null;
    });
  }
}

class SoundItem {
  final String name;
  final String description;
  final String fileName;
  final IconData icon;
  final Color color;

  SoundItem({
    required this.name,
    required this.description,
    required this.fileName,
    required this.icon,
    required this.color,
  });
} 