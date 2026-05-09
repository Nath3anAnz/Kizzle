import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; 
import 'tile_reward.dart'; 
import 'audio_manager.dart';

class TilePuzzle extends StatefulWidget {
  final String level;
  const TilePuzzle({super.key, required this.level});

  @override
  State<TilePuzzle> createState() => _TilePuzzleState();
}

class _TilePuzzleState extends State<TilePuzzle> with SingleTickerProviderStateMixin {
  
  late int _columns;
  late int _totalPieces;
  late String _folderName;
  late String _fullImageName;
  
  Map<String, bool> score = {};
  List<String> _shuffledPieces = [];

  Timer? _timer;
  int _elapsedSeconds = 0;
  final AudioPlayer _sfxPlayer = AudioPlayer(); 
  final AudioPlayer _correctSfxPlayer = AudioPlayer(); 

  late AnimationController _errorAnimController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    AudioManager().playGameMusic();
    super.initState();
    _setupLevelConfig(); 
    _startTimer(); 
    _startBgm(); 
    _setupAnimations();
  }

  void _startBgm() async {
    try {
    } catch (e) {
      debugPrint("BGM aman.");
    }
  }

  void _setupAnimations() {
    _errorAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flashAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.0), weight: 1),
    ]).animate(_errorAnimController);
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: 0.0), weight: 1),
    ]).animate(_errorAnimController);
  }

  void _triggerWrongEffect() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/wrong.mp3'));
    } catch (e) {
      debugPrint("SFX Wrong aman.");
    }
    _errorAnimController.forward(from: 0.0);
  }

  void _triggerCorrectEffect() async {
    try {
      await _correctSfxPlayer.stop(); 
      await _correctSfxPlayer.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      debugPrint("SFX Correct aman.");
    }
  }

  void _setupLevelConfig() {
    if (widget.level == '1') {
      _columns = 3;
      _totalPieces = 9;
      _folderName = 'tilelvl1'; 
      _fullImageName = 'easy_picture_full.png'; 
    } else if (widget.level == '2') {
      _columns = 4;
      _totalPieces = 16;
      _folderName = 'tilelvl2'; 
      _fullImageName = 'medium_picture_full.png'; 
    } else if (widget.level == '3') {
      // --- CONFIG LEVEL 3 (MOBIL 6x6) ---
      _columns = 6;
      _totalPieces = 36;
      _folderName = 'tilelvl3'; 
      _fullImageName = 'hard_picture_full.PNG'; 
    }

    for (int i = 1; i <= _totalPieces; i++) {
      score[i.toString()] = false;
    }
    _shuffledPieces = score.keys.toList()..shuffle();
  }

  String _getPieceImageName(String id) {
    int intId = int.parse(id);
    int r = ((intId - 1) ~/ _columns) + 1; 
    int c = ((intId - 1) % _columns) + 1;
    if (widget.level == '1') {
      return 'assets/images/$_folderName/easy_piece_r${r}_c${c}.jpg';
    } else if (widget.level == '2') {
      return 'assets/images/$_folderName/medium_piece_r${r}_c${c}.jpg';
    } else if (widget.level == '3') {
      // --- NAMA FILE MOBIL JPG ---
      return 'assets/images/$_folderName/hard_piece_r${r}_c${c}.jpg';
    }
    return 'assets/images/$_folderName/piece_$id.png';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
 
    _sfxPlayer.dispose();
    _correctSfxPlayer.dispose(); 
    _errorAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- KUNCI FIX 1: NGITUNG ASPECT RATIO BIAR GRID PRESISI ---
    int rows = _totalPieces ~/ _columns;
    double gridAspectRatio = _columns / rows;

    return Scaffold(
      appBar: AppBar(
        title: Text("Main Tile Puzzle - Level ${widget.level}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0), 
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              height: double.infinity, 
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/background_level.png'), fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10), 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "Waktu: ${_elapsedSeconds}s", 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  Expanded(
                    flex: 6, 
                    // --- KUNCI FIX 2: BUNGKUS PAKAI CENTER BIAR NGA KETARIK MELAR ---
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15), 
                        // --- KUNCI FIX 3: ASPECT RATIO DINAMIS SESUAI JUMLAH KOLOM/BARIS ---
                        child: AspectRatio(
                          aspectRatio: gridAspectRatio, 
                          child: Container(
                            padding: const EdgeInsets.all(4), 
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8), 
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white, width: 3), 
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Opacity(
                                      opacity: 0.3, 
                                      child: Image.asset(
                                        'assets/images/$_folderName/$_fullImageName', 
                                        fit: BoxFit.fill, 
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(child: Text("Gambar\nBelum Pas", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(), 
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _columns, 
                                      mainAxisSpacing: 1, 
                                      crossAxisSpacing: 1,
                                      childAspectRatio: 1.0, 
                                    ),
                                    itemCount: _totalPieces,
                                    itemBuilder: (context, index) {
                                      return _buildDragTarget((index + 1).toString());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), 
                  const Divider(color: Colors.white, thickness: 3, indent: 30, endIndent: 30),
                  const SizedBox(height: 10), 

                  Expanded(
                    flex: 4, 
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Wrap(
                          spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
                          children: _shuffledPieces.where((id) => score[id] == false).map((id) => _buildDraggable(id)).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          IgnorePointer(
            child: AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _flashAnimation.value,
                  child: Container(color: Colors.redAccent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragTarget(String id) {
    return DragTarget<String>(
      onWillAccept: (data) => true, 
      onAccept: (data) {
        if (data == id) {
          setState(() => score[id] = true);
          _triggerCorrectEffect();

          if (score.values.every((v) => v == true)) {
            _timer?.cancel();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => TileReward(level: widget.level, waktu: _elapsedSeconds) 
                ));
              }
            });
          }
        } else {
          _triggerWrongEffect(); 
        }
      },
      builder: (context, data, rejected) {
        if (score[id]!) {
          return Image.asset(
            _getPieceImageName(id), 
            fit: BoxFit.fill, 
            errorBuilder: (context, error, stackTrace) => _buildMissingAssetBox(),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
            ),
          );
        }
      },
    );
  }

  Widget _buildDraggable(String id) {
    double pieceSize = MediaQuery.of(context).size.width / (_columns + 2.5);
    return Draggable<String>(
      data: id,
      feedback: Opacity(
        opacity: 0.85, 
        child: Container(
          decoration: BoxDecoration(boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 4))]),
          child: Image.asset(
            _getPieceImageName(id), 
            width: pieceSize + 15, height: pieceSize + 15, fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => _buildMissingAssetBox(size: pieceSize + 15),
          ),
        )
      ),
      childWhenDragging: Container(width: pieceSize, height: pieceSize, color: Colors.transparent),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), 
        child: Image.asset(
          _getPieceImageName(id), 
          width: pieceSize, height: pieceSize, fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) => _buildMissingAssetBox(size: pieceSize),
        ),
      ),
    );
  }

  Widget _buildMissingAssetBox({double? size}) {
    return Container(width: size, height: size, color: Colors.grey.shade300, child: const Center(child: Text("Aset\nBelum\nAda", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.black54))));
  }
}