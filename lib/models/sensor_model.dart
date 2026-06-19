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
      // Mengonversi string berkutu ("6.80") dari Postgres menjadi double secara aman
      ph: double.tryParse(json['ph_value']?.toString() ?? '0.0') ?? 0.0,
      suhuUdara: double.tryParse(json['dht_temp']?.toString() ?? '0.0') ?? 0.0,
      suhuAir: double.tryParse(json['water_temp']?.toString() ?? '0.0') ?? 0.0,
      cahaya: double.tryParse(json['lux_value']?.toString() ?? '0.0') ?? 0.0,
      tds: double.tryParse(json['tds_ppm']?.toString() ?? '0.0') ?? 0.0,
      timestamp: json['created_at']?.toString() ?? '',
    );
  }
}