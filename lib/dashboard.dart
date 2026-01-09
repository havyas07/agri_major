import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'gsm.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String apiUrl = "http://192.168.137.124:5000/data";

  String temperature = "NA";
  String humidity = "NA";
  String soilStatus = "NA";
  String waterStatus = "NA";
  String cpu = "NA";
  String ram = "NA";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => fetchSensorData(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data["temperature"].toString();
          humidity = data["humidity"].toString();
          soilStatus = data["soil"];
          waterStatus = data["water"];
          cpu = data["cpu"].toString();
          ram = data["ram"].toString();
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Color statusColor(String value) =>
      (value.toLowerCase().contains("dry") ||
          value.toLowerCase().contains("no"))
      ? Colors.red
      : Colors.green[700]!;

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF4CAF50);

    final sensorList = [
      ["Temperature", "$temperature °C", Icons.thermostat, Colors.orangeAccent],
      ["Humidity", "$humidity%", Icons.water_drop, Colors.blueAccent],
      ["Soil", soilStatus, Icons.grass, statusColor(soilStatus)],
      ["Water Tank", waterStatus, Icons.opacity, statusColor(waterStatus)],
      ["CPU", "$cpu%", Icons.memory, Colors.purpleAccent],
      ["RAM", "$ram%", Icons.sd_storage, Colors.tealAccent],
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFd0f0c0), Color(0xFF76c893)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🌿 Smart Garden",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      Icon(
                        Icons.agriculture_rounded,
                        size: 36,
                        color: primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sensor Grid
                  Expanded(
                    child: GridView.builder(
                      itemCount: sensorList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 18,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final item = sensorList[index];
                        return sensorCard(
                          item[0] as String,
                          item[1] as String,
                          item[2] as IconData,
                          item[3] as Color,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // GSM Controls Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GSMPage()),
                        );
                      },
                      icon: const Icon(Icons.signal_cellular_alt),
                      label: const Text(
                        "Open GSM Controls",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),

      // ❌ Chatbot FAB removed
    );
  }

  // Sensor Card Widget (Overflow Safe)
  Widget sensorCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
