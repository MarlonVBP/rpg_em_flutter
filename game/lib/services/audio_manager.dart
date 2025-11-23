import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  final AudioPlayer _musicPlayer = AudioPlayer();

  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicPlaying = false;
  double _musicVolume = 0.1;
  double _sfxVolume = 0.4;

  AudioManager._internal();

  Future<void> playMusic(String fileName) async {
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/$fileName'));

    _isMusicPlaying = true;
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  Future<void> playSfx(String fileName) async {
    if (_sfxPlayer.state == PlayerState.playing) {
      await _sfxPlayer.stop();
    }

    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _sfxPlayer.play(AssetSource('sounds/$fileName'));
  }

  Future<void> setVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }
}
