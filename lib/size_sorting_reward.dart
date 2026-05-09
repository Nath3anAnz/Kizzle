import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'size_sorting_result.dart'; 

class SizeSortingReward extends StatefulWidget {
  final String level;
  final int waktu;

  const SizeSortingReward({super.key, required this.level, required this.waktu});

  @override
  State<SizeSortingReward> createState() => _SizeSortingRewardState();
}

class _SizeSortingRewardState extends State<SizeSortingReward> {
  final AudioPlayer _completePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playRewardSequence();
  }

  void _playRewardSequence() async {
    try {
      await _completePlayer.play(AssetSource('audio/complete.mp3'));
    } catch (e) {
      debugPrint("Audio belum ready: $e");
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
                child: const Center(
                  // Ikon sementara sebelum aset turun
                  child: Icon(Icons.bar_chart, size: 150, color: Colors.orange),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                "Urutan Sempurna!", 
                style: TextStyle(
                  fontSize: 32, 
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
                  _completePlayer.stop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SizeSortingResult(
                        level: widget.level,
                        waktu: widget.waktu,
                      ),
                    ),
                  );
                },
                child: const Text("LANJUT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}