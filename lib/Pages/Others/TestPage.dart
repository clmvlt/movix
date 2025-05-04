import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:movix/Services/globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SoundTestPage(),
    );
  }
}

class SoundTestPage extends StatefulWidget {
  const SoundTestPage({super.key});

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  final AudioPlayer player = AudioPlayer();

  Future<void> _playSound() async {
    try {
      await player.stop();
      await player.play(AssetSource('sounds/basic/scan_success1.mp3'));
      print('✅ Son joué avec succès');
    } catch (e) {
      print('❌ Erreur lors de la lecture du son: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text('Test Audio'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _playSound,
          child: const Text('Jouer le son'),
        ),
      ),
    );
  }
}
