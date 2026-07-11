part of '../admin_brand_management_page.dart';

class _BrandFormResult {
  const _BrandFormResult({
    required this.name,
    required this.description,
    required this.logo,
    required this.isActive,
  });

  final String name;
  final String description;
  final String logo;
  final bool isActive;
}

class _BrandFormDialog extends StatefulWidget {
  const _BrandFormDialog({this.brand});

  final AdminBrandModel? brand;

  @override
  State<_BrandFormDialog> createState() => _BrandFormDialogState();
}

class _BrandFormDialogState extends State<_BrandFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.brand?.name ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.brand?.description ?? '');
  late final TextEditingController _logoController = TextEditingController(
    text: widget.brand?.logo ?? '',
  );
  late bool _isActive = widget.brand?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _BrandFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        logo: _logoController.text.trim(),
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.brand != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actionsAlignment: MainAxisAlignment.end,
      title: _DialogTitle(
        title: isEditing ? 'Sửa thương hiệu' : 'Thêm thương hiệu',
        subtitle: 'Cập nhật thông tin nhận diện thương hiệu.',
        icon: Icons.verified_outlined,
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminFormField(
                  controller: _nameController,
                  label: 'Tên thương hiệu',
                  hintText: 'Ví dụ: Nike',
                  prefixIcon: Icons.verified_outlined,
                  required: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminFormField(
                  controller: _descriptionController,
                  label: 'Mô tả',
                  hintText: 'Mô tả ngắn về thương hiệu',
                  prefixIcon: Icons.notes_rounded,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminFormField(
                  controller: _logoController,
                  label: 'URL logo',
                  hintText: 'https://...',
                  prefixIcon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  validator: BrandLogoUrlValidator.validate,
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  color: AdminColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    value: _isActive,
                    activeTrackColor: AdminColors.primary,
                    title: Text(
                      'Đang hoạt động',
                      style: AppTextStyles.body.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Cho phép thương hiệu xuất hiện trong danh mục.',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AdminColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        _DialogSaveButton(onPressed: _submit),
      ],
    );
  }
}
