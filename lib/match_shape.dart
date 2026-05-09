import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MatchShape extends StatefulWidget {
  final String level;
  const MatchShape({super.key, required this.level});

  @override
  State<MatchShape> createState() => _MatchShapeState();
}

class _MatchShapeState extends State<MatchShape> {
  String _targetItem = ""; 
  List<String> _options = []; 
  bool _isMatched = false; 

  int _elapsedSeconds = 0;
  Timer? _timer;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _setupLevel();
    _startTimer();
  }

  void _setupLevel() {
    if (widget.level == '1') {
      _targetItem = "Singa"; 
      _options = ["Kelinci", "Singa", "Gajah"]; 
    } else if (widget.level == '2') {
      _targetItem = "Sofa"; 
      _options = ["Kulkas", "Sofa", "Bantal"];
    } else if (widget.level == '3') {
      _targetItem = "Segitiga"; // Gua ganti ke segitiga biar ikonnya jelas
      _options = ["Segitiga", "Lingkaran", "Kotak"];
    }
    _options.shuffle(); 
  }

  // --- HELPER BUAT NAMPILIN BENTUK (SHAPE) SEMENTARA TANPA ASSET ---
  IconData _getShapeIcon(String itemName) {
    switch (itemName) {
      // Level 1: Hewan
      case "Singa": return Icons.pets; 
      case "Kelinci": return Icons.cruelty_free;
      case "Gajah": return Icons.bug_report; // Anggap aja gajah wkwk
      // Level 2: Perabotan
      case "Sofa": return Icons.chair;
      case "Kulkas": return Icons.kitchen;
      case "Bantal": return Icons.bed;
      // Level 3: Bentuk
      case "Segitiga": return Icons.change_history;
      case "Lingkaran": return Icons.circle;
      case "Kotak": return Icons.square;
      default: return Icons.star;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _triggerWrongEffect() async {
    try { await _sfxPlayer.play(AssetSource('audio/wrong.mp3')); } catch (e) {}
  }

  void _triggerCorrectEffect() async {
    try { await _sfxPlayer.play(AssetSource('audio/correct.mp3')); } catch (e) {}
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
      appBar: AppBar(
        title: Text("Match Shape - Level ${widget.level}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/background_level.png'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
              child: Text("Waktu: ${_elapsedSeconds}s", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            
            const Spacer(),

            // --- LUBANG TARGET (SILUET) ---
            DragTarget<String>(
              onWillAccept: (data) => !_isMatched, 
              onAccept: (data) {
                if (data == _targetItem) {
                  setState(() { _isMatched = true; });
                  _triggerCorrectEffect();
                  _timer?.cancel();
                  
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text("BENAR! 🎉"),
                      content: Text("Kamu menyelesaikan dalam ${_elapsedSeconds} detik!"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); 
                            Navigator.pop(context); 
                          },
                          child: const Text("OK"),
                        )
                      ],
                    )
                  );
                } else {
                  _triggerWrongEffect();
                }
              },
              builder: (context, candidateData, rejectedData) {
                // REVISI: BUKAN KOTAK LAGI, TAPI SILUET BENTUKNYA LANGSUNG
                return SizedBox(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: _isMatched 
                      ? Icon(_getShapeIcon(_targetItem), size: 150, color: Colors.blue) // Kalau bener warnanya nyala
                      : Icon(_getShapeIcon(_targetItem), size: 150, color: Colors.black26), // Kalau belum, warnanya abu-abu (Siluet)
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(color: Colors.white, thickness: 3, indent: 30, endIndent: 30),
            const SizedBox(height: 20),

            // --- PILIHAN JAWABAN (DRAGGABLE) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _options.map((option) => _buildDraggableItem(option)).toList(),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableItem(String itemName) {
    if (_isMatched && itemName == _targetItem) {
      return const SizedBox(width: 100, height: 100); 
    }

    return Draggable<String>(
      data: itemName,
      // Saat ditarik, bentuknya ngikutin jari
      feedback: Material(
        color: Colors.transparent,
        child: Icon(_getShapeIcon(itemName), size: 100, color: Colors.blueAccent.withOpacity(0.8)),
      ),
      // Bayangan yang ditinggal pas ditarik
      childWhenDragging: SizedBox(
        width: 100, height: 100,
        child: Icon(_getShapeIcon(itemName), size: 100, color: Colors.black12),
      ),
      // REVISI: Bentuk asli di bawah, tanpa kotak
      child: SizedBox(
        width: 100, height: 100,
        child: Icon(_getShapeIcon(itemName), size: 100, color: Colors.orange),
      ),
    );
  }
}