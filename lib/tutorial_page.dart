import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialItem {
  final String imagePath;
  final Duration duration;

  _TutorialItem({required this.imagePath, required this.duration});
}

class _TutorialPageState extends State<TutorialPage>
    with SingleTickerProviderStateMixin {
  List<_TutorialItem> _tutorials = [];
  int _totalStories = 0;
  int _currentIndex = 0;
  late AnimationController _animationController;
  bool _isLoading = true;

  static const int _fallbackTotalStories = 13;
  static const Duration _fallbackDuration = Duration(seconds: 4);

  List<_TutorialItem> get _fallbackTutorials {
    return List.generate(
      _fallbackTotalStories,
      (index) => _TutorialItem(
        imagePath: 'assets/images/tut$index.png',
        duration: _fallbackDuration,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _fallbackDuration,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _loadTutorials();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTutorials() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tutorials')
          .orderBy('order')
          .get();

      if (!mounted) return;

      final tutorials = querySnapshot.docs
          .where((doc) => doc.data()['is_active'] == true)
          .map((doc) {
        final data = doc.data();
        final imagePath = data['image_path'] as String? ?? '';
        final durationSeconds = data['duration'] as int? ?? 4;
        return _TutorialItem(
          imagePath: imagePath,
          duration: Duration(seconds: durationSeconds),
        );
      }).where((item) => item.imagePath.isNotEmpty).toList();

      if (tutorials.isEmpty) {
        _applyFallback();
        return;
      }

      if (!mounted) return;

      setState(() {
        _tutorials = tutorials;
        _totalStories = tutorials.length;
        _isLoading = false;
        _currentIndex = 0;
        _animationController.duration =
            tutorials.isNotEmpty ? tutorials[0].duration : _fallbackDuration;
        _animationController.reset();
        _animationController.forward();
      });
    } catch (_) {
      if (!mounted) return;
      _applyFallback();
    }
  }

  void _applyFallback() {
    setState(() {
      _tutorials = _fallbackTutorials;
      _totalStories = _fallbackTotalStories;
      _isLoading = false;
      _currentIndex = 0;
      _animationController.duration = _fallbackDuration;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _nextStory() {
    if (_currentIndex < _totalStories - 1) {
      setState(() {
        _currentIndex++;
        _animationController.reset();
        _animationController.duration = _tutorials[_currentIndex].duration;
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
        _animationController.duration = _tutorials[_currentIndex].duration;
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildTutorial(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildTutorial() {
    return GestureDetector(
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
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 15, left: 12, right: 12, bottom: 15),
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
                                    : (index == _currentIndex
                                        ? _animationController.value
                                        : 0.0),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.red),
                                backgroundColor: Colors.white.withValues(alpha: 0.35),
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
              Expanded(
                child: Image.asset(
                  _tutorials[_currentIndex].imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black.withValues(alpha: 0.2),
                    size: 45,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black.withValues(alpha: 0.2),
                    size: 45,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
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
    );
  }
}
