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
  double _musicVolume = AudioManager().musicVolume;
  double _sfxVolume = AudioManager().sfxVolume;
  double _voiceVolume = AudioManager().voiceVolume;

  @override
  void initState() {
    super.initState();
    _loadVolumes();
  }

  Future<void> _loadVolumes() async {
    await AudioManager().init();
    if (!mounted) return;

    setState(() {
      _musicVolume = AudioManager().musicVolume;
      _sfxVolume = AudioManager().sfxVolume;
      _voiceVolume = AudioManager().voiceVolume;
    });
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
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: Colors.orange,
      inactiveTrackColor: Colors.orange.shade100,
      thumbColor: Colors.orangeAccent,
      overlayColor: Colors.orange.withValues(alpha: 0.2),
      trackHeight: 8.0,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'Jua',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )
        ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 18,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.9,
                    ), // Efek kaca/transparan dikit
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SliderTheme(
                    data: sliderTheme,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildVolumeControl(
                          icon: Icons.music_note_rounded,
                          title: "Volume Musik",
                          value: _musicVolume,
                          onChanged: (value) {
                            setState(() => _musicVolume = value);
                            AudioManager().setMusicVolume(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildVolumeControl(
                          icon: Icons.graphic_eq_rounded,
                          title: "Volume Efek Suara",
                          value: _sfxVolume,
                          onChanged: (value) {
                            setState(() => _sfxVolume = value);
                            AudioManager().setSfxVolume(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildVolumeControl(
                          icon: Icons.record_voice_over_rounded,
                          title: "Volume Instruksi",
                          value: _voiceVolume,
                          onChanged: (value) {
                            setState(() => _voiceVolume = value);
                            AudioManager().setVoiceVolume(value);
                          },
                        ),
                        const SizedBox(height: 22),
                        const Divider(thickness: 1.5, color: Colors.black12),
                        const SizedBox(height: 18),

                        // --- TOMBOL LOGOUT ---
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              "LOG OUT",
                              style: TextStyle(
                                fontFamily: 'Jua',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 34, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        Slider(value: value, min: 0.0, max: 1.0, onChanged: onChanged),
      ],
    );
  }
}
