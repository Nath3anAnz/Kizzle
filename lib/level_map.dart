import 'package:flutter/material.dart';
import 'puzzle_game.dart';

class LevelMapPage extends StatelessWidget {
  const LevelMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Levelmu", style: TextStyle(fontFamily: 'Jua')), 
        backgroundColor: Colors.orange,
      ),
      // INI DIA KUNCINYA: Membungkus dengan background gambar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_level.png'), // Manggil gambar lu
            fit: BoxFit.cover, // Biar gambarnya ditarik menutupi seluruh layar
          ),
        ),
        // Isi tombol-tombolnya ada di atas gambar
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                _buildLevelNode(context, "1", Alignment.centerLeft, true),
                _buildLine(Alignment.centerLeft),
                _buildLevelNode(context, "2", Alignment.center, false),
                _buildLine(Alignment.center),
                _buildLevelNode(context, "3", Alignment.centerRight, false),
                _buildLine(Alignment.centerRight),
                _buildLevelNode(context, "4", Alignment.center, false),
                _buildLine(Alignment.center),
                _buildLevelNode(context, "5", Alignment.centerLeft, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelNode(BuildContext context, String label, Alignment align, bool isUnlocked) {
    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: GestureDetector(
          onTap: () {
            if (isUnlocked) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PuzzleGame(level: label)));
            }
          },
          child: CircleAvatar(
            radius: 35,
            backgroundColor: isUnlocked ? Colors.orange : Colors.grey,
            child: Text(label, style: const TextStyle(fontFamily: 'Jua', fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // Modifikasi: Warnanya jadi putih transparan biar kelihatan di background gelap lu
  Widget _buildLine(Alignment align) {
    return Align(
      alignment: align,
      child: Container(
        width: 5, 
        height: 40, 
        color: Colors.white70, // <-- Berubah di sini
        margin: const EdgeInsets.symmetric(horizontal: 60)
      ),
    );
  }
}