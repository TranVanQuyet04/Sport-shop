part of '../admin_sports_page.dart';

class _SportFormResult {
  const _SportFormResult({required this.name, required this.description});

  final String name;
  final String description;
}

class _SportFormDialog extends StatefulWidget {
  const _SportFormDialog({this.sport});

  final SportModel? sport;

  @override
  State<_SportFormDialog> createState() => _SportFormDialogState();
}

class _SportFormDialogState extends State<_SportFormDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.sport?.name ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.sport?.description ?? '',
  );
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.sport == null
        ? 'Thêm môn thể thao'
        : 'Sửa môn thể thao';

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: SuperSportsTheme.borderRadius,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFF8FAFC),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _PremiumFormField(
                controller: _name,
                label: 'Tên *',
                hintText: 'Ví dụ: Bóng đá',
                errorText: _nameError,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.xl),
              _PremiumFormField(
                controller: _description,
                label: 'Mô tả',
                hintText: 'Mô tả ngắn về môn thể thao',
                minLines: 3,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      overlayColor: Colors.transparent,
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _GradientSaveButton(onPressed: _save, label: 'Lưu'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Vui lòng nhập tên môn thể thao.');
      return;
    }
    Navigator.pop(
      context,
      _SportFormResult(name: name, description: _description.text.trim()),
    );
  }
}

class _GradientSaveButton extends StatelessWidget {
  const _GradientSaveButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SuperSportsTheme.colorPrimary,
        borderRadius: SuperSportsTheme.borderRadius,
        boxShadow: SuperSportsTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: SuperSportsTheme.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumFormField extends StatefulWidget {
  const _PremiumFormField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.textInputAction,
    this.errorText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputAction textInputAction;
  final String? errorText;
  final int minLines;
  final int maxLines;

  @override
  State<_PremiumFormField> createState() => _PremiumFormFieldState();
}

class _PremiumFormFieldState extends State<_PremiumFormField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = SuperSportsTheme.borderRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(
                color: SuperSportsTheme.colorPrimary,
                width: 1.5,
              ),
            ),
            errorText: widget.errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: AdminColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(
                color: AdminColors.danger,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
