import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'countdown_page.dart';
import 'leaderboard_page.dart';

class DifficultyPage extends StatefulWidget {
  final String kategori;
  const DifficultyPage({super.key, required this.kategori});

  @override
  State<DifficultyPage> createState() => _DifficultyPageState();
}

/// Internal model for a difficulty level loaded from Firestore.
class _DifficultyItem {
  final String difficultyName;
  final String level;
  final String buttonColorHex;
  final int starsDisplay;
  final int difficultyOrder;

  _DifficultyItem({
    required this.difficultyName,
    required this.level,
    required this.buttonColorHex,
    required this.starsDisplay,
    required this.difficultyOrder,
  });
}

class _DifficultyPageState extends State<DifficultyPage> {
  List<_DifficultyItem> _levels = [];
  bool _isLoading = true;

  /// Hardcoded fallback when Firestore is unavailable or returns no active data.
  static final List<_DifficultyItem> _fallbackLevels = [
    _DifficultyItem(
      difficultyName: 'Easy',
      level: '1',
      buttonColorHex: '#4CAF50',
      starsDisplay: 1,
      difficultyOrder: 1,
    ),
    _DifficultyItem(
      difficultyName: 'Medium',
      level: '2',
      buttonColorHex: '#2196F3',
      starsDisplay: 2,
      difficultyOrder: 2,
    ),
    _DifficultyItem(
      difficultyName: 'Hard',
      level: '3',
      buttonColorHex: '#FF5252',
      starsDisplay: 3,
      difficultyOrder: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Levels')
          .orderBy('difficulty_order')
          .get();

      if (!mounted) return;

      final levels = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['category_name'] == widget.kategori &&
                data['is_active'] == true;
          })
          .map((doc) {
            final data = doc.data();
            final buttonColorHex = data['button_color_hex'] as String? ?? '';
            final starsDisplay = data['stars_display'] as int? ?? 1;
            return _DifficultyItem(
              difficultyName: data['difficulty_name'] as String? ?? 'Unknown',
              level: data['level'] as String? ?? '1',
              buttonColorHex: buttonColorHex,
              starsDisplay: starsDisplay,
              difficultyOrder: data['difficulty_order'] as int? ?? 0,
            );
          })
          .toList();

      if (!mounted) return;

      if (levels.isEmpty) {
        _applyFallback();
        return;
      }

      setState(() {
        _levels = levels;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _applyFallback();
    }
  }

  void _applyFallback() {
    setState(() {
      _levels = _fallbackLevels;
      _isLoading = false;
    });
  }

  /// Parse hex color from Firestore, falling back by difficulty name on failure.
  Color _buttonColor(_DifficultyItem item) {
    final hex = item.buttonColorHex;
    if (hex.isNotEmpty) {
      final buffer = StringBuffer();
      if (hex.startsWith('#')) {
        buffer.write('FF');
        buffer.write(hex.substring(1));
      } else {
        buffer.write('FF');
        buffer.write(hex);
      }
      final colorInt = int.tryParse(buffer.toString(), radix: 16);
      if (colorInt != null) return Color(colorInt);
    }
    // Fallback by difficulty name
    final name = item.difficultyName;
    if (name == 'Easy') return Colors.green;
    if (name == 'Medium') return Colors.blue;
    if (name == 'Hard') return Colors.redAccent;
    return Colors.orange;
  }

  // --- HELPERS FROM ORIGINAL ---

  IconData _getCategoryIcon() {
    if (widget.kategori == 'Tile Puzzle') return Icons.grid_view_rounded;
    if (widget.kategori == 'Match Shape') return Icons.category;
    if (widget.kategori == 'Size Sorting')
      return Icons.align_vertical_bottom_rounded;
    if (widget.kategori == 'Object Matching') return Icons.extension;
    return Icons.star;
  }

  Color _getCategoryColor() {
    if (widget.kategori == 'Tile Puzzle') return Colors.green;
    if (widget.kategori == 'Match Shape') return Colors.blue;
    if (widget.kategori == 'Size Sorting') return Colors.orange;
    if (widget.kategori == 'Object Matching') return Colors.purple;
    return Colors.grey;
  }

  String _heroTag() {
    if (widget.kategori == 'Tile Puzzle') return 'hero_tile_game';
    if (widget.kategori == 'Match Shape') return 'hero_shape_game';
    if (widget.kategori == 'Size Sorting') return 'hero_size_game';
    if (widget.kategori == 'Object Matching') return 'hero_object_game';
    return 'hero_${widget.kategori.toLowerCase().replaceAll(' ', '_')}_game';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Difficulty",
          style: TextStyle(
            fontFamily: 'Jua',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                  builder: (context) =>
                      LeaderboardPage(kategori: widget.kategori),
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
                  widget.kategori,
                  style: const TextStyle(
                    fontFamily: 'Jua',
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

                // --- LOADING STATE ---
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                // --- DIFFICULTY BUTTONS ---
                else
                  ..._levels.map((item) {
                    final color = _buttonColor(item);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildDiffButton(
                        context,
                        item.difficultyName,
                        color,
                        item.level,
                        item.starsDisplay,
                      ),
                    );
                  }),

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CountdownPage(kategori: widget.kategori, level: levelStr),
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
                  fontFamily: 'Jua',
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
