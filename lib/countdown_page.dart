import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'home_page.dart';
import 'tile_puzzle.dart';
import 'shape_puzzle.dart'; 
import 'size_sorting_puzzle.dart'; // <--- IMPORT GAME BARUNYA DISINI
import 'audio_manager.dart'; 
import 'object_matching_puzzle.dart';

class CountdownPage extends StatefulWidget {
  final String kategori;
  final String level;

  const CountdownPage({super.key, required this.kategori, required this.level});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int _counter = 3;
  String _displayText = "3";
  Timer? _timer;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    AudioManager().stopMusic(); 
    
    _playSound("3"); 
    _startCountdown();
  }

  void _playSound(String text) async {
    try {
      await _sfxPlayer.stop(); 
      
      if (text == "3") {
        await _sfxPlayer.play(AssetSource('audio/3.mp3'));
      } else if (text == "2") {
        await _sfxPlayer.play(AssetSource('audio/2.mp3'));
      } else if (text == "1") {
        await _sfxPlayer.play(AssetSource('audio/1.mp3'));
      } else if (text == "GO!") {
        await _sfxPlayer.play(AssetSource('audio/go.mp3'));
      }
    } catch (e) {
      debugPrint("Audio $text gagal diputar, aman.");
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 1) {
          _counter--;
          _displayText = _counter.toString();
          _playSound(_displayText); 
        } else if (_counter == 1) {
          _counter--;
          _displayText = "GO!";
          _playSound(_displayText); 
        } else {
          _timer?.cancel();
          _navigateToGame();
        }
      });
    });
  }

  // --- REVISI: NAMBAHIN JALUR BUAT SIZE SORTING ---
  void _navigateToGame() {
    if (widget.kategori == 'Tile Puzzle') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TilePuzzle(level: widget.level)),
      );
    } else if (widget.kategori == 'Match Shape') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShapePuzzle(level: widget.level)), 
      );
    } else if (widget.kategori == 'Size Sorting') { 
      // Nah ini dia tiket masuknya!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SizeSortingPuzzle(level: widget.level)), 
      );
    } else if (widget.kategori == 'Object Matching') { 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ObjectMatchingPuzzle(level: widget.level)));  

    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              _displayText,
              key: ValueKey<String>(_displayText),
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: _displayText == "GO!" ? 100 : 150,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(4, 4))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}