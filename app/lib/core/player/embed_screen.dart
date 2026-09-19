import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embed_policy.dart';

class EmbedScreen extends StatefulWidget {
  const EmbedScreen({
    super.key,
    required this.initialUri,
    required this.title,
    required this.allowedHosts,
  });

  final Uri initialUri;
  final String title;
  final Set<String> allowedHosts;

  @override
  State<EmbedScreen> createState() => _EmbedScreenState();
}

class _EmbedScreenState extends State<EmbedScreen> {
  WebViewController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final policy = EmbedNavigationPolicy(allowedHosts: widget.allowedHosts);
    if (!policy.allowsInitial(widget.initialUri)) {
      _error = 'This embedded source is not allowed.';
      return;
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final destination = Uri.tryParse(request.url);
          if (destination == null ||
              !policy.allowsNavigation(widget.initialUri, destination)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _error = 'Embedded playback failed.');
        },
      ));
    _controller = controller;
    controller.loadRequest(widget.initialUri);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          child: _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, key: const Key('embed-error')),
                  ),
                )
              : WebViewWidget(
                  key: const Key('legal-embed-webview'),
                  controller: _controller!,
                ),
        ),
      );
}
