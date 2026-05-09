import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'categories_page.dart'; 
import 'settings_page.dart'; // Buat Halaman Settings
import 'audio_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AudioManager().playMenuMusic();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_level.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Buat Tombol Settings
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.blueAccent, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ),
              ),
              
              // --- KONTEN TENGAH ---
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 180, 
                      child: Image.asset(
                        'assets/images/kizzle_logo.png', // Pastiin sesuai nama logo lu
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 60), 
                    
                    // --- TOMBOL PLAY ---
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5, 
                        ),
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const CategoriesPage())
                          );
                        },
                        child: const Text("PLAY", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // --- TOMBOL EXIT GAME ---
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252), 
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        onPressed: () {
                          SystemNavigator.pop(); 
                        },
                        child: const Text("EXIT GAME", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}