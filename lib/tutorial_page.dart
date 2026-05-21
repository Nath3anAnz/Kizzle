import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with SingleTickerProviderStateMixin {
  final int _totalStories = 13;
  int _currentIndex = 0;
  late AnimationController _animationController;
  
  final List<String> _images = List.generate(13, (index) => 'assets/images/tut$index.png');

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < _totalStories - 1) {
      setState(() {
        _currentIndex++;
        _animationController.reset();
        _animationController.forward();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (details) {
            _animationController.stop(); 
          },
          onTapUp: (details) {
            _animationController.forward(); 
            
            final double screenWidth = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < screenWidth / 3) {
              _prevStory();
            } else {
              _nextStory();
            }
          },
          onTapCancel: () => _animationController.forward(),
          onLongPress: () => _animationController.stop(),
          onLongPressEnd: (_) => _animationController.forward(),
          child: Stack(
            children: [
              // --- KITA PAKE COLUMN BIAR LAYOUTNYA RAPI (TIDAK SALING TINDIH) ---
              Column(
                children: [
                  // 1. GARIS PROGRESS MERAH DI PALING ATAS
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 12, right: 12, bottom: 15),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Row(
                          children: List.generate(_totalStories, (index) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: index < _currentIndex
                                        ? 1.0 
                                        : (index == _currentIndex ? _animationController.value : 0.0), 
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red), 
                                    backgroundColor: Colors.white.withOpacity(0.35),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),

                  // 2. GAMBAR FIGMA LU (Pake Expanded biar ngelebar maksimal ke bawah)
                  Expanded(
                    child: Image.asset(
                      _images[_currentIndex],
                      fit: BoxFit.contain, // <--- KUNCI ANTI GEPENG: Kembali pakai contain!
                      width: double.infinity, // Paksa mentok ujung layar tanpa ngerusak rasio
                    ),
                  ), 
                 // Paksa ngelebar se-proporsional mungkin
                      
                  const SizedBox(height: 10), // Dikasih jarak bawah dikit biar lega
                ],
              ),

              // 3. PANAH KIRI KANAN
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black.withOpacity(0.2), // Gua ubah jadi item transparan biar keliatan di atas gambar lu yang warnanya putih
                        size: 45,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black.withOpacity(0.2),
                        size: 45,
                      ),
                    ],
                  ),
                ),
              ),

              // 4. TOMBOL EXIT (X) DI KANAN ATAS
              Positioned(
                top: 40, // Turun dikit sejajar sama atas gambar
                right: 20, 
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); 
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25), 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26, 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}