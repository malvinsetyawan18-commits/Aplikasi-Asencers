import 'package:flutter/material.dart';
import 'package:aplikasi_pertamaku/services/api_service.dart'; // Sesuaikan path-nya

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool _isPumpOn = false; 
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Fungsi mengendalikan pompa lewat ApiService
  void _togglePompa(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String statusStr = value ? "ON" : "OFF";
      
      // Mengirim perintah ke backend FastAPI -> VPS -> ESP32
      final response = await _apiService.controlPump(statusStr);

      if (response['status'] == 'success') {
        setState(() {
          _isPumpOn = value; // Ubah status tombol di aplikasi jika sukses
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengontrol pompa: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.water_drop, color: Colors.blue, size: 30),
                    title: const Text("Pompa Utama", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_isPumpOn ? "Status: HIDUP" : "Status: MATI"),
                    trailing: Switch(
                      value: _isPumpOn,
                      onChanged: _togglePompa, // Memicu fungsi kontrol saat digeser
                      activeColor: Colors.green,
                    ),
                  ),
                ),
                // Anda bisa menambahkan Card serupa di bawah ini untuk RELAY2, RELAY3 (pH Up/Down), dll.
              ],
            ),
    );
  }
}