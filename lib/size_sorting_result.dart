import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahan buat Database
import 'package:firebase_auth/firebase_auth.dart'; // Tambahan buat ID User
import 'categories_page.dart';
import 'countdown_page.dart';
import 'audio_manager.dart';

class SizeSortingResult extends StatefulWidget {
  final String level;
  final int waktu;

  const SizeSortingResult({
    super.key,
    required this.level,
    required this.waktu,
  });

  @override
  State<SizeSortingResult> createState() => _SizeSortingResultState();
}

class _SizeSortingResultState extends State<SizeSortingResult> {
  int _stars = 0;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _stars = _calculateStars();
    _simpanSkor(); // Panggil fungsi simpan skor otomatis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.lightImpact();
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Fungsi penentu jumlah bintang berdasarkan waktu
  int _calculateStars() {
    if (widget.waktu <= 15) return 3;
    if (widget.waktu <= 30) return 2;
    return 1;
  }

  // --- MESIN PENYIMPAN SKOR KE FIREBASE ---
  Future<void> _simpanSkor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Ambil nama anak dari collection 'users'
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final namaAnak = userDoc.data()?['nama'] ?? 'Pemain Misterius';

        // 2. Tembak datanya ke collection 'leaderboard'
        await FirebaseFirestore.instance.collection('leaderboard').add({
          'uid': user.uid,
          'nama': namaAnak,
          'kategori': 'Size Sorting', // Kategori udah disesuaikan!
          'level': widget.level,
          'waktu': widget.waktu,
          'stars': _stars,
          'tanggal': FieldValue.serverTimestamp(),
        });

        debugPrint("Skor Size Sorting berhasil disimpan ke Leaderboard!");
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.bar_chart,
                            size: 100,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        'LEVEL SELESAI!',
                        style: TextStyle(
                          fontFamily: 'Jua',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Icon(
                            index < _stars
                                ? Icons.star
                                : Icons.star_border, // Pakai variabel _stars
                            color: Colors.amber,
                            size: 55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text(
                        'Waktu: ${widget.waktu} Detik',
                        style: const TextStyle(
                          fontFamily: 'PalanquinDark',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
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
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CategoriesPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ActionButton(
                              icon: Icons.repeat,
                              label: 'Repeat\n',
                              color: Colors.blueAccent,
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CountdownPage(
                                      kategori: 'Size Sorting',
                                      level: widget.level,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ActionButton(
                              icon: Icons.skip_next,
                              label: 'Next\nDifficulty',
                              color: Colors.greenAccent,
                              onPressed: () {
                                int currentLevel =
                                    int.tryParse(widget.level) ?? 1;
                                int nextLevelInt = currentLevel + 1;

                                if (nextLevelInt > 3 ||
                                    widget.level.toLowerCase() == 'hard') {
                                  AudioManager().playMenuMusic();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoriesPage(),
                                    ),
                                    (route) => false,
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CountdownPage(
                                        kategori: 'Size Sorting',
                                        level: nextLevelInt.toString(),
                                      ),
                                    ),
                                  );
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.25,
              colors: const [
                Colors.orange,
                Colors.amber,
                Colors.blueAccent,
                Colors.greenAccent,
                Colors.pinkAccent,
              ],
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

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 30),
            onPressed: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PalanquinDark',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
