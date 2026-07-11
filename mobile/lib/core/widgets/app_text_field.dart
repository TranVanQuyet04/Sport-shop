import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/device_profiles.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured = widget.obscureText;
  bool _hovered = false;
  TextEditingController? _localController;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _localController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null && widget.initialValue != null) {
      _localController = TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _localController?.text) {
      _localController ??= TextEditingController();
      _localController!.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final enableHover =
        widget.enabled && !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final borderColor = hasError
        ? AppColors.error
        : !widget.enabled
        ? AppColors.borderStrong
        : _hovered
        ? AppColors.primary.withValues(alpha: 0.42)
        : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          textField: true,
          enabled: widget.enabled,
          label: widget.label,
          hint: widget.hintText,
          child: _maybeHover(
            enableHover,
            AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.enter,
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: widget.enabled && !hasError
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: _hovered ? 0.075 : 0.03,
                          ),
                          blurRadius: _hovered ? 18 : 12,
                          offset: Offset(0, _hovered ? 7 : 4),
                        ),
                      ]
                    : null,
              ),
              child: CupertinoTextField(
                controller: _effectiveController,
                placeholder: widget.hintText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                obscureText: _isObscured,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                minLines: widget.obscureText ? 1 : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                prefix: widget.prefixIcon == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.md),
                        child: Icon(
                          widget.prefixIcon,
                          size: 20,
                          color: _hovered
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                suffix: _buildSuffixIcon(),
                placeholderStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                style: AppTextStyles.body,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? (_hovered
                            ? AppColors.surface
                            : AppColors.surfaceElevated)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: borderColor,
                    width: hasError || _hovered ? 1.2 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText ?? widget.helperText!,
            style: AppTextStyles.caption.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _maybeHover(bool enableHover, Widget child) {
    if (!enableHover) {
      return child;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: child,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        tooltip: _isObscured ? 'Hiển thị nội dung' : 'Ẩn nội dung',
        onPressed: () => setState(() => _isObscured = !_isObscured),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(
          _isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Icon(
          widget.suffixIcon,
          size: 20,
          color: AppColors.textSecondary,
        ),
      );
    }

    return null;
  }
}
