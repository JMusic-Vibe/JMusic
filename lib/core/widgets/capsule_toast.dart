import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CapsuleToast {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _CapsuleToastWidget(message: message),
    );
    overlay.insert(overlayEntry);
    Timer(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class _CapsuleToastWidget extends StatefulWidget {
  final String message;

  const _CapsuleToastWidget({required this.message});

  @override
  State<_CapsuleToastWidget> createState() => _CapsuleToastWidgetState();
}

class _CapsuleToastWidgetState extends State<_CapsuleToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final top = MediaQuery.of(context).size.height / 2 - 50;
    // 最大宽度，避免在大屏设备上过宽
    const double maxWidthPx = 600.0;
    final double effectiveWidth = math.min(screenWidth * 0.8, maxWidthPx);

    return Positioned(
      top: top,
      left: (screenWidth - effectiveWidth) / 2,
      width: effectiveWidth,
      child: FadeTransition(
        opacity: _animation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

