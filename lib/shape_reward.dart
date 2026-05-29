import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart';
import 'shape_result.dart';

class ShapeReward extends StatefulWidget {
  final String level;
  final String targetItem;
  final int waktu;

  const ShapeReward({
    super.key,
    required this.level,
    required this.targetItem,
    required this.waktu,
  });

  @override
  State<ShapeReward> createState() => _ShapeRewardState();
}

class _ShapeRewardState extends State<ShapeReward> {
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playRewardSound();
  }

  void _playRewardSound() async {
    try {
      await AudioManager().playSfx(_sfxPlayer, 'complete.mp3');
    } catch (e) {
      debugPrint("Audio belum ready: $e");
    }
  }

  String get _kategoriName {
    if (widget.level == '1' || widget.level.toLowerCase() == 'easy')
      return 'Hewan';
    if (widget.level == '2' || widget.level.toLowerCase() == 'medium')
      return 'Perabotan';
    if (widget.level == '3' || widget.level.toLowerCase() == 'hard')
      return 'Bentuk';
    return 'Hebat';
  }

  Widget _buildCategoryIcon() {
    if (widget.level == '1' || widget.level.toLowerCase() == 'easy') {
      return const Icon(Icons.pets, size: 150, color: Colors.orange);
    } else if (widget.level == '2' || widget.level.toLowerCase() == 'medium') {
      return const Icon(Icons.weekend, size: 150, color: Colors.teal);
    } else if (widget.level == '3' || widget.level.toLowerCase() == 'hard') {
      return const Icon(Icons.category, size: 150, color: Colors.blueAccent);
    }
    return const Icon(Icons.star, size: 150, color: Colors.amber);
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
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
                  shadows: [Shadow(color: Colors.white, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 30),

              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(child: _buildCategoryIcon()),
              ),
              const SizedBox(height: 20),

              Text(
                _kategoriName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                ),
              ),

              const SizedBox(height: 60),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _sfxPlayer.stop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShapeResult(level: widget.level, waktu: widget.waktu),
                    ),
                  );
                },
                child: const Text(
                  "LANJUT",
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
