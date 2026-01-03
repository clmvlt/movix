import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:movix/Models/Sound.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import 'globals.dart';

enum SoundPack {
  Basic,
  Mario,
  Minecraft,
  Pokemon,
  StreetFighter,
}

final AudioPlayer _audioPlayer = AudioPlayer();
bool _audioContextConfigured = false;

/// Vérifie si le son peut être joué
/// [ignoreSoundEnabled] : true pour la preview (ignore le paramètre utilisateur)
Future<bool> canPlaySound({bool ignoreSoundEnabled = false}) async {
  // 1. Vérifier le paramètre utilisateur (sauf si preview)
  if (!ignoreSoundEnabled && !Globals.SOUND_ENABLED) {
    return false;
  }

  // 2. Vérifier le mode silencieux du système
  try {
    final ringerStatus = await SoundMode.ringerModeStatus;
    if (ringerStatus == RingerModeStatus.silent ||
        ringerStatus == RingerModeStatus.vibrate) {
      return false;
    }
  } catch (_) {
    // Si erreur (iOS ou autre), on laisse le AudioContext gérer
  }

  return true;
}

Future<void> _configureAudioContext() async {
  if (_audioContextConfigured) return;

  if (Platform.isIOS) {
    await _audioPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));
  } else if (Platform.isAndroid) {
    await _audioPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        audioMode: AndroidAudioMode.normal,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.notification,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));
  }

  _audioContextConfigured = true;
}

Future<void> playSound(ScanResult result) async {
    if (!await canPlaySound()) return;

    await _configureAudioContext();

    final path = switch (result) {
      ScanResult.SCAN_SUCCESS =>
        'sounds/${Globals.SOUND_PACK.name.toLowerCase()}/success.mp3',
      ScanResult.SCAN_ERROR =>
        'sounds/${Globals.SOUND_PACK.name.toLowerCase()}/error.mp3',
      ScanResult.SCAN_FINISH =>
        'sounds/${Globals.SOUND_PACK.name.toLowerCase()}/finish.mp3',
      ScanResult.SCAN_SWITCH =>
        'sounds/${Globals.SOUND_PACK.name.toLowerCase()}/switch.mp3',
      ScanResult.NOTHING => null,
    };

    if (path == null) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (_) {}
  }

Future<void> playCustomSound(String soundFileName) async {
  if (!await canPlaySound()) return;

  await _configureAudioContext();

  final path = 'sounds/${Globals.SOUND_PACK.name.toLowerCase()}/$soundFileName.mp3';

  try {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
  } catch (_) {}
}

Future<void> playCustomSoundFromPack(SoundPack pack, String soundFileName, {bool isPreview = false}) async {
  if (!await canPlaySound(ignoreSoundEnabled: isPreview)) return;

  await _configureAudioContext();

  final path = 'sounds/${pack.name.toLowerCase()}/$soundFileName.mp3';

  try {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
  } catch (_) {}
}

Future<SoundPack> getSoundPack() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  SoundPack soundPack = stringToSoundPack(prefs.getString('sound_pack') ?? "");

  return soundPack;
}

Future<void> setSoundPack(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  SoundPack soundPack = stringToSoundPack(value);
  prefs.setString('sound_pack', soundPack.name);
  Globals.SOUND_PACK = soundPack;
}

SoundPack stringToSoundPack(String value) {
  return SoundPack.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SoundPack.Basic,
  );
}

Future<void> playAllSoundsFromPack(SoundPack pack) async {
  final sounds = ['success', 'error', 'finish', 'switch'];
  
  for (final sound in sounds) {
    try {
      await _audioPlayer.stop();
      await playCustomSoundFromPack(pack, sound);
      await Future<void>.delayed(const Duration(seconds: 1));
    } catch (_) {}
  }
}