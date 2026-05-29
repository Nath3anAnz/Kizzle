import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  static const String _musicVolumeKey = 'musicVolume';
  static const String _sfxVolumeKey = 'sfxVolume';
  static const String _voiceVolumeKey = 'voiceVolume';

  final AudioPlayer bgmPlayer = AudioPlayer();
  final Map<AudioPlayer, StreamSubscription<void>> _voiceCompleteSubscriptions =
      {};

  String _currentBgm = '';
  double _musicVolume = 0.5;
  double _sfxVolume = 0.5;
  double _voiceVolume = 0.5;
  double _bgmDuckMultiplier = 1.0;
  Future<void>? _loadFuture;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;

  // Backward-compatible alias for old code that only knew one BGM volume.
  double get volume => _musicVolume;

  Future<void> init() async {
    await _ensureInitialized();
  }

  Future<void> _ensureInitialized() {
    _loadFuture ??= _loadVolumes();
    return _loadFuture!;
  }

  Future<void> _loadVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = prefs.getDouble(_musicVolumeKey) ?? _musicVolume;
    _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? _sfxVolume;
    _voiceVolume = prefs.getDouble(_voiceVolumeKey) ?? _voiceVolume;
    await _applyBgmVolume();
  }

  double _clampVolume(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }

  Future<void> _saveVolume(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> _applyBgmVolume() async {
    await bgmPlayer.setVolume(_musicVolume * _bgmDuckMultiplier);
  }

  Future<void> setMusicVolume(double value) async {
    await _ensureInitialized();
    _musicVolume = _clampVolume(value);
    await _applyBgmVolume();
    await _saveVolume(_musicVolumeKey, _musicVolume);
  }

  Future<void> setSfxVolume(double value) async {
    await _ensureInitialized();
    _sfxVolume = _clampVolume(value);
    await _saveVolume(_sfxVolumeKey, _sfxVolume);
  }

  Future<void> setVoiceVolume(double value) async {
    await _ensureInitialized();
    _voiceVolume = _clampVolume(value);
    await _saveVolume(_voiceVolumeKey, _voiceVolume);
  }

  Future<void> setVolume(double value) async {
    await setMusicVolume(value);
  }

  // Buat audio ducking: kecilkan BGM sementara saat instruksi/voice berjalan.
  Future<void> setBgmVolume(double multiplier) async {
    await _ensureInitialized();
    _bgmDuckMultiplier = _clampVolume(multiplier);
    await _applyBgmVolume();
  }

  Future<void> playSfx(
    AudioPlayer player,
    String fileName, {
    bool stopFirst = false,
  }) async {
    await _ensureInitialized();
    if (stopFirst) {
      await player.stop();
    }
    await player.setVolume(_sfxVolume);
    await player.play(AssetSource('audio/$fileName'));
  }

  Future<void> playVoice(
    AudioPlayer player,
    String fileName, {
    bool stopFirst = false,
    bool duckBgm = true,
    double duckMultiplier = 0.2,
  }) async {
    await _ensureInitialized();

    if (stopFirst) {
      await player.stop();
    }

    await _voiceCompleteSubscriptions[player]?.cancel();
    if (duckBgm) {
      await setBgmVolume(duckMultiplier);
      _voiceCompleteSubscriptions[player] = player.onPlayerComplete.listen((_) {
        setBgmVolume(1.0);
      });
    }

    try {
      await player.setVolume(_voiceVolume);
      await player.play(AssetSource('audio/$fileName'));
    } catch (_) {
      if (duckBgm) {
        await cancelVoiceDucking(player);
      }
      rethrow;
    }
  }

  Future<void> stopVoice(AudioPlayer player) async {
    await _voiceCompleteSubscriptions[player]?.cancel();
    _voiceCompleteSubscriptions.remove(player);
    await player.stop();
    await setBgmVolume(1.0);
  }

  Future<void> cancelVoiceDucking(AudioPlayer player) async {
    await _voiceCompleteSubscriptions[player]?.cancel();
    _voiceCompleteSubscriptions.remove(player);
    await setBgmVolume(1.0);
  }

  Future<void> playMenuMusic() async {
    await _ensureInitialized();
    if (_currentBgm == 'menu') return;
    _currentBgm = 'menu';
    await bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _applyBgmVolume();
    await bgmPlayer.play(AssetSource('audio/homepage_music.mp3'));
  }

  Future<void> playGameMusic() async {
    await _ensureInitialized();
    if (_currentBgm == 'game') return;
    _currentBgm = 'game';
    await bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _applyBgmVolume();
    await bgmPlayer.play(AssetSource('audio/bgmusic.mp3'));
  }

  Future<void> stopMusic() async {
    _currentBgm = '';
    await bgmPlayer.stop();
  }
}
