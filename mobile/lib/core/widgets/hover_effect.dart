import 'package:flutter/material.dart';

import '../constants/device_profiles.dart';

class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 1.018,
    this.dy = -2,
    this.borderRadius,
    this.hoverShadow = true,
    this.showHoverBorder = true,
    this.interactive = false,
    this.duration = const Duration(milliseconds: 180),
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final double dy;
  final BorderRadiusGeometry? borderRadius;
  final bool hoverShadow;
  final bool showHoverBorder;
  final bool interactive;
  final Duration duration;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.enabled && _pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enableHover =
        widget.enabled &&
        MediaQuery.sizeOf(context).width > AppDeviceProfiles.pixel7LogicalWidth;
    final enablePress = widget.enabled && widget.interactive;
    if (!enableHover && !enablePress) {
      return widget.child;
    }

    final active = enableHover && _hovered;
    final pressed = enablePress && _pressed;
    final primary = Theme.of(context).colorScheme.primary;
    final scale = pressed ? 0.985 : (active ? widget.scale : 1.0);

    final interaction = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: enablePress ? (_) => _setPressed(true) : null,
      onPointerUp: enablePress ? (_) => _setPressed(false) : null,
      onPointerCancel: enablePress ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: scale,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: Transform.translate(
          offset: Offset(0, active && !pressed ? widget.dy : 0),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: widget.duration,
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: pressed
                          ? primary.withValues(alpha: 0.035)
                          : Colors.transparent,
                      borderRadius: widget.borderRadius,
                      border: active && widget.showHoverBorder
                          ? Border.all(color: primary.withValues(alpha: 0.42))
                          : null,
                      boxShadow: [
                        if (active && widget.hoverShadow)
                          BoxShadow(
                            color: primary.withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!enableHover) return interaction;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.interactive ? SystemMouseCursors.click : MouseCursor.defer,
      child: interaction,
    );
  }
}
