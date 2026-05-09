import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'audio_manager.dart'; 
import 'login_email.dart'; // Sesuaikan kalau nama file login lu beda

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentVolume = 0.5; // Default tengah-tengah

  @override
void initState() {
  super.initState();
  // Baris pemanggil AudioManager dihapus biar nggak error
}

  // FUNGSI LOG OUT
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      
      // Matikan lagu kalau logout (opsional, hapus kalau gak mau)
      AudioManager().stopMusic(); 

      if (context.mounted) {
        // Lempar balik ke halaman login dan hapus semua history halaman sebelumnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginEmailPage()), 
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Gagal Log Out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background biar senada sama game
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9), // Efek kaca/transparan dikit
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- BAGIAN VOLUME ---
                      const Icon(Icons.volume_up_rounded, size: 60, color: Colors.orange),
                      const SizedBox(height: 15),
                      const Text(
                        "Volume Musik", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      const SizedBox(height: 10),
                      
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor: Colors.orange.shade100,
                          thumbColor: Colors.orangeAccent,
                          overlayColor: Colors.orange.withValues(alpha: 0.2),
                          trackHeight: 8.0,
                        ),
                        child: Slider(
                          value: _currentVolume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            setState(() {
                              _currentVolume = value;
                            });
                            AudioManager().setVolume(value); // Update volume secara real-time
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Divider(thickness: 1.5, color: Colors.black12),
                      const SizedBox(height: 20),

                      // --- TOMBOL LOGOUT ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "LOG OUT", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}