import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- IMPORT MESIN GOOGLE
import 'login_page.dart';

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLogin = true; 
  bool _isLoading = false; 

  // --- FUNGSI MASUK / DAFTAR PAKAI EMAIL (TETAP AMAN) ---
  void _submitAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email dan Password harus diisi!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        if (_nameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama anak harus diisi!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
          return;
        }
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'nama': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'dibuat_pada': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat! Silakan Masuk.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
          setState(() { 
            _isLogin = true; 
            _passwordController.clear(); 
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Terjadi kesalahan", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // --- FUNGSI BARU: MASUK PAKAI GOOGLE ---
  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; });
    try {
      // Muncilin pop-up milih akun Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Kalau user mencet tombol 'Cancel' atau 'Back'
        setState(() { _isLoading = false; });
        return; 
      }

      // Minta izin ke Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Masuk ke Firebase pakai akun Google
      UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      // Cek apakah dia orang baru? Kalau iya, simpan namanya otomatis ke Database
      if (userCred.additionalUserInfo?.isNewUser ?? false) {
        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'nama': userCred.user!.displayName ?? 'Pemain Kizzle', // Ngambil nama asli dari Google
          'email': userCred.user!.email,
          'dibuat_pada': FieldValue.serverTimestamp(),
        });
      }

      debugPrint("Google Sign-In Sukses!");
      
      // Langsung pindah halaman
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      
    } catch (e) {
      debugPrint("Error Google: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal masuk dengan Google. Coba lagi!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset('assets/images/kizzle_logo.png', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                    ),
                  ),
                  
                  const SizedBox(height: 40), 

                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(hintText: 'Nama Anak', prefixIcon: const Icon(Icons.person_outline, color: Colors.blueAccent), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                          ),
                          const SizedBox(height: 20),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(hintText: 'Email', prefixIcon: const Icon(Icons.email_outlined, color: Colors.blueAccent), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent), suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                        ),
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity, height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 5),
                            onPressed: _isLoading ? null : _submitAuth,
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_isLogin ? "Masuk" : "Daftar", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // --- TOMBOL GOOGLE SUDAH AKTIF ---
                        if (_isLogin) 
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), side: BorderSide(color: Colors.grey.shade300, width: 2)),
                            // Jalankan fungsi Google di sini
                            onPressed: _isLoading ? null : _signInWithGoogle, 
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network('https://img.icons8.com/color/48/000000/google-logo.png', height: 25, errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red)),
                                const SizedBox(width: 15),
                                const Text("Masuk dengan Google", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLogin ? "Belum punya akun? " : "Sudah punya akun? ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () { setState(() { _isLogin = !_isLogin; }); },
                        child: Text(_isLogin ? "Daftar Sekarang" : "Masuk di Sini", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}