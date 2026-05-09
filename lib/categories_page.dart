import 'package:flutter/material.dart';
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
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
              padding: const EdgeInsets.symmetric(horizontal: 25.0), // Spacing pinggir dilebarin dikit
              child: GridView.count(
                shrinkWrap: true, // <-- INI KUNCINYA: Biar gridnya kumpul di tengah, ga manjang ke atas-bawah
                physics: const NeverScrollableScrollPhysics(), // Dimatiin scrollnya karena cuma 4 kotak
                crossAxisCount: 2, 
                crossAxisSpacing: 20, // Jarak antar kotak dilebarin dikit biar lega
                mainAxisSpacing: 20,
                childAspectRatio: 0.95, // <-- Dibikin nyaris kotak biar ga kepanjangan melar
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Tile Puzzle',
                    icon: Icons.grid_view_rounded,
                    color: const Color(0xFF4CAF50), 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DifficultyPage(kategori: 'Tile Puzzle')));
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Match Shape',
                    icon: Icons.category,
                    color: const Color(0xFF2196F3), 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DifficultyPage(kategori: 'Match Shape')));
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Size Sorting',
                    icon: Icons.bar_chart,
                    color: const Color(0xFFFF9800), 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DifficultyPage(kategori: 'Size Sorting')));
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Object Matching',
                    icon: Icons.extension,
                    color: const Color(0xFF9C27B0), 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DifficultyPage(kategori: 'Object Matching')));
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

  Widget _buildCategoryCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 4), 
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}