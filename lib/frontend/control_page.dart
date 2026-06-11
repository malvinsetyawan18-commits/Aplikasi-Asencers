import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool relayUp = false;
  bool relayDown = false;

  void toggleRelayUp() {
    setState(() {
      relayUp = !relayUp;
    });

    // TODO: kirim ke backend / ESP32
  }

  void toggleRelayDown() {
    setState(() {
      relayDown = !relayDown;
    });

    // TODO: kirim ke backend / ESP32
  }

  Widget buildControlCard({
    required String title,
    required bool status,
    required VoidCallback onToggle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            status ? "AKTIF" : "MATI",
            style: TextStyle(
              fontSize: 16,
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: onToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: Text(status ? "OFF" : "ON"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kontrol Relay"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            buildControlCard(
              title: "Pompa Naik pH",
              status: relayUp,
              onToggle: toggleRelayUp,
              color: Colors.green,
            ),

            buildControlCard(
              title: "Pompa Turun pH",
              status: relayDown,
              onToggle: toggleRelayDown,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}