import 'package:audioplayers/audioplayers.dart';
import 'package:eleicao/src/injector.dart';

enum AudioFiles {
  tecla('tecla.mov'),
  confirma('confirma.mov');

  const AudioFiles(this.name);
  final String name;

  void play() {
    soundPlayer.play(this);
  }
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
