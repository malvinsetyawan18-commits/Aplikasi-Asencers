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
  
  // Status loading masing-masing pompa agar tidak saling mengganggu
  bool _isLoadingUp = false;
  bool _isLoadingDown = false;
  
  final ApiService _apiService = ApiService();

  // Fungsi utama pengontrol pompa
  void _togglePompa(String pumpType, bool value) async {
    setState(() {
      if (pumpType == "pompa_up") _isLoadingUp = true;
      if (pumpType == "pompa_down") _isLoadingDown = true;
    });

    try {
      String statusStr = value ? "ON" : "OFF";
      
      // Memanggil API Service dengan mengirim 2 parameter
      final response = await _apiService.controlPump(pumpType, statusStr);

      if (!mounted) return; // Mencegah error async lewat build context

      if (response['status'] == 'success' || response['status'] != 'error') {
        setState(() {
          if (pumpType == "pompa_up") _isPumpUpOn = value;
          if (pumpType == "pompa_down") _isPumpDownOn = value;
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kontrol Perangkat"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // CARD 1: POMPA PENAIK pH
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.green, size: 30),
              title: const Text("Pompa Naik pH (pH UP)", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_isPumpUpOn ? "Status: HIDUP" : "Status: MATI"),
              trailing: _isLoadingUp 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Switch(
                      value: _isPumpUpOn,
                      onChanged: (val) => _togglePompa("pompa_up", val),
                      activeTrackColor: Colors.green,
                    ),
            ),
          ),
          
          const SizedBox(height: 12),

          // CARD 2: POMPA PENURUN pH
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.red, size: 30),
              title: const Text("Pompa Turun pH (pH DOWN)", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_isPumpDownOn ? "Status: HIDUP" : "Status: MATI"),
              trailing: _isLoadingDown 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Switch(
                      value: _isPumpDownOn,
                      onChanged: (val) => _togglePompa("pompa_down", val),
                      activeTrackColor: Colors.red,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}