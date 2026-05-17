import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'countdown_page.dart';
import 'leaderboard_page.dart';

class DifficultyPage extends StatelessWidget {
  final String kategori;
  const DifficultyPage({super.key, required this.kategori});

  // --- HELPER BUAT MILIH IKON OTOMATIS SESUAI NAMA GAME ---
  IconData _getCategoryIcon() {
    if (kategori == 'Tile Puzzle') return Icons.grid_view_rounded;
    if (kategori == 'Match Shape') return Icons.category;
    if (kategori == 'Size Sorting') return Icons.align_vertical_bottom_rounded;
    if (kategori == 'Object Matching') return Icons.extension;
    return Icons.star;
  }

  // --- HELPER BUAT MILIH WARNA IKON OTOMATIS BIAR MATCHING ---
  Color _getCategoryColor() {
    if (kategori == 'Tile Puzzle') return Colors.green;
    if (kategori == 'Match Shape') return Colors.blue;
    if (kategori == 'Size Sorting') return Colors.orange;
    if (kategori == 'Object Matching') return Colors.purple;
    return Colors.grey;
  }

  String _heroTag() {
    if (kategori == 'Tile Puzzle') return 'hero_tile_game';
    if (kategori == 'Match Shape') return 'hero_shape_game';
    if (kategori == 'Size Sorting') return 'hero_size_game';
    if (kategori == 'Object Matching') return 'hero_object_game';
    return 'hero_${kategori.toLowerCase().replaceAll(' ', '_')}_game';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Difficulty",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardPage(kategori: kategori),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // --- IKON DINAMIS DI DALEM LINGKARAN PUTIH ---
                Hero(
                  tag: _heroTag(),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(),
                          size: 60,
                          color: _getCategoryColor(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  kategori,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- TOMBOL LEVEL (Ngelmpar '1', '2', '3' ke Countdown) ---
                _buildDiffButton(context, "Easy", Colors.green, '1', 1),
                const SizedBox(height: 20),
                _buildDiffButton(context, "Medium", Colors.blue, '2', 2),
                const SizedBox(height: 20),
                _buildDiffButton(context, "Hard", Colors.redAccent, '3', 3),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiffButton(
    BuildContext context,
    String title,
    Color color,
    String levelStr,
    int filledStars,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // --- RUTENYA AMAN KE COUNTDOWN DULU ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CountdownPage(kategori: kategori, level: levelStr),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < filledStars ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 30,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
