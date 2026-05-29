import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'size_sorting_reward.dart';
import 'audio_manager.dart';

class SizeSortingPuzzle extends StatefulWidget {
  final String level;
  const SizeSortingPuzzle({super.key, required this.level});

  @override
  State<SizeSortingPuzzle> createState() => _SizeSortingPuzzleState();
}

class _SizeSortingPuzzleState extends State<SizeSortingPuzzle> {
  List<int> _bars = [];
  int _elapsedSeconds = 0;
  Timer? _timer;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    AudioManager().playGameMusic();
    _setupLevel();
    _startTimer();
  }

  void _setupLevel() {
    int barCount = 6;
    if (widget.level == '2' || widget.level.toLowerCase() == 'medium') {
      barCount = 10;
    } else if (widget.level == '3' || widget.level.toLowerCase() == 'hard') {
      barCount = 14;
    }

    _bars = List.generate(barCount, (index) => index + 1);

    _bars.shuffle();
    while (_isSorted()) {
      _bars.shuffle();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  bool _isSorted() {
    for (int i = 0; i < _bars.length - 1; i++) {
      if (_bars[i] > _bars[i + 1]) return false;
    }
    return true;
  }

  void _playSound(String fileName) async {
    try {
      await _sfxPlayer.stop();
      await AudioManager().playSfx(_sfxPlayer, fileName);
    } catch (e) {
      debugPrint("Gagal muter suara: $e");
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final int item = _bars.removeAt(oldIndex);
      _bars.insert(newIndex, item);

      if (_bars[newIndex] == newIndex + 1) {
        _playSound('correct.mp3');
      } else {
        _playSound('wrong.mp3');
      }
    });

    if (_isSorted()) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SizeSortingReward(level: widget.level, waktu: _elapsedSeconds),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> barColors = [
      Colors.redAccent,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pinkAccent,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.brown,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Size Sorting - Level ${widget.level}",
          style: const TextStyle(
            fontFamily: 'Jua',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
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
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Urutkan dari yang Terpendek ➡️ Tertinggi",
                style: TextStyle(
                  fontFamily: 'Jua',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 40),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double marginHorizontal = _bars.length >= 10 ? 2.0 : 4.0;
                    double totalMargin = (marginHorizontal * 2) * _bars.length;
                    double barWidth =
                        (constraints.maxWidth - totalMargin - 5) / _bars.length;

                    return ReorderableListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      // --- KUNCI 1: MATIIN HOLD / LONG PRESS ---
                      buildDefaultDragHandles: false,
                      onReorder: _onReorder,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: Transform.scale(scale: 1.05, child: child),
                        );
                      },
                      children: [
                        for (int i = 0; i < _bars.length; i++)
                          // --- KUNCI 2: BIKIN BALOKNYA BISA LANGSUNG DISERET ---
                          ReorderableDragStartListener(
                            key: ValueKey(_bars[i]),
                            index: i,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: marginHorizontal,
                              ),
                              width: barWidth,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height:
                                      (_bars[i] *
                                      (constraints.maxHeight / _bars.length)),
                                  decoration: BoxDecoration(
                                    color:
                                        barColors[_bars[i] % barColors.length],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                    border: Border.all(
                                      color: Colors.black12,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _bars[i].toString(),
                                      style: TextStyle(
                                        fontFamily: 'PalanquinDark',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: _bars.length >= 10 ? 12 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
