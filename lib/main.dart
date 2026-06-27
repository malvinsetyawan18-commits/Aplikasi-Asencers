import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_pertamaku/frontend/ai_page.dart';
import 'package:aplikasi_pertamaku/frontend/control_page.dart';
import 'package:aplikasi_pertamaku/services/api_service.dart';
import 'package:aplikasi_pertamaku/models/sensor_model.dart';  
import 'dart:async'; 
import 'package:aplikasi_pertamaku/frontend/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      title: 'Asencoders',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const WelcomePage(), 
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
      const ControlPage(),
      const AiPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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

// ================== DASHBOARD PAGE ==================
class DashboardPage extends StatefulWidget {
  final String petani;
  final String alat;

  const DashboardPage({super.key, required this.petani, required this.alat});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  SensorData? _sensorData;
  Map<String, dynamic>? _fusionData;
  bool _isLoading = true;
  bool _isFusionLoading = false;
  Map<String, String> _actionDecisions = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _apiService.getSensorData("ESP32_01");
      if (mounted) {
        setState(() {
          _sensorData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data sensor: $e");
      if (mounted && _sensorData == null) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchFusion() async {
    setState(() {
      _isFusionLoading = true;
      _actionDecisions = {};
    });
    try {
      final data = await _apiService.getFusionResult();
      if (mounted) {
        setState(() {
          _fusionData = data;
          _isFusionLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil fusion: $e");
      if (mounted) {
        setState(() => _isFusionLoading = false);
      }
    }
  }

  Future<void> _handleApprove(String sessionId, String actionId, String label) async {
    try {
      await _apiService.approveAction(sessionId, actionId);
      setState(() => _actionDecisions[actionId] = 'approved');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ $label berhasil dijalankan!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menjalankan aksi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(String sessionId, String actionId, String label) async {
    try {
      await _apiService.rejectAction(sessionId, actionId);
      setState(() => _actionDecisions[actionId] = 'rejected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ $label ditolak."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal menolak aksi: $e");
    }
  }

  Color _getStatusColor(String status) {
    if (status.contains("OPTIMAL")) return Colors.green;
    if (status.contains("WASPADA")) return Colors.orange;
    if (status.contains("SANGAT YAKIN")) return Colors.red;
    return Colors.blue;
  }

  IconData _getStatusIcon(String status) {
    if (status.contains("OPTIMAL")) return Icons.check_circle;
    if (status.contains("WASPADA")) return Icons.warning;
    if (status.contains("SANGAT YAKIN")) return Icons.dangerous;
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unit: ${widget.alat}"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // ===== HEADER PETANI =====
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.green.shade700],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text("Petani: ${widget.petani}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          _sensorData != null && _sensorData!.timestamp.isNotEmpty
                              ? "Terakhir diperbarui: ${_sensorData!.timestamp.split('T').last.substring(0, 5)} WIB"
                              : "Monitoring aktif",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ===== GRID SENSOR =====
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SensorCard(
                          title: "pH Air", 
                          value: _sensorData != null ? _sensorData!.ph.toStringAsFixed(2) : "--"
                        ),
                        SensorCard(
                          title: "Suhu Udara", 
                          value: _sensorData != null ? "${_sensorData!.suhuUdara.toStringAsFixed(1)}°C" : "--"
                        ),
                        SensorCard(
                          title: "Suhu Air", 
                          value: _sensorData != null ? "${_sensorData!.suhuAir.toStringAsFixed(1)}°C" : "--"
                        ),
                        SensorCard(
                          title: "TDS", 
                          value: _sensorData != null ? "${_sensorData!.tds.toStringAsFixed(0)} ppm" : "--"
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== SECTION ANALISIS AI =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Analisis AI Tanaman",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isFusionLoading ? null : _fetchFusion,
                          icon: _isFusionLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 16),
                          label: const Text("Analisis"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ===== FUSION RESULT CARD =====
                    if (_fusionData == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.shade300, blurRadius: 10)
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.agriculture, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "Tekan tombol Analisis untuk melihat\nhasil analisis kondisi tanaman",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildFusionCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFusionCard() {
    final fusionResult = _fusionData!['fusion_result'] ?? {};
    final sensorResult = _fusionData!['sensor_result'] ?? {};
    final visualResults = _fusionData!['visual_results'] as List? ?? [];
    final recommendedActions = fusionResult['recommended_actions'] as List? ?? [];
    final sessionId = fusionResult['session_id'] ?? '';
    final requiresApproval = fusionResult['requires_approval'] ?? false;
    final status = fusionResult['status'] ?? 'Tidak diketahui';
    final recommendation = fusionResult['recommendation'] ?? '-';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // ===== STATUS UTAMA =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                left: BorderSide(color: statusColor, width: 4),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== REKOMENDASI =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // ===== HASIL SENSOR ML =====
                const Text("Hasil Sensor ML",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.memory, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Status: ${sensorResult['label'] ?? '-'}  |  "
                      "Confidence: ${((sensorResult['confidence'] ?? 0) * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // ===== HASIL KAMERA YOLO =====
                const Text("Hasil Kamera YOLO",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ...visualResults.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "${v['camera']}: ${v['label']}  (${v['confidence'].toStringAsFixed(1)}%)",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                )),

                // ===== FOTO KAMERA =====
                if (visualResults.any((v) => v['url_gambar'] != null && v['url_gambar'].toString().isNotEmpty)) ...[
                  const Divider(height: 24),
                  const Text("Foto Kamera",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...visualResults.where((v) => v['url_gambar'] != null && v['url_gambar'].toString().isNotEmpty).map((v) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v['camera'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              v['url_gambar'].toString(),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 180,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                ),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 180,
                                  color: Colors.grey.shade100,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ===== AKSI PERSETUJUAN =====
                if (requiresApproval && recommendedActions.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    "Tindakan Direkomendasikan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Setujui atau tolak tindakan berikut:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ...recommendedActions.map((action) {
                    final actionId = action['id'] ?? '';
                    final actionLabel = action['label'] ?? '';
                    final actionReason = action['reason'] ?? '';
                    final decision = _actionDecisions[actionId];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: decision == 'approved'
                            ? Colors.green.shade50
                            : decision == 'rejected'
                                ? Colors.red.shade50
                                : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: decision == 'approved'
                              ? Colors.green.shade300
                              : decision == 'rejected'
                                  ? Colors.red.shade300
                                  : Colors.orange.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings_remote,
                                size: 16,
                                color: decision == 'approved'
                                    ? Colors.green
                                    : decision == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  actionLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            actionReason,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          if (decision == null)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _handleApprove(sessionId, actionId, actionLabel),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text("Setujui"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _handleReject(sessionId, actionId, actionLabel),
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text("Tolak"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(
                                  decision == 'approved' ? Icons.check_circle : Icons.cancel,
                                  size: 16,
                                  color: decision == 'approved' ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  decision == 'approved' ? "Disetujui — Pompa berjalan" : "Ditolak — Tidak ada tindakan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: decision == 'approved' ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
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
      case "TDS":
        return Icons.science;
      default:
        return Icons.device_thermostat;
    }
  }
}