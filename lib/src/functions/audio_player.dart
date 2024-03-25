import 'package:audioplayers/audioplayers.dart';

enum AudioFiles {
  tecla('tecla.mov'),
  confirma('confirma.mov');

  const AudioFiles(this.name);
  final String name;
}

abstract class SoundPlayer {
  void play(AudioFiles audio);
}

class SoundPlayerImpl implements SoundPlayer {
  final player = AudioPlayer();

  @override
  Future<void> play(AudioFiles audio) async {
    await player.play(AssetSource('sounds/${audio.name}'));
  }
}
