import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JobApplyWebview extends StatefulWidget {
  final String applyUrl;
  final String name;
  final String email;
  final String phone;
  final String resumePath;

  const JobApplyWebview({
    super.key,
    required this.applyUrl,
    required this.name,
    required this.email,
    required this.phone,
    required this.resumePath,
  });

  @override
  State<JobApplyWebview> createState() => _JobApplyWebviewState();
}

class _JobApplyWebviewState extends State<JobApplyWebview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.applyUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            // Auto-fill JS
            final jsCode = """
              try {
                if(document.querySelector('#name')) {
                  document.querySelector('#name').value = '${widget.name}';
                }
                if(document.querySelector('#email')) {
                  document.querySelector('#email').value = '${widget.email}';
                }
                if(document.querySelector('#phone')) {
                  document.querySelector('#phone').value = '${widget.phone}';
                }
                // File upload can't be automated for security reasons
                console.log('Form auto-filled');
              } catch(e) { console.log(e); }
            """;
            _controller.runJavaScript(jsCode);
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto Apply"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
