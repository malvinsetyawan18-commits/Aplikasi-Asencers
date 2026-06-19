import 'dart:io';
import 'package:dio/dio.dart';
import '../models/sensor_model.dart';
import 'package:path/path.dart';

class ApiService {
  // Menggunakan IP VPS dan port Node-RED
  static const String baseUrl = 'http://187.77.117.24:1880';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), 
      receiveTimeout: const Duration(seconds: 5),
    ));
  }

  // 1. Disesuaikan jalur endpoint-nya jika di backend menggunakan prefix /device (Tetap Sama)
  Future<Map<String, dynamic>> pairDevice(String deviceId, String petani) async {
    try {
      final response = await _dio.post('/device/pair-device', data: {
        'device_id': deviceId,
        'petani': petani,
      });
      return response.data;
    } catch (e) {
      throw Exception('Pair device gagal: $e');
    }
  }

  // 2. Fungsi untuk mengambil daftar seluruh device untuk dipasang ke UI (Tetap Sama)
  Future<List<dynamic>> getAllDevices() async {
    try {
      final response = await _dio.get('/device/list-devices');
      if (response.data['status'] == 'success') {
        return response.data['data']; 
      }
      return [];
    } catch (e) {
      throw Exception('Gagal memuat daftar perangkat: $e');
    }
  }

  // 3. Fungsi mengambil data sensor (Tetap Sama)
  Future<SensorData> getSensorData(String deviceId) async {
    try {
      final response = await _dio.get('/sensor/$deviceId');
      
      if (response.data is List && (response.data as List).isNotEmpty) {
        return SensorData.fromJson(response.data[0]);
      } else if (response.data is Map<String, dynamic>) {
        return SensorData.fromJson(response.data);
      } else {
        throw Exception('Format data tidak sesuai atau database kosong');
      }
    } catch (e) {
      throw Exception('Fetch sensor gagal: $e');
    }
  }

  // 4. TAMBAHKAN INI: Fungsi untuk kontrol pompa
  Future<Map<String, dynamic>> controlPump(String status) async {
    try {
      // Mengirim data menggunakan FormData karena backend Python menggunakan Form(...)
      final response = await _dio.post(
        '/device/control-pump', 
        data: FormData.fromMap({
          'status': status, // Kirim "ON" atau "OFF"
        }),
      );
      return response.data;
    } catch (e) {
      throw Exception('Gagal mengontrol pompa: $e');
    }
  }

  // 5. Fungsi Analisis Gambar (Tetap Sama)
  Future<Map<String, dynamic>> analyzeImage(File imageFile, String deviceId) async {
    try {
      final name = basename(imageFile.path);
      final fileBytes = await imageFile.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(fileBytes, filename: name);

      final response = await _dio.post('/analyze-image',
        data: FormData.fromMap({
          'file': multipartFile,
          'device_id': deviceId,
        }),
      );
      return response.data;
    } catch (e) {
      throw Exception('Analyze image gagal: $e');
    }
  }

  // 6. Fungsi AI Chat (Tetap Sama)
  Future<Map<String, dynamic>> sendAiChat(String message, String deviceId) async {
    try {
      final response = await _dio.post('/ai-chat', data: {
        'message': message,
        'device_id': deviceId,
      });
      return response.data;
    } catch (e) {
      throw Exception('AI chat gagal: $e');
    }
  }
}