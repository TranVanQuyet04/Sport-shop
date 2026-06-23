import 'package:flutter/material.dart';

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
    this.duration = const Duration(milliseconds: 200),
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
    final active = widget.enabled && _hovered;
    final pressed = widget.enabled && _pressed;
    final primary = Theme.of(context).colorScheme.primary;
    final scale = pressed ? 0.985 : (active ? widget.scale : 1.0);

    return MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _hovered = false) : null,
      cursor: widget.enabled && widget.interactive
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
        onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
        onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
        child: AnimatedScale(
          scale: scale,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              0,
              active && !pressed ? widget.dy : 0,
              0,
            ),
            decoration: BoxDecoration(
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
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
