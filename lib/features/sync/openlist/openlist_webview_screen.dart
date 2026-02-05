import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenListWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const OpenListWebViewScreen({super.key, required this.title, required this.url});

  static Future<void> openExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  State<OpenListWebViewScreen> createState() => _OpenListWebViewScreenState();
}

class _OpenListWebViewScreenState extends State<OpenListWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _supportsWebView = true;

  @override
  void initState() {
    super.initState();
    _supportsWebView = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!_supportsWebView) {
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsWebView) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              tooltip: '外部浏览器打开',
              onPressed: () => OpenListWebViewScreen.openExternal(widget.url),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
        body: Center(
          child: Text('当前平台不支持内嵌网页，请使用外部浏览器打开。'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: '外部浏览器打开',
            onPressed: () => OpenListWebViewScreen.openExternal(widget.url),
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
