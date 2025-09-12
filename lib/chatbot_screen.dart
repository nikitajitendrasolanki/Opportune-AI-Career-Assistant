import 'dart:convert';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'db_service.dart';

class PersistentChatbotScreen extends StatefulWidget {
  const PersistentChatbotScreen({super.key});

  @override
  State<PersistentChatbotScreen> createState() =>
      _PersistentChatbotScreenState();
}

class _PersistentChatbotScreenState extends State<PersistentChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, Object>> _messages = [];
  Map<String, dynamic>? _savedResume;
  int _currentResumeVersion = 0;
  bool _isTyping = false;

  late final String _apiKey;

  @override
  void initState() {
    super.initState();
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? "";
    if (_apiKey.isEmpty) {
      debugPrint("⚠️ GROQ_API_KEY missing in .env file");
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final resume = await DBService.loadResume();
    final chatsRaw = await DBService.loadChats();
    final chats = chatsRaw
        .map<Map<String, Object>>((e) => Map<String, Object>.from(e))
        .toList();

    setState(() {
      _savedResume = resume;
      _currentResumeVersion = resume?['version'] ?? 0;
      _messages = chats;
    });
    _scrollToBottom();
  }

  Map<String, String> _systemPrompt() {
    if (_savedResume != null) {
      return {
        "role": "system",
        "content":
        "You are a friendly Career Assistant. User's latest resume version: $_currentResumeVersion. Resume content: ${jsonEncode(_savedResume)}. Always give ATS-friendly suggestions and improvements."
      };
    } else {
      return {
        "role": "system",
        "content":
        "You are a friendly Career Assistant. User has no resume yet. Give advice on building ATS-friendly resumes and career guidance."
      };
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "role": "user",
        "content": text,
        "resume_version": _currentResumeVersion,
      });
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();
    await DBService.saveChat("user", text,
        resumeVersion: _currentResumeVersion);

    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            _systemPrompt(),
            ..._messages.map((m) => {
              "role": m['role'].toString(),
              "content": m['content'].toString(),
            }),
          ],
          "max_tokens": 500,
          "temperature": 0.7,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["choices"] != null) {
        final aiMessage =
            data["choices"][0]["message"]["content"] ?? "⚠️ No response";

        setState(() {
          _messages.add({
            "role": "assistant",
            "content": aiMessage,
            "resume_version": _currentResumeVersion,
          });
          _isTyping = false;
        });

        await DBService.saveChat("assistant", aiMessage,
            resumeVersion: _currentResumeVersion);
      } else {
        throw Exception(data["error"]?["message"] ?? "Unknown API error");
      }

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "❌ Error: $e",
          "resume_version": _currentResumeVersion,
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
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

  Widget _buildMessage(Map<String, Object> msg) {
    final isUser = msg["role"] == "user";
    final oldResume = msg['resume_version'] != _currentResumeVersion;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.deepPurpleAccent.withOpacity(0.15)
              : Colors.blueAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg["content"]?.toString() ?? "",
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            if (oldResume)
              const Text(
                "⚠️ Based on older resume version",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // dark blue gradient
          ).createShader(bounds),
          child: const Text(
            "Career Chatbot",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "Orbitron",
            ),
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.history, color: Colors.deepPurpleAccent),
              onPressed: () async {
                final chatsRaw = await DBService.loadChats();
                final chats = chatsRaw
                    .map<Map<String, Object>>((e) => Map<String, Object>.from(e))
                    .toList();
                setState(() => _messages = chats);
                _scrollToBottom();
              }),
          IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () async {
                await DBService.clearChats();
                setState(() => _messages.clear());
              }),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Single Frosted Glass
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (_, index) => _buildMessage(_messages[index]),
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Typing...",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              // Input Bar
              SafeArea(
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.black87),
                          decoration: const InputDecoration(
                            hintText: "Type your message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
