import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show ImageFilter;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audio_manager.dart';
import 'settings_page.dart';
import 'difficulty_page.dart';
import 'tutorial_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

/// Internal model for a game category loaded from Firestore.
class _GameCategory {
  final String name;
  final String iconName;
  final String colorHex;
  final int order;

  _GameCategory({
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.order,
  });
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<_GameCategory> _categories = [];
  bool _isLoading = true;

  /// Fallback categories when Firestore is unavailable or returns no active data.
  static final List<_GameCategory> _fallbackCategories = [
    _GameCategory(
      name: 'Tile Puzzle',
      iconName: 'grid_view_rounded',
      colorHex: '#4CAF50',
      order: 1,
    ),
    _GameCategory(
      name: 'Match Shape',
      iconName: 'category',
      colorHex: '#2196F3',
      order: 2,
    ),
    _GameCategory(
      name: 'Size Sorting',
      iconName: 'bar_chart',
      colorHex: '#FF9800',
      order: 3,
    ),
    _GameCategory(
      name: 'Object Matching',
      iconName: 'extension',
      colorHex: '#9C27B0',
      order: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AudioManager().playMenuMusic();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('game_categories')
          .orderBy('order')
          .get();

      if (!mounted) return;

      final categories = querySnapshot.docs
          .where((doc) => doc.data()['is_active'] == true)
          .map((doc) {
            final data = doc.data();
            return _GameCategory(
              name: data['name'] as String? ?? '',
              iconName: data['icon_name'] as String? ?? '',
              colorHex: data['color_hex'] as String? ?? '',
              order: data['order'] as int? ?? 0,
            );
          })
          .where((cat) => cat.name.isNotEmpty)
          .toList();

      if (categories.isEmpty) {
        _applyFallback();
        return;
      }

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _applyFallback();
    }
  }

  void _applyFallback() {
    setState(() {
      _categories = _fallbackCategories;
      _isLoading = false;
    });
  }

  /// Map a Firestore icon_name string to an IconData.
  IconData _mapIconName(String iconName) {
    switch (iconName) {
      case 'grid_view_rounded':
        return Icons.grid_view_rounded;
      case 'category':
        return Icons.category;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'extension':
        return Icons.extension;
      default:
        return Icons.star;
    }
  }

  /// Parse a hex color string (e.g. "#4CAF50") to a Color.
  /// Returns [Colors.orange] if parsing fails.
  Color _parseHexColor(String hex) {
    try {
      final colorString = hex.replaceFirst('#', '');
      if (colorString.length != 6) return Colors.orange;
      final intValue = int.parse('FF$colorString', radix: 16);
      return Color(intValue);
    } catch (e) {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Kategori',
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_level.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.95,
                          children: _categories.map((cat) {
                            return _buildCategoryCard(
                              context,
                              title: cat.name,
                              icon: _mapIconName(cat.iconName),
                              color: _parseHexColor(cat.colorHex),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DifficultyPage(kategori: cat.name),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 5,
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.5),
                  barrierDismissible: true,
                  barrierLabel: 'Tutorial',
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: const TutorialPage(),
                    );
                  },
                  transitionBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                );
              },
              child: const Icon(Icons.question_mark, color: Colors.blue),
            ),
          ),
        ],
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
                      fontFamily: 'Jua',
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
