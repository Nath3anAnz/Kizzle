import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tile_result.dart'; 

class TileReward extends StatefulWidget {
  final String level;
  final int waktu;

  const TileReward({super.key, required this.level, required this.waktu});

  @override
  State<TileReward> createState() => _TileRewardState();
}

class _TileRewardState extends State<TileReward> {
  // Bikin 2 player biar ga tabrakan, satu buat 'Tadaa', satu buat 'Meong/Ngeeng'
  final AudioPlayer _completePlayer = AudioPlayer();
  final AudioPlayer _itemSfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playRewardSequence();
  }

  // NENTUIN NAMA BENDA
  String get _itemName {
    if (widget.level == '1' || widget.level.toLowerCase() == 'easy') return 'Kucing';
    if (widget.level == '2' || widget.level.toLowerCase() == 'medium') return 'Jam';
    if (widget.level == '3' || widget.level.toLowerCase() == 'hard') return 'Mobil';
    return 'Kucing'; 
  }

  // NENTUIN GAMBAR 
  String get _imagePath {
    if (widget.level == '1' || widget.level.toLowerCase() == 'easy') return 'assets/images/tilelvl1/easy_picture_full.png';
    if (widget.level == '2' || widget.level.toLowerCase() == 'medium') return 'assets/images/tilelvl2/medium_picture_full.png';
    if (widget.level == '3' || widget.level.toLowerCase() == 'hard') return 'assets/images/tilelvl3/hard_picture_full.PNG';
    return 'assets/images/tilelvl1/easy_picture_full.png'; 
  }

  // NENTUIN SUARA BENDA
  String get _audioPath {
    if (widget.level == '1' || widget.level.toLowerCase() == 'easy') return 'audio/kucing.mp3';
    if (widget.level == '2' || widget.level.toLowerCase() == 'medium') return 'audio/jam.mp3';
    if (widget.level == '3' || widget.level.toLowerCase() == 'hard') return 'audio/car.mp3';
    return 'audio/kucing.mp3'; 
  }

  // MUTAR SUARA BERURUTAN
  void _playRewardSequence() async {
    try {
      // 1. Play suara "Tadaaa!" (complete.mp3) dulu
      await _completePlayer.play(AssetSource('audio/complete.mp3'));
      
      // Tunggu bentar (misal 1.5 detik, sesuaikan sama panjang durasi complete.mp3 lu)
      // Biar nggak numpuk suaranya. Kalo dirasa terlalu lama, turunin jadi 1000 (1 dtk).
      await Future.delayed(const Duration(milliseconds: 1500)); 
      
      // 2. Kalau halaman belum ditutup, play suara bendanya (Meong/Ngeeng)
      if (mounted) {
        await _itemSfxPlayer.play(AssetSource(_audioPath));
      }
    } catch (e) {
      debugPrint("Audio belum ready: $e");
    }
  }

  @override
  void dispose() {
    _completePlayer.dispose();
    _itemSfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_level.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "PINTAR!", 
                style: TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 48, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.orange, 
                  shadows: [Shadow(color: Colors.white, blurRadius: 10)]
                )
              ),
              const SizedBox(height: 30),
              
              Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95), 
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Center(
                  child: Image.asset(
                    _imagePath, 
                    width: 160, 
                    height: 160, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                _itemName, 
                style: const TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 36, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white, 
                  shadows: [Shadow(color: Colors.black45, blurRadius: 5)]
                )
              ),
              
              const SizedBox(height: 60),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), 
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                onPressed: () {
                  // Biar kalau tombol ditekan duluan, suaranya mati
                  _completePlayer.stop();
                  _itemSfxPlayer.stop();
                  
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TileResult(
                        level: widget.level,
                        waktu: widget.waktu,
                      ),
                    ),
                  );
                },
                child: const Text("LANJUT", style: TextStyle(fontFamily: 'Jua', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}