import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'object_matching_result.dart'; 

class ObjectMatchingReward extends StatefulWidget {
  final String level;
  final int waktu;
  final String targetName;
  final String correctOption;
  final String logicalExplanation; 
  
  // Data gambar/icon dari halaman puzzle
  final String? matchedImagePath; 
  final IconData? matchedIcon;    

  const ObjectMatchingReward({
    super.key, 
    required this.level, 
    required this.waktu, 
    required this.targetName, 
    required this.correctOption,
    required this.logicalExplanation,
    this.matchedImagePath,
    this.matchedIcon,
  });

  @override
  State<ObjectMatchingReward> createState() => _ObjectMatchingRewardState();
}

class _ObjectMatchingRewardState extends State<ObjectMatchingReward> {
  final AudioPlayer _completePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playRewardSequence();
  }

  void _playRewardSequence() async {
    try {
      // Pastikan file complete.mp3 sudah ada di folder assets/audio/
      await _completePlayer.play(AssetSource('audio/complete.mp3'));
    } catch (e) {
      debugPrint("Gagal memutar audio complete: $e");
    }
  }

  @override
  void dispose() {
    _completePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          // Background konsisten dengan halaman game
          image: DecorationImage(image: AssetImage('assets/images/background_level.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul Reward
              const Text(
                "PINTAR!", 
                style: TextStyle(
                  fontSize: 52, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.orange, 
                  shadows: [Shadow(color: Colors.white, blurRadius: 15)]
                )
              ),
              const SizedBox(height: 30),
              
              // --- REVISI: CONTAINER LINGKARAN DENGAN CLIP OVAL ---
              Container(
                width: 220, // Ukuran lingkaran putih
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95), 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), 
                      blurRadius: 20, 
                      offset: const Offset(0, 10)
                    )
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 180, // Ukuran gambar di dalam
                    height: 180,
                    child: ClipOval( // <--- INI KUNCINYA: Memotong gambar jadi bulat sempurna
                      child: widget.matchedImagePath != null
                          ? Image.asset(
                              widget.matchedImagePath!, 
                              fit: BoxFit.cover, // Memastikan gambar memenuhi lingkaran
                            )
                          : Icon(
                              widget.matchedIcon ?? Icons.check_circle, 
                              size: 120, 
                              color: Colors.green
                            ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Penjelasan Logika (TTS Narator)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  widget.logicalExplanation, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)]
                  )
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Tombol Lanjut
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), 
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  elevation: 8,
                ),
                onPressed: () {
                  _completePlayer.stop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObjectMatchingResult(level: widget.level, waktu: widget.waktu),
                    ),
                  );
                },
                child: const Text(
                  "LANJUT", 
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}