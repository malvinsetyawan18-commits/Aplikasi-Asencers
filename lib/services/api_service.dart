import 'dart:io';
import 'package:dio/dio.dart';
import '../models/sensor_model.dart';
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator; ganti ke localhost:8000 atau IP untuk device
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
  }

  Future<Map<String, dynamic>> pairDevice(String deviceId, String petani) async {
    try {
      final response = await _dio.post('/pair-device', data: {
        'device_id': deviceId,
        'petani': petani,
      });
      return response.data;
    } catch (e) {
      throw Exception('Pair device gagal: $e');
    }
  }

  Future<SensorData> getSensorData(String deviceId) async {
    try {
      final response = await _dio.get('/sensor/$deviceId');
      return SensorData.fromJson(response.data);
    } catch (e) {
      throw Exception('Fetch sensor gagal: $e');
    }
  }

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
