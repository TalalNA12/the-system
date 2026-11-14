import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SystemEffect { open, questComplete, levelUp, penalty }

class SystemAudio {
  SystemAudio._();

  static final SystemAudio instance = SystemAudio._();

  bool enabled = true;

  final List<AudioPlayer> _activePlayers = [];

  String _soundPath(SystemEffect effect) {
    switch (effect) {
      case SystemEffect.open:
        return 'sounds/system_open.wav';

      case SystemEffect.questComplete:
        return 'sounds/quest_complete.wav';

      case SystemEffect.levelUp:
        return 'sounds/level_up.wav';

      case SystemEffect.penalty:
        return 'sounds/penalty.wav';
    }
  }

  Duration _soundDuration(SystemEffect effect) {
    switch (effect) {
      case SystemEffect.open:
        return const Duration(milliseconds: 2600);

      case SystemEffect.questComplete:
        return const Duration(milliseconds: 2100);

      case SystemEffect.levelUp:
        return const Duration(milliseconds: 4200);

      case SystemEffect.penalty:
        return const Duration(milliseconds: 3100);
    }
  }

  Future<void> play(SystemEffect effect) async {
    if (!enabled) return;

    final player = AudioPlayer();
    _activePlayers.add(player);

    try {
      await player.setVolume(0.65);

      await player.play(AssetSource(_soundPath(effect)));

      debugPrint('Playing System sound: $effect');

      
      
      
      await Future.delayed(_soundDuration(effect));
    } catch (error) {
      debugPrint('System audio error ($effect): $error');
    } finally {
      _activePlayers.remove(player);
      await player.dispose();
    }
  }

  void setMuted(bool muted) {
    enabled = !muted;

    
    if (muted) {
      for (final player in List<AudioPlayer>.from(_activePlayers)) {
        player.stop();
      }
    }
  }
}
