import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/hidroponik_bg.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Lapisan Gradasi Estetik (Gelap di bawah agar tombol kontras)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),

          // 3. Lapisan Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(), 
                  // Tengah (Logo + Judul)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,

                          errorBuilder:(context, error, stackTrace) { 
                            return const Icon(
                              Icons.eco_rounded,
                              size: 80,
                              color: Colors.greenAccent,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "ASENCERS",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900, 
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text( 
                        "Pantau kondisi hidroponik Anda\nsecara real-time dan akurat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8), 
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(), 
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade700,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: Colors.green.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "MULAI SEKARANG",
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Versi 1.0",
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.white38,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}