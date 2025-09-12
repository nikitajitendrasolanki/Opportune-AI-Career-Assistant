import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JobApplyFormScreen extends StatefulWidget {
  final String applyUrl;
  final String jobTitle;

  const JobApplyFormScreen({
    super.key,
    required this.applyUrl,
    required this.jobTitle,
  });

  @override
  State<JobApplyFormScreen> createState() => _JobApplyFormScreenState();
}

class _JobApplyFormScreenState extends State<JobApplyFormScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            // ✅ Inject CSS to improve readability
            _controller.runJavaScript("""
              document.body.style.backgroundColor = 'white';
              document.body.style.color = 'black';
              document.querySelectorAll('input, textarea').forEach(el => {
                el.style.backgroundColor = 'white';
                el.style.color = 'black';
              });
            """);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.applyUrl));
  }

  // ✅ Gradient heading
  Widget _buildGradientTitle(String text) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // dark blue gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: "Orbitron",
          color: Colors.white, // required for ShaderMask
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Background with glassmorphism
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ✅ App Bar like heading
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGradientTitle("Apply: ${widget.jobTitle}"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ WebView in glass effect
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: WebViewWidget(controller: _controller),
                    ),
                  ),
                ),

                // ✅ Bottom Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
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
