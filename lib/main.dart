import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_email.dart';

void main() async {
  // Wajib ada biar mesin Flutter siap ngejalanin fungsi di luar UI (seperti Firebase)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menyalakan mesin Firebase Kizzle
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      // Garis biru udah hilang karena const di bawah ini udah gua cabut
      home: LoginEmailPage(), 
    ),
  );
}