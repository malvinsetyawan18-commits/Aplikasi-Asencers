import 'package:flutter/material.dart';
import 'package:aplikasi_pertamaku/services/api_service.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Status sakelar masing-masing pompa
  bool _isPumpUpOn = false;
  bool _isPumpDownOn = false;
  bool _isPumpABMixOn = false; // Status baru untuk AB Mix
  
  // Status loading masing-masing pompa agar tidak saling mengganggu
  bool _isLoadingUp = false;
  bool _isLoadingDown = false;
  bool _isLoadingABMix = false; // Loading baru untuk AB Mix
  
  final ApiService _apiService = ApiService();

  void _togglePompa(String pumpType, bool value) async {
    setState(() {
      if (pumpType == "pompa_up") _isLoadingUp = true;
      if (pumpType == "pompa_down") _isLoadingDown = true;
      if (pumpType == "pompa_abmix") _isLoadingABMix = true;
    });

    try {
      String statusStr = value ? "ON" : "OFF";
      final response = await _apiService.controlPump(pumpType, statusStr);

      if (!mounted) return;

      if (response['status'] == 'success' || response['status'] != 'error') {
        setState(() {
          if (pumpType == "pompa_up") _isPumpUpOn = value;
          if (pumpType == "pompa_down") _isPumpDownOn = value;
          if (pumpType == "pompa_abmix") _isPumpABMixOn = value;
        });
      } else {
        throw Exception(response['message'] ?? 'Gagal memproses perintah');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengontrol pompa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (pumpType == "pompa_up") _isLoadingUp = false;
          if (pumpType == "pompa_down") _isLoadingDown = false;
          if (pumpType == "pompa_abmix") _isLoadingABMix = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 1. TOP HEADER MELENGKUNG (Sesuai gaya mockup gambar Anda)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Control Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Kendalikan sistem aktuator hidroponik Anda",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),

          // 2. DAFTAR SAKELAR KONTROL
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              children: [
                // CARD 1: POMPA PENAIK pH
                _buildControlCard(
                  title: "Pompa Naik pH (pH UP)",
                  subtitle: _isPumpUpOn ? "Status: AKTIF" : "Status: NONAKTIF",
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.blue.shade600,
                  value: _isPumpUpOn,
                  isLoading: _isLoadingUp,
                  onChanged: (val) => _togglePompa("pompa_up", val),
                ),
                const SizedBox(height: 16),

                // CARD 2: POMPA PENURUN pH
                _buildControlCard(
                  title: "Pompa Turun pH (pH DOWN)",
                  subtitle: _isPumpDownOn ? "Status: AKTIF" : "Status: NONAKTIF",
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.amber.shade700,
                  value: _isPumpDownOn,
                  isLoading: _isLoadingDown,
                  onChanged: (val) => _togglePompa("pompa_down", val),
                ),
                const SizedBox(height: 16),

                // CARD 3: TOMBOL BARU - POMPA NUTRISI AB MIX
                _buildControlCard(
                  title: "Pompa Nutrisi AB Mix",
                  subtitle: _isPumpABMixOn ? "Status: AKTIF" : "Status: NONAKTIF",
                  icon: Icons.vaccines_rounded, // Ikon representasi cairan nutrisi pekat
                  iconColor: Colors.green.shade700,
                  value: _isPumpABMixOn,
                  isLoading: _isLoadingABMix,
                  onChanged: (val) => _togglePompa("pompa_abmix", val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget Reusable Card agar kodenya bersih
  Widget _buildControlCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          title: Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: value ? Colors.green.shade700 : Colors.grey,
              fontWeight: value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: isLoading 
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.green)
                )
              : Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green.shade500,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
        ),
      ),
    );
  }
}