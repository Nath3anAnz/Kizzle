import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'object_matching_reward.dart';
import 'audio_manager.dart';

class ObjectMatchingPuzzle extends StatefulWidget {
  final String level;
  const ObjectMatchingPuzzle({super.key, required this.level});

  @override
  State<ObjectMatchingPuzzle> createState() => _ObjectMatchingPuzzleState();
}

class _ObjectMatchingPuzzleState extends State<ObjectMatchingPuzzle> with SingleTickerProviderStateMixin {
  int _elapsedSeconds = 0;
  Timer? _timer;
  
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _ttsPlayer = AudioPlayer(); 

  late String targetName;
  IconData? targetIcon; 
  String? targetImagePath; 
  String? targetMatchedImagePath; 
  
  late String correctOption;
  IconData? correctIcon;
  
  late String logicalExplanation; 
  late String ttsFileName; 
  List<Map<String, dynamic>> options = [];
  
  bool _isMatched = false;

  late AnimationController _errorAnimController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playGameMusic();
    _setupLevel();
    _setupAnimations();
    _playIntroTts(); 
    _startTimer();
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

  void _setupLevel() {
    List<Map<String, dynamic>> wrongs = [];

    if (widget.level == '1' || widget.level.toLowerCase() == 'easy') {
      // --- LEVEL 1 (KAKI & SEPATU) ---
      targetName = "Kaki";
      targetImagePath = "assets/images/matchshapelvl1/matchkaki.png"; 
      targetMatchedImagePath = "assets/images/matchshapelvl1/matchkakisepatu.png"; 
      
      correctOption = "Sepatu";
      String correctImagePath = "assets/images/matchshapelvl1/matchsepatu.png";
      
      logicalExplanation = "Sepatu dipakai di kaki";
      ttsFileName = "ttslvl1.mp3"; 
      wrongs = [
        {"name": "Topi", "imagePath": "assets/images/matchshapelvl1/matchtopi.png"}, 
        {"name": "Sarung Tangan", "imagePath": "assets/images/matchshapelvl1/matchsarung.png"},
      ];

      options.add({"name": correctOption, "imagePath": correctImagePath});
      options.add({"name": wrongs[0]["name"], "imagePath": wrongs[0]["imagePath"]});
      options.add({"name": wrongs[1]["name"], "imagePath": wrongs[1]["imagePath"]});

    } else if (widget.level == '2' || widget.level.toLowerCase() == 'medium') {
      // --- LEVEL 2 (ES KRIM & CONE) ---
      // Perhatikan foldernya: matchshapelvl3 (sesuai screenshot lu)
      targetName = "Es Krim";
      targetImagePath = "assets/images/matchshapelvl3/object_matching_level2_es_krim.png"; 
      targetMatchedImagePath = "assets/images/matchshapelvl3/object_matching_level2_sukses.png";
      
      correctOption = "Cone";
      String correctImagePath = "assets/images/matchshapelvl3/object_matching_level2_cone.png";
      
      logicalExplanation = "Es krim ditaruh di cone";
      ttsFileName = "ttslvl2.mp3"; 
      wrongs = [
        {"name": "Piring", "imagePath": "assets/images/matchshapelvl3/object_matching_level2_piring.png"},
        {"name": "Kaos Kaki", "imagePath": "assets/images/matchshapelvl3/object_matching_level2_kaos_kaki.png"},
      ];
      
      options.add({"name": correctOption, "imagePath": correctImagePath});
      options.add({"name": wrongs[0]["name"], "imagePath": wrongs[0]["imagePath"]});
      options.add({"name": wrongs[1]["name"], "imagePath": wrongs[1]["imagePath"]});

    } else {
      // --- LEVEL 3 (MOBIL & JALAN) ---
      // Perhatikan foldernya: matchshapelvl2 (sesuai screenshot lu)
      targetName = "Mobil";
      targetImagePath = "assets/images/matchshapelvl2/object_matching_level3_mobil.png"; 
      targetMatchedImagePath = "assets/images/matchshapelvl2/object_matching_level3_sukses.png";
      
      correctOption = "Jalan";
      String correctImagePath = "assets/images/matchshapelvl2/object_matching_level3_jalan.png";
      
      logicalExplanation = "Mobil bergerak di jalanan";
      ttsFileName = "ttslvl3.mp3"; 
      wrongs = [
        {"name": "Laut", "imagePath": "assets/images/matchshapelvl2/object_matching_level3_laut.png"},
        {"name": "Langit", "imagePath": "assets/images/matchshapelvl2/object_matching_level3_langit.png"},
      ];
      
      options.add({"name": correctOption, "imagePath": correctImagePath});
      options.add({"name": wrongs[0]["name"], "imagePath": wrongs[0]["imagePath"]});
      options.add({"name": wrongs[1]["name"], "imagePath": wrongs[1]["imagePath"]});
    }

    options.shuffle();
  }

