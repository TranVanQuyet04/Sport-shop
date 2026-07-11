part of '../admin_add_product_page.dart';

class _PremiumDropdown<T> extends StatefulWidget {
  const _PremiumDropdown({
    required this.label,
    required this.hintText,
    required this.fieldIcon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.itemIcon,
    required this.onChanged,
    this.enabled = true,
    this.required = false,
    this.onQuickAdd,
  });

  final String label;
  final String hintText;
  final IconData fieldIcon;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final IconData Function(T item) itemIcon;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final bool required;
  final VoidCallback? onQuickAdd;

  @override
  State<_PremiumDropdown<T>> createState() => _PremiumDropdownState<T>();
}

class _PremiumDropdownState<T> extends State<_PremiumDropdown<T>> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.required ? '${widget.label} *' : widget.label,
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<T>(
                key: ValueKey(widget.value),
                initialValue: widget.value,
                focusNode: _focusNode,
                validator: (value) {
                  if (widget.required && value == null) {
                    return 'Vui lòng chọn ${widget.label.toLowerCase()}.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    widget.fieldIcon,
                    color: AdminColors.primary,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AdminColors.danger),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: AdminColors.danger,
                      width: 1.5,
                    ),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AdminColors.textSecondary,
                ),
                hint: Text(
                  widget.hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
                items: widget.items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AdminColors.primarySoft,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                widget.itemIcon(item),
                                color: AdminColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                widget.itemLabel(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  color: AdminColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
                selectedItemBuilder: (context) => widget.items
                    .map(
                      (item) => Text(
                        widget.itemLabel(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: widget.enabled ? widget.onChanged : null,
              ),
            ),
            if (widget.onQuickAdd != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: widget.onQuickAdd,
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_rounded,
                        color: AdminColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
