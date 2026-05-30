import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'loading_screen.dart';

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isAuthButtonPressed = false;
  bool _isGoogleButtonPressed = false;

  late final AnimationController _logoController;
  late final Animation<double> _logoFloatAnimation;

  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoFloatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _blinkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;

      setState(() => _isBlinking = true);

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _isBlinking = false);
      });
    });
  }

  void _submitAuth() async {
    final String emailInput = _emailController.text.trim();
    final String passwordInput = _passwordController.text.trim();
    final String nameInput = _nameController.text.trim();

    if (emailInput.isEmpty || passwordInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _premiumSnackBar("Email dan Password harus diisi!", Colors.redAccent),
      );
      return;
    }

    if (!emailInput.endsWith('@gmail.com') &&
        !emailInput.endsWith('@yahoo.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        _premiumSnackBar(
          "⚠️ Gunakan provider email yang valid! (Contoh: @gmail.com)",
          Colors.deepOrangeAccent,
        ),
      );
      return;
    }

    if (!_isLogin && nameInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _premiumSnackBar("Nama anak harus diisi!", Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      late final UserCredential userCred;

      if (_isLogin) {
        userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailInput,
          password: passwordInput,
        );

        final User? user = userCred.user;

        if (user == null) {
          throw FirebaseAuthException(
            code: 'null-user',
            message: 'Login gagal mendapatkan data pengguna.',
          );
        }

        await _ensurePlayerName(user, emailFallback: emailInput);

        if (mounted) {
          _goToLoadingScreen();
        }
      } else {
        userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailInput,
          password: passwordInput,
        );

        final User? user = userCred.user;

        if (user == null) {
          throw FirebaseAuthException(
            code: 'null-user',
            message: 'Registrasi gagal mendapatkan data pengguna.',
          );
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nama': nameInput,
          'email': emailInput,
          'dibuat_pada': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          _goToLoadingScreen();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _premiumSnackBar(e.message ?? "Terjadi kesalahan", Colors.redAccent),
        );
      }
    } catch (e) {
      debugPrint("Error Auth: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _premiumSnackBar("Terjadi kesalahan. Coba lagi!", Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      late final UserCredential userCred;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider.addScope('email');
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
        });

        userCred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final User? user = userCred.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Google Sign-In gagal mendapatkan data pengguna.',
        );
      }

      await _ensurePlayerName(user, emailFallback: user.email ?? '');

      debugPrint("Google Sign-In Sukses!");

      if (mounted) {
        _goToLoadingScreen();
      }
    } catch (e) {
      debugPrint("Error Google: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _premiumSnackBar(
            "Gagal masuk dengan Google. Coba lagi!",
            Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _ensurePlayerName(
    User user, {
    String emailFallback = '',
  }) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final userData = userDoc.data();

    final String existingName = userData?['nama']?.toString().trim() ?? '';

    if (existingName.isNotEmpty) {
      return;
    }

    if (!mounted) {
      throw FirebaseAuthException(
        code: 'missing-player-name',
        message: 'Nama pemain belum tersedia.',
      );
    }

    final String playerName = await _showPlayerNameDialog();

    final Map<String, dynamic> userPayload = {
      'nama': playerName,
      'email': user.email ?? emailFallback,
      'diperbarui_pada': FieldValue.serverTimestamp(),
    };

    if (!userDoc.exists) {
      userPayload['dibuat_pada'] = FieldValue.serverTimestamp();
    }

    await userRef.set(userPayload, SetOptions(merge: true));
  }

  Future<String> _showPlayerNameDialog() async {
    final TextEditingController playerNameController = TextEditingController();
    String? errorText;

    final String? result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                "Masukkan Nama Pemain",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              content: TextField(
                controller: playerNameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: "Contoh: Ansell",
                  errorText: errorText,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.blueAccent,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    final String inputName = playerNameController.text.trim();

                    if (inputName.isEmpty) {
                      setDialogState(() {
                        errorText = "Nama pemain wajib diisi";
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(inputName);
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      fontFamily: 'Jua',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    playerNameController.dispose();

    final String finalName = result?.trim() ?? '';

    if (finalName.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-player-name',
        message: 'Nama pemain wajib diisi.',
      );
    }

    return finalName;
  }

  void _goToLoadingScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoadingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _bouncyButton({
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required Widget child,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        onTapDown();
      },
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: isPressed ? Curves.easeOut : Curves.elasticOut,
        child: child,
      ),
    );
  }

  SnackBar _premiumSnackBar(String message, Color color) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'PalanquinDark',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    );
  }

  Widget _buildAnimatedLogo(double logoSize) {
    return AnimatedBuilder(
      animation: _logoFloatAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _logoFloatAnimation.value),
          child: Image.asset(
            _isBlinking
                ? 'assets/images/kizzle_logoblink.png'
                : 'assets/images/kizzle_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoSize = (screenWidth * 0.30).clamp(95.0, 130.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 18, 25, 25),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildAnimatedLogo(logoSize),
                          const SizedBox(height: 12),

                          if (!_isLogin) ...[
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Nama Anak',
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.blueAccent,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.blueAccent,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.blueAccent,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          _bouncyButton(
                            isPressed: _isAuthButtonPressed,
                            onTapDown: () =>
                                setState(() => _isAuthButtonPressed = true),
                            onTapUp: () =>
                                setState(() => _isAuthButtonPressed = false),
                            child: SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        _submitAuth();
                                      },
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _isLogin ? "Masuk" : "Daftar",
                                        style: const TextStyle(
                                          fontFamily: 'Jua',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (_isLogin)
                            _bouncyButton(
                              isPressed: _isGoogleButtonPressed,
                              onTapDown: () =>
                                  setState(() => _isGoogleButtonPressed = true),
                              onTapUp: () => setState(
                                () => _isGoogleButtonPressed = false,
                              ),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        _signInWithGoogle();
                                      },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://img.icons8.com/color/48/000000/google-logo.png',
                                      height: 25,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.g_mobiledata,
                                                color: Colors.red,
                                              ),
                                    ),
                                    const SizedBox(width: 15),
                                    const Text(
                                      "Masuk dengan Google",
                                      style: TextStyle(
                                        fontFamily: 'PalanquinDark',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Belum punya akun? "
                              : "Sudah punya akun? ",
                          style: const TextStyle(
                            fontFamily: 'PalanquinDark',
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? "Daftar Sekarang" : "Masuk di Sini",
                            style: const TextStyle(
                              fontFamily: 'PalanquinDark',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
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
      ),
    );
  }
}