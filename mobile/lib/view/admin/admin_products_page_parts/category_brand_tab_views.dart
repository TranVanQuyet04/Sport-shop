part of '../admin_products_page.dart';

// --- CATEGORY HOVER CARD / WIDGET PARTS ---

class _CategoryListItemTile extends StatelessWidget {
  const _CategoryListItemTile({
    required this.category,
    required this.parentName,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  final AdminCategoryModel category;
  final String? parentName;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Icon(
                Icons.category_outlined,
                color: Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      if (parentName != null && parentName!.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            parentName!,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AdminColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (category.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: const TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF475569),
                size: 20,
              ),
              onPressed: onTapEdit,
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              onPressed: onTapDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBlockActionButton extends StatelessWidget {
  const _CategoryBlockActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'THÊM DANH MỤC MỚI +',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// --- BRAND HOVER CARD / WIDGET PARTS ---

class _BrandListItemTile extends StatelessWidget {
  const _BrandListItemTile({
    required this.brand,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  final AdminBrandModel brand;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD1FAE5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: brand.logo.isNotEmpty
                  ? Image.network(
                      brand.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF10B981),
                        size: 22,
                      ),
                    )
                  : const Icon(
                      Icons.verified_outlined,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        brand.name,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: brand.isActive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          brand.isActive ? 'Hoạt động' : 'Tạm khóa',
                          style: TextStyle(
                            fontSize: 9,
                            color: brand.isActive
                                ? const Color(0xFF16A34A)
                                : AdminColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (brand.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      brand.description,
                      style: const TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF475569),
                size: 20,
              ),
              onPressed: onTapEdit,
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              onPressed: onTapDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBlockActionButton extends StatelessWidget {
  const _BrandBlockActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'THÊM THƯƠNG HIỆU MỚI +',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// --- MAIN EXTENSION STATE FOR ADMIN PRODUCTS PAGE ---

extension _CategoryBrandTabViews on _AdminProductsPageState {
  // --- RENDERING TABS ---

  Widget _buildCategoriesTabContent(BuildContext context) {
    final displayCategories = _presenter.categories.where((c) {
      if (_presenter.searchKeyword.isEmpty) return true;
      return c.name.toLowerCase().contains(
        _presenter.searchKeyword.toLowerCase(),
      );
    }).toList();

    if (displayCategories.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: PremiumEmptyState(
                icon: Icons.category_outlined,
                title: 'Chưa có danh mục',
                message: _presenter.searchKeyword.isNotEmpty
                    ? 'Không tìm thấy danh mục nào phù hợp.'
                    : 'Hãy tạo danh mục đầu tiên để phân loại sản phẩm.',
                actionLabel: 'Thêm danh mục',
                onAction: _goToCreateCategory,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _CategoryBlockActionButton(onPressed: _goToCreateCategory),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: displayCategories.length,
              itemBuilder: (context, index) {
                final category = displayCategories[index];
                return _CategoryListItemTile(
                  category: category,
                  parentName: _parentNameFor(category),
                  onTapEdit: () => _goToEditCategory(category),
                  onTapDelete: () => _deleteCategory(category),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _CategoryBlockActionButton(onPressed: _goToCreateCategory),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsTabContent(BuildContext context) {
    final displayBrands = _presenter.brands.where((b) {
      if (_presenter.searchKeyword.isEmpty) return true;
      return b.name.toLowerCase().contains(
        _presenter.searchKeyword.toLowerCase(),
      );
    }).toList();

    if (displayBrands.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: PremiumEmptyState(
                icon: Icons.verified_outlined,
                title: 'Chưa có thương hiệu',
                message: _presenter.searchKeyword.isNotEmpty
                    ? 'Không tìm thấy thương hiệu nào phù hợp.'
                    : 'Hãy tạo thương hiệu mới để gắn thẻ cho sản phẩm.',
                actionLabel: 'Thêm thương hiệu',
                onAction: _goToCreateBrand,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _BrandBlockActionButton(onPressed: _goToCreateBrand),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: displayBrands.length,
              itemBuilder: (context, index) {
                final brand = displayBrands[index];
                return _BrandListItemTile(
                  brand: brand,
                  onTapEdit: () => _goToEditBrand(brand),
                  onTapDelete: () => _deleteBrand(brand),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _BrandBlockActionButton(onPressed: _goToCreateBrand),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // --- HELPER LOGIC FOR CATEGORIES ---

  String? _parentNameFor(AdminCategoryModel category) {
    if (category.parentId.isEmpty) return null;
    final parent = _presenter.categories.firstWhere(
      (c) => c.id == category.parentId,
      orElse: () => const AdminCategoryModel(
        id: '',
        name: '',
        description: '',
        parentId: '',
      ),
    );
    return parent.name.isNotEmpty ? parent.name : null;
  }

  Future<void> _goToCreateCategory() async {
    final nameCtl = TextEditingController();
    final descCtl = TextEditingController();
    String? selectedParentId;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm danh mục'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Tên danh mục *',
                        hintText: 'Ví dụ: Áo khoác, Giày chạy...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: descCtl,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Mô tả ngắn gọn về danh mục',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedParentId,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục cha (Tùy chọn)',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Không có (Danh mục gốc)'),
                        ),
                        ..._presenter.categories.map((c) {
                          return DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedParentId = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && nameCtl.text.trim().isNotEmpty) {
      final success = await _presenter.saveCategory(
        name: nameCtl.text.trim(),
        description: descCtl.text.trim(),
        parentId: selectedParentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã thêm danh mục thành công'
                  : 'Thêm danh mục thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _goToEditCategory(AdminCategoryModel category) async {
    final nameCtl = TextEditingController(text: category.name);
    final descCtl = TextEditingController(text: category.description);
    String? selectedParentId = category.parentId.isNotEmpty
        ? category.parentId
        : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sửa danh mục'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Tên danh mục *',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: descCtl,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedParentId,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục cha (Tùy chọn)',
                      ),
                      // Prevent circular dependency: cannot set self as parent
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Không có (Danh mục gốc)'),
                        ),
                        ..._presenter.categories
                            .where((c) => c.id != category.id)
                            .map((c) {
                              return DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedParentId = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && nameCtl.text.trim().isNotEmpty) {
      final success = await _presenter.saveCategory(
        id: category.id,
        name: nameCtl.text.trim(),
        description: descCtl.text.trim(),
        parentId: selectedParentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Đã sửa danh mục thành công' : 'Sửa danh mục thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _deleteCategory(AdminCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text(
          'Bạn có chắc muốn xóa danh mục "${category.name}"? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _presenter.deleteCategory(category.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Đã xóa danh mục thành công' : 'Xóa danh mục thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  // --- HELPER LOGIC FOR BRANDS ---

  Future<void> _goToCreateBrand() async {
    final nameCtl = TextEditingController();
    final descCtl = TextEditingController();
    final logoCtl = TextEditingController();
    bool isActiveValue = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm thương hiệu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Tên thương hiệu *',
                        hintText: 'Ví dụ: Nike, Adidas...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: descCtl,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Mô tả ngắn gọn thương hiệu',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: logoCtl,
                      decoration: const InputDecoration(
                        labelText: 'URL Logo',
                        hintText: 'Địa chỉ ảnh logo thương hiệu',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      title: const Text(
                        'Trạng thái hoạt động',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: isActiveValue,
                      activeThumbColor: AdminColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          isActiveValue = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && nameCtl.text.trim().isNotEmpty) {
      final logoError = BrandLogoUrlValidator.validate(logoCtl.text);
      if (logoError != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(logoError)));
        }
        return;
      }
      final success = await _presenter.saveBrand(
        name: nameCtl.text.trim(),
        description: descCtl.text.trim(),
        logo: BrandLogoUrlValidator.normalize(logoCtl.text),
        isActive: isActiveValue,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã thêm thương hiệu thành công'
                  : 'Thêm thương hiệu thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _goToEditBrand(AdminBrandModel brand) async {
    final nameCtl = TextEditingController(text: brand.name);
    final descCtl = TextEditingController(text: brand.description);
    final logoCtl = TextEditingController(text: brand.logo);
    bool isActiveValue = brand.isActive;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sửa thương hiệu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Tên thương hiệu *',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: descCtl,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: logoCtl,
                      decoration: const InputDecoration(labelText: 'URL Logo'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      title: const Text(
                        'Trạng thái hoạt động',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: isActiveValue,
                      activeThumbColor: AdminColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          isActiveValue = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && nameCtl.text.trim().isNotEmpty) {
      final logoError = BrandLogoUrlValidator.validate(logoCtl.text);
      if (logoError != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(logoError)));
        }
        return;
      }
      final success = await _presenter.saveBrand(
        id: brand.id,
        name: nameCtl.text.trim(),
        description: descCtl.text.trim(),
        logo: BrandLogoUrlValidator.normalize(logoCtl.text),
        isActive: isActiveValue,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã sửa thương hiệu thành công'
                  : 'Sửa thương hiệu thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _deleteBrand(AdminBrandModel brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa thương hiệu?'),
        content: Text(
          'Bạn có chắc muốn xóa thương hiệu "${brand.name}"? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _presenter.deleteBrand(brand.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã xóa thương hiệu thành công'
                  : 'Xóa thương hiệu thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }
}
