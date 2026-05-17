import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // <--- IMPORT LOGIN PAGE LU DI SINI

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progressValue = 0.0;
  int _percentage = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  // --- LOGIKA SIMULASI LOADING ---
  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progressValue >= 1.0) {
          timer.cancel();

          // <--- LOMPAT KE LOGIN PAGE SETELAH LOADING 100%
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LoginPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              ),
            );
          }
        } else {
          _progressValue += 0.01;
          _percentage = (_progressValue * 100).toInt();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loading_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),

                // <--- NAMA FILE LOGO UDAH DIBENERIN DI SINI
                Image.asset('assets/images/kizzle_logo.png', width: 220),

                const Spacer(),

                // TEKS PERSENTASE & STATUS
                Text(
                  "($_percentage%) Building the games...",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 15),

                // PROGRESS BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    height: 25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _progressValue,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // QUOTE DI BAGIAN BAWAH
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "when life gives you apple, you take it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
