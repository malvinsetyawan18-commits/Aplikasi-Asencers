import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_pertamaku/frontend/ai_page.dart';
import 'package:aplikasi_pertamaku/frontend/camera.dart';
import 'package:aplikasi_pertamaku/frontend/control_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCameras();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asencers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const PairingPage(),
    );
  }
}

// ================== PAIRING PAGE ==================
class PairingPage extends StatefulWidget {
  const PairingPage({super.key});

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final TextEditingController namaPetani = TextEditingController();
  final TextEditingController namaAlat = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(-4, 0), 
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "ASENCERS",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 5),
              const Text(
                "Silakan Masukkan Identitas Alat",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [

                    TextField(
                      controller: namaPetani,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: "Nama Petani",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: namaAlat,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.memory),
                        labelText: "Nama / ID Alat",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainPage(
                        petani: namaPetani.text,
                        alat: namaAlat.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Masuk",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "smart hydroponic monitoring",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== MAIN PAGE ==================
class MainPage extends StatefulWidget {
  final String petani;
  final String alat;

  const MainPage({super.key, required this.petani, required this.alat});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(petani: widget.petani, alat: widget.alat),
      const CameraPage(),
      ControlPage(),
      const AiPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Monitoring",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: "Kamera",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Kontrol",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: "AI Saran",
          ),
        ],
      ),
    );
  }
}

// ================== DASHBOARD ==================
class DashboardPage extends StatelessWidget {
  final String petani;
  final String alat;

  const DashboardPage({super.key, required this.petani, required this.alat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unit: $alat"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text("Petani: $petani",
                    style: const TextStyle(color: Colors.white)),
                subtitle: const Text("Monitoring aktif",
                    style: TextStyle(color: Colors.white70)),
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SensorCard(title: "pH Air", value: "6.5"),
                SensorCard(title: "Suhu Udara", value: "28°C"),
                SensorCard(title: "Suhu Air", value: "26°C"),
                SensorCard(title: "Cahaya", value: "700 lux"),
                SensorCard(title: "TDS", value: "800 ppm"),
              ],
            ),

            const SizedBox(height: 20),

            const Text("Grafik Pertumbuhan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Center(
                child: Text("Grafik Sawi & Pakcoy (Coming Soon)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== CAMERA PAGE ==================
class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: CameraView(),
    );
  }
}

// ================== SENSOR CARD ==================
class SensorCard extends StatelessWidget {
  final String title;
  final String value;

  const SensorCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(2, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getIcon(title), size: 30, color: Colors.green),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Normal",
                style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  IconData getIcon(String title) {
    switch (title) {
      case "pH Air":
        return Icons.water_drop;
      case "Suhu Udara":
        return Icons.thermostat;
      case "Suhu Air":
        return Icons.thermostat_auto;
      case "Cahaya":
        return Icons.wb_sunny;
      case "TDS":
        return Icons.science;
      default:
        return Icons.device_thermostat;
    }
  }
}