import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embed_policy.dart';

/// Last-resort in-app surface for explicitly authorized legal embeds.
/// Navigation fails closed and never opens an external browser.
class LegalEmbedScreen extends StatefulWidget {
  const LegalEmbedScreen({super.key, required this.initialUri, required this.title, required this.allowedHosts});

  final Uri initialUri;
  final String title;
  final Set<String> allowedHosts;

  @override
  State<LegalEmbedScreen> createState() => _LegalEmbedScreenState();
}

class _LegalEmbedScreenState extends State<LegalEmbedScreen> {
  WebViewController? _controller;
  String? _error;
  late final EmbedNavigationPolicy _policy;

  @override
  void initState() {
    super.initState();
    _policy = EmbedNavigationPolicy(allowedHosts: widget.allowedHosts);
    if (!_policy.allowsInitial(widget.initialUri)) {
      _error = 'Embed blocked by the legal navigation policy.';
      return;
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final destination = Uri.tryParse(request.url);
          if (destination == null || !_policy.allowsNavigation(widget.initialUri, destination)) {
            if (mounted) setState(() => _error = 'Navigation blocked by the legal embed policy.');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == false || !mounted) return;
          setState(() => _error = 'Embed failed to load.');
        },
      ))
      ..loadRequest(widget.initialUri);
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: SafeArea(child: _error != null
      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Semantics(liveRegion: true, child: Text(_error!, key: const Key('embed-error'), textAlign: TextAlign.center))))
      : _controller == null
        ? const Center(child: CircularProgressIndicator())
        : WebViewWidget(key: const Key('legal-embed-webview'), controller: _controller!)),
  );
}
