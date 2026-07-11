part of '../admin_category_management_page.dart';

class _CategoryFormResult {
  const _CategoryFormResult({
    required this.name,
    required this.description,
    required this.parentId,
  });

  final String name;
  final String description;
  final String parentId;
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category, required this.categories});

  final AdminCategoryModel? category;
  final List<AdminCategoryModel> categories;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.category?.name ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.category?.description ?? '');
  late String _parentId = widget.category?.parentId ?? '';

  List<AdminCategoryModel> get _parentOptions => widget.categories
      .where((category) => category.id != widget.category?.id)
      .toList();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _CategoryFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        parentId: _parentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final validParentIds = _parentOptions.map((item) => item.id).toSet();
    final selectedParentId = validParentIds.contains(_parentId)
        ? _parentId
        : '';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actionsAlignment: MainAxisAlignment.end,
      title: _DialogTitle(
        title: isEditing ? 'Sửa danh mục' : 'Thêm danh mục',
        subtitle: 'Thiết lập thông tin và danh mục cha.',
        icon: Icons.category_outlined,
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminFormField(
                  controller: _nameController,
                  label: 'Tên danh mục',
                  hintText: 'Ví dụ: Giày chạy bộ',
                  prefixIcon: Icons.category_outlined,
                  required: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminFormField(
                  controller: _descriptionController,
                  label: 'Mô tả',
                  hintText: 'Mô tả ngắn về nhóm sản phẩm',
                  prefixIcon: Icons.notes_rounded,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Danh mục cha',
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedParentId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Không có - Danh mục gốc'),
                    ),
                    ..._parentOptions.map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _parentId = value ?? ''),
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
