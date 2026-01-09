import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GSMPage extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  final String defaultNumber = "9620519556"; // Fixed recipient number

  GSMPage({super.key});

  /// Function to send SMS with given message
  Future<void> sendSMS(String command) async {
    final Uri smsUri = Uri.parse(
      "sms:$defaultNumber?body=${Uri.encodeComponent(command)}",
    );

    try {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("❌ Error launching SMS: $e");
    }
  }

  /// Dialog for registering phone number
  void showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register Mobile Number"),
          content: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "Enter Mobile Number",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              onPressed: () {
                final phoneNumber = _phoneController.text.trim();
                if (phoneNumber.isEmpty) return;
                Navigator.pop(context);
                sendSMS("#1STN$phoneNumber");
              },
            ),
          ],
        );
      },
    );
  }

  /// Dialog for motor control
  void showMotorControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("⚙ Motor Control"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.power),
                label: const Text("Turn ON Motor"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  sendSMS("#1"); // Motor ON
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.power_off),
                label: const Text("Turn OFF Motor"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  sendSMS("#2"); // Motor OFF
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryGreen = Color(0xFF4CAF50);
    final secondaryBlue = Color(0xFF42A5F5);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0f7da), Color(0xFFa8e063)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "📡 GSM Control Panel",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Register Number Button
                    GestureDetector(
                      onTap: () => showPhoneDialog(context),
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: secondaryBlue,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "📱 Register Mobile Number",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Motor Control Button
                    GestureDetector(
                      onTap: () => showMotorControlDialog(context),
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "⚙ Control Motor",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