  void _playIntroTts() async {
    try {
      AudioManager().setBgmVolume(0.2); 
      _ttsPlayer.onPlayerComplete.listen((event) {
        AudioManager().setBgmVolume(1.0);
      });
      await _ttsPlayer.play(AssetSource('audio/$ttsFileName'));
    } catch (e) {
      AudioManager().setBgmVolume(1.0); 
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMatched) setState(() { _elapsedSeconds++; });
    });
  }

  void _playSound(String fileName) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {}
  }

  void _checkAnswer(String droppedName) {
    if (droppedName == correctOption) {
      setState(() { _isMatched = true; }); 
      _playSound('puzzlepas.mp3'); 
      _timer?.cancel();
      _ttsPlayer.stop(); 
      AudioManager().setBgmVolume(1.0); 

      Future.delayed(const Duration(milliseconds: 1200), () { 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ObjectMatchingReward(
              level: widget.level,
              waktu: _elapsedSeconds,
              targetName: targetName,
              correctOption: correctOption,
              logicalExplanation: logicalExplanation,
              matchedImagePath: targetMatchedImagePath, 
              matchedIcon: targetIcon,
            ),
          ),
        );
      });
    } else {
      _playSound('wrong.mp3');
      _errorAnimController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sfxPlayer.dispose();
    _ttsPlayer.dispose(); 
    _errorAnimController.dispose();
    AudioManager().setBgmVolume(1.0); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Object Matching - Level ${widget.level}", style: const TextStyle(fontFamily: 'Jua', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple,
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
              width: double.infinity, height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/background_level.png'), fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                    child: Text("Waktu: ${_elapsedSeconds}s", style: const TextStyle(fontFamily: 'PalanquinDark', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text("Tarik Pasangannya ke Sini!", style: TextStyle(fontFamily: 'Jua', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 5)])),
                  const SizedBox(height: 10),
                  
                  // TARGET ITEM
                  DragTarget<String>(
                    onWillAcceptWithDetails: (details) => !_isMatched,
                    onAcceptWithDetails: (details) {
                      _checkAnswer(details.data);
                    },
                    builder: (context, candidateData, rejectedData) {
                      bool isHovering = candidateData.isNotEmpty;
                      
                      Widget targetDisplay;
                      if (_isMatched) {
                        if (targetMatchedImagePath != null) {
                          targetDisplay = Image.asset(targetMatchedImagePath!, width: 120, height: 120, fit: BoxFit.contain);
                        } else {
                          targetDisplay = const Icon(Icons.check_circle, size: 80, color: Colors.green);
                        }
                      } else {
                        if (targetImagePath != null) {
                          targetDisplay = Image.asset(targetImagePath!, width: 100, height: 100, fit: BoxFit.contain);
                        } else {
                          targetDisplay = Icon(targetIcon, size: 80, color: Colors.purple);
                        }
                      }

                      return Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          color: _isMatched ? Colors.green.shade100 : (isHovering ? Colors.purple.shade50 : Colors.white), 
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isMatched ? Colors.green : (isHovering ? Colors.purple : Colors.purpleAccent), 
                            width: isHovering || _isMatched ? 8 : 5
                          ),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            targetDisplay,
                            const SizedBox(height: 10),
                            Text(
                              _isMatched ? "COCOK!" : targetName, 
                              style: TextStyle(
                                fontFamily: 'Jua',
                                fontSize: 22, 
                                fontWeight: FontWeight.bold, 
                                color: _isMatched ? Colors.green : Colors.black87
                              )
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // PILIHAN JAWABAN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        const Text("Mana pasangannya?", style: TextStyle(fontFamily: 'Jua', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: options.map((opt) {
                            
                            Widget optionDisplay;
                            if (opt.containsKey("imagePath") && opt["imagePath"] != null) {
                              optionDisplay = Image.asset(opt["imagePath"], width: 60, height: 60, fit: BoxFit.contain);
                            } else {
                              optionDisplay = Icon(opt["icon"], size: 45, color: Colors.blueAccent);
                            }

                            Widget optionBox = Container(
                              width: 100, height: 125, 
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  optionDisplay,
                                  const SizedBox(height: 8),
                                  Text(opt["name"], textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontFamily: 'PalanquinDark', fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            );

                            return Draggable<String>(
                              data: opt["name"], 
                              feedback: Material( 
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.1, 
                                  child: optionBox,
                                ),
                              ),
                              childWhenDragging: Opacity( 
                                opacity: 0.3,
                                child: optionBox,
                              ),
                              child: optionBox, 
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
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
}