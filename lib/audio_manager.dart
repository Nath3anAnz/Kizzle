import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer bgmPlayer = AudioPlayer();
  String _currentBgm = '';
  double _volume = 0.5; // Default volume 50%

  double get volume => _volume;
  
  // Buat ngubah volume secara permanen (misal dari Menu Settings)
  Future<void> setVolume(double value) async {
    _volume = value;
    await bgmPlayer.setVolume(_volume); // buat ubah volume
  }

  // --- TAMBAHAN BARU: Buat Audio Ducking (Ngecilin BGM sementara buat TTS) ---
  Future<void> setBgmVolume(double multiplier) async {
    // Multiplier 1.0 = balik ke volume normal (_volume)
    // Multiplier 0.2 = meredup jadi 20% dari volume normal
    await bgmPlayer.setVolume(_volume * multiplier);
  }

  Future<void> playMenuMusic() async {
    if (_currentBgm == 'menu') return; 
    _currentBgm = 'menu';
    await bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await bgmPlayer.setVolume(_volume); // Pasang volume terakhir
    await bgmPlayer.play(AssetSource('audio/homepage_music.mp3'));
  }

  Future<void> playGameMusic() async {
    if (_currentBgm == 'game') return;
    _currentBgm = 'game';
    await bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await bgmPlayer.setVolume(_volume); // Pasang volume terakhir
    await bgmPlayer.play(AssetSource('audio/bgmusic.mp3'));
  }

  Future<void> stopMusic() async {
    _currentBgm = '';
    await bgmPlayer.stop();
  }
}