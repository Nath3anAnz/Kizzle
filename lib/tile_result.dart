import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'categories_page.dart'; 
import 'countdown_page.dart'; 
import 'audio_manager.dart'; 

class TileResult extends StatefulWidget {
  final String level;
  final int waktu;

  const TileResult({
    super.key,
    required this.level,
    required this.waktu,
  });

  @override
  State<TileResult> createState() => _TileResultState();
}

class _TileResultState extends State<TileResult> {
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _stars = _calculateStars();
    _simpanSkor(); // Panggil fungsi simpan skor otomatis
  }
  
  // Fungsi penentu jumlah bintang berdasarkan waktu
  // Tile puzzle mungkin butuh waktu lebih lama, tapi kita pakai standar ini dulu
  int _calculateStars() {
    if (widget.waktu <= 20) return 3; 
    if (widget.waktu <= 40) return 2;
    return 1;
  }

  // --- MESIN PENYIMPAN SKOR KE FIREBASE ---
  Future<void> _simpanSkor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Ambil nama anak dari collection 'users'
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final namaAnak = userDoc.data()?['nama'] ?? 'Pemain Misterius';

        // 2. Tembak datanya ke collection 'leaderboard'
        await FirebaseFirestore.instance.collection('leaderboard').add({
          'uid': user.uid,
          'nama': namaAnak,
          'kategori': 'Tile Puzzle', // Kategori udah disesuaikan!
          'level': widget.level,
          'waktu': widget.waktu,
          'stars': _stars,
          'tanggal': FieldValue.serverTimestamp(), 
        });
        
        debugPrint("Skor Tile Puzzle berhasil disimpan ke Leaderboard!");
      }
    } catch (e) {
      debugPrint("Gagal nyimpen skor: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView( 
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20), 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95), 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Colors.white, 
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.grid_view_rounded, // Ikon Tile Puzzle
                            size: 80, 
                            color: Colors.green // Warna dominan Tile Puzzle
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      const Text(
                        'LEVEL SELESAI!', 
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 15),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Icon(
                            index < _stars ? Icons.star : Icons.star_border,
                            color: Colors.amber, 
                            size: 55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      Text(
                        'Waktu: ${widget.waktu} Detik', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 40), 
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ActionButton(
                              icon: Icons.home, 
                              label: 'Back to\nHome', 
                              color: Colors.redAccent, 
                              onPressed: () {
                                AudioManager().playMenuMusic(); 
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CategoriesPage()), (route) => false);
                              },
                            ),
                          ),
                          Expanded(
                            child: ActionButton(
                              icon: Icons.repeat, 
                              label: 'Repeat\n', 
                              color: Colors.blueAccent, 
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CountdownPage(kategori: 'Tile Puzzle', level: widget.level)));
                              },
                            ),
                          ),
                          Expanded(
                            child: ActionButton(
                              icon: Icons.skip_next, 
                              label: 'Next\nDifficulty', 
                              color: Colors.greenAccent, 
                              onPressed: () {
                                int currentLevel = int.tryParse(widget.level) ?? 1;
                                int nextLevelInt = currentLevel + 1;
                                
                                if (nextLevelInt > 3 || widget.level.toLowerCase() == 'hard') {
                                  AudioManager().playMenuMusic();
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CategoriesPage()), (route) => false);
                                } else {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CountdownPage(kategori: 'Tile Puzzle', level: nextLevelInt.toString())));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.icon, required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60, 
          height: 60,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
          ),
          child: IconButton(icon: Icon(icon, color: Colors.white, size: 30), onPressed: onPressed),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
          textAlign: TextAlign.center, 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}