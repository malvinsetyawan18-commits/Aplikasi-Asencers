class SensorData {
  final double ph;
  final double suhuUdara;
  final double suhuAir;
  final double cahaya;
  final double tds;
  final String timestamp;

  SensorData({
    required this.ph,
    required this.suhuUdara,
    required this.suhuAir,
    required this.cahaya,
    required this.tds,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      ph: (json['ph'] ?? 0.0).toDouble(),
      suhuUdara: (json['suhu_udara'] ?? 0.0).toDouble(),
      suhuAir: (json['suhu_air'] ?? 0.0).toDouble(),
      cahaya: (json['cahaya'] ?? 0.0).toDouble(),
      tds: (json['tds'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }
}
