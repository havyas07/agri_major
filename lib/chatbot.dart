import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool _isTyping = false;

  static const String apiKey = "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";

  Future<String> getReply(String userMessage) async {
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4.1-mini",
          "messages": [
            {"role": "system", "content": "You are an agriculture expert chatbot for Indian farming."},
            {"role": "user", "content": userMessage},
          ]
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result["choices"][0]["message"]["content"];
      } else {
        return "⚠️ Server Error (${response.statusCode}) — Check API Key & Internet.";
      }
    } catch (e) {
      return "❌ Error connecting to server: $e";
    }
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    final reply = await getReply(text);

    setState(() {
      messages.add({"role": "bot", "text": reply});
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget messageBubble(Map msg) {
    bool isUser = msg["role"] == "user";
    Color bubbleColor = isUser ? Colors.green[300]! : Colors.grey[200]!;
    Color textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.75 * MediaQuery.of(context).size.width),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 12 : 0),
            topRight: Radius.circular(isUser ? 0 : 12),
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
          ),
        ),
        child: Text(
          msg["text"],
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("🌾 Agriculture AI Chatbot"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) => messageBubble(messages[index]),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 6,
                        height: 6,
                        child: CircleAvatar(backgroundColor: Colors.grey, radius: 3),
                      ),
                      SizedBox(width: 4),
                      SizedBox(
                        width: 6,
                        height: 6,
                        child: CircleAvatar(backgroundColor: Colors.grey, radius: 3),
                      ),
                      SizedBox(width: 4),
                      SizedBox(
                        width: 6,
                        height: 6,
                        child: CircleAvatar(backgroundColor: Colors.grey, radius: 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Ask about crops, fertilizers, soil...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.green[50],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
