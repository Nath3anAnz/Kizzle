import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audio_manager.dart';
import 'settings_page.dart';
import 'difficulty_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    AudioManager().playMenuMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
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
          // --- REVISI: Dibungkus Center biar kotaknya diam di tengah layar ---
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ), // Spacing pinggir dilebarin dikit
              child: GridView.count(
                shrinkWrap:
                    true, // <-- INI KUNCINYA: Biar gridnya kumpul di tengah, ga manjang ke atas-bawah
                physics:
                    const NeverScrollableScrollPhysics(), // Dimatiin scrollnya karena cuma 4 kotak
                crossAxisCount: 2,
                crossAxisSpacing:
                    20, // Jarak antar kotak dilebarin dikit biar lega
                mainAxisSpacing: 20,
                childAspectRatio:
                    0.95, // <-- Dibikin nyaris kotak biar ga kepanjangan melar
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Tile Puzzle',
                    icon: Icons.grid_view_rounded,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DifficultyPage(kategori: 'Tile Puzzle'),
                        ),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Match Shape',
                    icon: Icons.category,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DifficultyPage(kategori: 'Match Shape'),
                        ),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Size Sorting',
                    icon: Icons.bar_chart,
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DifficultyPage(kategori: 'Size Sorting'),
                        ),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Object Matching',
                    icon: Icons.extension,
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DifficultyPage(kategori: 'Object Matching'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _heroTagForTitle(String title) {
    if (title == 'Tile Puzzle') return 'hero_tile_game';
    if (title == 'Match Shape') return 'hero_shape_game';
    if (title == 'Size Sorting') return 'hero_size_game';
    if (title == 'Object Matching') return 'hero_object_game';
    return 'hero_${title.toLowerCase().replaceAll(' ', '_')}_game';
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 0,
              offset: const Offset(0, 9),
            ),
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
            const BoxShadow(
              color: Colors.white70,
              blurRadius: 0,
              offset: Offset(-3, -3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 14,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 14,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: _heroTagForTitle(title),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 52, color: color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.4,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 0,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
