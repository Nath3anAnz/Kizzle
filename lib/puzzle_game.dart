import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PuzzleGame extends StatefulWidget {
  final String level;
  const PuzzleGame({super.key, required this.level});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final FlutterTts flutterTts = FlutterTts();
  final Map<String, bool> score = {'A': false, 'B': false, 'C': false, 'D': false};

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bermain Level ${widget.level}")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            spacing: 15, runSpacing: 15,
            children: score.keys.map((id) => DragTarget<String>(
              onWillAccept: (data) => data == id,
              onAccept: (data) {
                setState(() => score[id] = true);
                _speak("Mantap!");
              },
              builder: (context, data, rejected) => Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: score[id]! ? Colors.green : Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(score[id]! ? "Sip!" : "?")),
              ),
            )).toList(),
          ),
          const Divider(),
          Wrap(
            spacing: 20,
            children: score.keys.where((id) => score[id] == false).map((id) => Draggable<String>(
              data: id,
              feedback: _box(id, Colors.blue.withOpacity(0.5)),
              child: _box(id, Colors.blue),
            )).toList()..shuffle(),
          ),
          if (score.values.every((v) => v == true))
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Balik ke Map"))
        ],
      ),
    );
  }

  Widget _box(String id, Color color) {
    return Container(
      width: 70, height: 70,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(id, style: const TextStyle(color: Colors.white))),
    );
  }
}