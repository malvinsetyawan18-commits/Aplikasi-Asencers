import 'dart:io';
import 'package:dio/dio.dart';
import '../models/sensor_model.dart';
import 'package:path/path.dart';

class ApiService {
  // Node-RED — untuk sensor, device, pompa
  static const String baseUrl = 'http://187.77.117.24:1880';
  
  // FastAPI — untuk fusion, monitoring, AI
  static const String apiUrl = 'http://187.77.117.24:8000';
  
  late final Dio _dio;
  late final Dio _apiDio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), 
      receiveTimeout: const Duration(seconds: 5),
    ));

    _apiDio = Dio(BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 10), 
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  // 1. Pair device (Node-RED)
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

  // 2. Get all devices (Node-RED)
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

  // 3. Get sensor data (Node-RED)
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

  // 4. Kontrol pompa (Node-RED)
  Future<Map<String, dynamic>> controlPump(String pumpType, String status) async {
    try {
      final response = await _dio.post(
        '/device/control-pump', 
        data: {
          'pump_type': pumpType,
          'status': status,
        },
      );
      
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      
      return {
        'status': 'success',
        'message': response.data.toString()
      };
    } catch (e) {
      throw Exception('Gagal menghubungi server: $e');
    }
  }

  // 5. Analisis gambar (Node-RED)
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

  // 6. AI Chat (Node-RED)
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

  // 7. Fusion result (FastAPI)
  Future<Map<String, dynamic>> getFusionResult() async {
    try {
      final response = await _apiDio.get('/monitoring/fusion');
      return response.data;
    } catch (e) {
      throw Exception('Gagal mengambil hasil fusion: $e');
    }
  }

  // 8. History monitoring (FastAPI)
  Future<List<dynamic>> getMonitoringHistory() async {
    try {
      final response = await _apiDio.get('/monitoring/history');
      if (response.data is List) {
        return response.data;
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil history monitoring: $e');
    }
  }

  // 9. Setujui aksi pompa (FastAPI)
  Future<Map<String, dynamic>> approveAction(String sessionId, String actionId) async {
    try {
      final response = await _apiDio.post('/monitoring/approve', queryParameters: {
        'session_id': sessionId,
        'action_id': actionId,
      });
      return response.data;
    } catch (e) {
      throw Exception('Gagal menyetujui aksi: $e');
    }
  }

  // 10. Tolak aksi pompa (FastAPI)
  Future<Map<String, dynamic>> rejectAction(String sessionId, String actionId) async {
    try {
      final response = await _apiDio.post('/monitoring/reject', queryParameters: {
        'session_id': sessionId,
        'action_id': actionId,
      });
      return response.data;
    } catch (e) {
      throw Exception('Gagal menolak aksi: $e');
    }
  }
}