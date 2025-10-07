import 'dart:async';
import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import '/pages/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1C1C27), // Warna background gelap
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Efek Dot Blur Background
          _buildDotBlurBackground(),

          // Konten Utama
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_laundry_service_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              // --- PERUBAHAN DI SINI: Menggunakan TextStyle standar ---
              const Text(
                'Fena Laundry',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat efek dot blur di background
  Widget _buildDotBlurBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -150,
          child: _buildBlurredCircle(300, Colors.deepPurpleAccent),
        ),
        Positioned(
          bottom: -120,
          right: -150,
          child: _buildBlurredCircle(350, Colors.blueAccent),
        ),
      ],
    );
  }

  Widget _buildBlurredCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
        ),
      ),
    );
  }
}
