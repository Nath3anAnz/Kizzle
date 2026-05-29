import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'shape_reward.dart';
import 'audio_manager.dart';

class ShapePuzzle extends StatefulWidget {
  final String level;
  const ShapePuzzle({super.key, required this.level});

  @override
  State<ShapePuzzle> createState() => _ShapePuzzleState();
}

class _ShapePuzzleState extends State<ShapePuzzle>
    with SingleTickerProviderStateMixin {
  List<String> _targetItems = [];
  Map<String, bool> _matchedStatus = {};
  List<String> _shuffledOptions = [];

  Map<String, Alignment> _targetAlignments = {};
  double _siluetSize = 120.0;
  double _puzzleSize = 100.0;

  bool _isWrong = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    AudioManager().playGameMusic();

    _setupLevel();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _setupLevel() {
    List<Alignment> safePoints = [];

    if (widget.level == '1' || widget.level.toLowerCase() == 'easy') {
      _targetItems = ["Singa", "Kelinci", "Gajah"];
      _siluetSize = 130.0;
      _puzzleSize = 110.0;
      safePoints = [
        const Alignment(-0.7, -0.6),
        const Alignment(0.7, -0.2),
        const Alignment(-0.4, 0.7),
      ];
    } else if (widget.level == '2' || widget.level.toLowerCase() == 'medium') {
      _targetItems = ["Sofa", "Kulkas", "Bantal", "Lampu tidur", "Pot bunga"];
      _siluetSize = 110.0;
      _puzzleSize = 95.0;
      safePoints = [
        const Alignment(-0.8, -0.8),
        const Alignment(0.8, -0.7),
        const Alignment(0.0, 0.0),
        const Alignment(-0.8, 0.8),
        const Alignment(0.8, 0.7),
      ];
    } else {
      _targetItems = [
        "Abstrak1",
        "Abstrak2",
        "Abstrak3",
        "Abstrak4",
        "Abstrak5",
        "Abstrak6",
        "Abstrak7",
      ];
      _siluetSize = 100.0;
      _puzzleSize = 90.0;
      safePoints = [
        const Alignment(-0.95, -0.95),
        const Alignment(0.95, -0.85),
        const Alignment(0.0, -0.3),
        const Alignment(-0.95, 0.35),
        const Alignment(0.95, 0.45),
        const Alignment(-0.6, 0.95),
        const Alignment(0.6, 0.95),
      ];
    }

    List<String> shuffledTargetsForPos = List.from(_targetItems)..shuffle();

    for (int i = 0; i < _targetItems.length; i++) {
      String item = _targetItems[i];
      _matchedStatus[item] = false;
    }

    for (int i = 0; i < shuffledTargetsForPos.length; i++) {
      _targetAlignments[shuffledTargetsForPos[i]] = safePoints[i];
    }

    _shuffledOptions = List.from(_targetItems)..shuffle();
  }

  Widget _buildShapeImage(
    String itemName, {
    bool isSilhouette = false,
    double size = 70,
  }) {
    String imagePath = '';

    switch (itemName) {
      case "Singa":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl1/Frame 37.png'
            : 'assets/images/shapelvl1/Frame 35.png';
        break;
      case "Kelinci":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl1/Frame 36.png'
            : 'assets/images/shapelvl1/Frame 33.png';
        break;
      case "Gajah":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl1/Frame 38.png'
            : 'assets/images/shapelvl1/Frame 34.png';
        break;
      case "Sofa":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl2/Sofa.png'
            : 'assets/images/shapelvl2/sofa_shape_matching.png';
        break;
      case "Kulkas":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl2/Kulkas.png'
            : 'assets/images/shapelvl2/kulkas_shape_matching.png';
        break;
      case "Bantal":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl2/Bantal.png'
            : 'assets/images/shapelvl2/bantal_shape_matching.png';
        break;
      case "Lampu tidur":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl2/Lampu tidur.png'
            : 'assets/images/shapelvl2/lampu_shape_matching.png';
        break;
      case "Pot bunga":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl2/Pot tanaman.png'
            : 'assets/images/shapelvl2/bunga_shape_matching.png';
        break;
      case "Abstrak1":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 30.png'
            : 'assets/images/shapelvl3/Frame 19.png';
        break;
      case "Abstrak2":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 26.png'
            : 'assets/images/shapelvl3/Frame 20.png';
        break;
      case "Abstrak3":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 27.png'
            : 'assets/images/shapelvl3/Frame 21.png';
        break;
      case "Abstrak4":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 28.png'
            : 'assets/images/shapelvl3/Frame 22.png';
        break;
      case "Abstrak5":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 29.png'
            : 'assets/images/shapelvl3/Frame 23.png';
        break;
      case "Abstrak6":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 31.png'
            : 'assets/images/shapelvl3/Frame 24.png';
        break;
      case "Abstrak7":
        imagePath = isSilhouette
            ? 'assets/images/shapelvl3/Frame 32.png'
            : 'assets/images/shapelvl3/Frame 25.png';
        break;
    }

    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.broken_image, size: size, color: Colors.grey),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _triggerWrongEffect() async {
    try {
      await AudioManager().playSfx(_sfxPlayer, 'wrong.mp3');
    } catch (e) {}
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);

    setState(() => _isWrong = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isWrong = false);
    });
  }

  void _triggerCorrectEffect() async {
    try {
      await AudioManager().playSfx(_sfxPlayer, 'correct.mp3');
    } catch (e) {}
  }

  void _checkWinCondition() {
    _triggerCorrectEffect();
    bool isAllMatched = _matchedStatus.values.every(
      (matched) => matched == true,
    );

    if (isAllMatched) {
      _timer?.cancel();
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShapeReward(
              level: widget.level,
              targetItem: 'Tamat Level ${widget.level}',
              waktu: _elapsedSeconds,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sfxPlayer.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Match Shape - Level ${widget.level}",
          style: const TextStyle(
            fontFamily: 'Jua',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final sineValue = sin(4 * pi * _shakeController.value);
              return Transform.translate(
                offset: Offset(sineValue * 12, 0),
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_level.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Waktu: ${_elapsedSeconds}s",
                      style: const TextStyle(
                        fontFamily: 'PalanquinDark',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Stack(
                        children: _targetItems.map((targetName) {
                          bool isMatched = _matchedStatus[targetName] ?? false;

                          return Align(
                            alignment: _targetAlignments[targetName]!,
                            child: DragTarget<String>(
                              onWillAccept: (data) => !isMatched,
                              onAccept: (data) {
                                if (data == targetName) {
                                  setState(() {
                                    _matchedStatus[targetName] = true;
                                  });
                                  _checkWinCondition();
                                } else {
                                  _triggerWrongEffect();
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: _siluetSize,
                                  height: _siluetSize,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: _buildShapeImage(
                                      targetName,
                                      isSilhouette: !isMatched,
                                      size: _siluetSize,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const Divider(
                    color: Colors.white,
                    thickness: 3,
                    indent: 40,
                    endIndent: 40,
                  ),
                  const SizedBox(height: 10),

                  // AREA BAWAH YANG BISA DI SCROLL
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Center(
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            alignment: WrapAlignment.center,
                            children: _shuffledOptions.map((option) {
                              bool isMatched = _matchedStatus[option] ?? false;

                              if (isMatched) {
                                return const SizedBox.shrink();
                              }

                              return Draggable<String>(
                                data: option,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: _buildShapeImage(
                                    option,
                                    size: _puzzleSize + 20,
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildShapeImage(
                                    option,
                                    size: _puzzleSize,
                                  ),
                                ),
                                child: Container(
                                  width: _puzzleSize,
                                  height: _puzzleSize,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: _buildShapeImage(
                                      option,
                                      size: _puzzleSize,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _isWrong ? 0.4 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
