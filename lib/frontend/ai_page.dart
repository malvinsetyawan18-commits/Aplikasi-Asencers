import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import service API kamu

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController controller = TextEditingController();
  final ApiService apiService = ApiService(); // Inisialisasi ApiService
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    if (controller.text.isEmpty || isLoading) return;

    final userMessage = controller.text;
    
    setState(() {
      messages.add({"text": userMessage, "isUser": true});
      isLoading = true;
    });
    controller.clear();

    try {
      // Menembak endpoint AI Chat asli di Node-RED dengan device_id terkait
      final response = await apiService.sendAiChat(userMessage, "ESP32_01");
      
      setState(() {
        messages.add({
          "text": response['reply'] ?? response['message'] ?? "AI tidak memberikan respon.",
          "isUser": false
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "text": "Gagal terhubung ke AI: $e",
          "isUser": false
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Saran"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["isUser"] ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Tanya AI...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}