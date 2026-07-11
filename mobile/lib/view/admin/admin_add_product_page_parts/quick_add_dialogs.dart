part of '../admin_add_product_page.dart';

extension _AdminAddProductQuickAddDialogs on _AdminAddProductPageState {
  void _onQuickAddCategory() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm mới danh mục'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên danh mục *'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                Navigator.pop(ctx);

                updateState(() => _isLoadingLookups = true);
                final success = await _presenter.saveCategory(
                  name: name,
                  description: desc,
                );
                if (success) {
                  await _loadLookups();
                  updateState(() {
                    _selectedCategory =
                        _categories.any(
                          (c) => c.name.toLowerCase() == name.toLowerCase(),
                        )
                        ? _categories.firstWhere(
                            (c) => c.name.toLowerCase() == name.toLowerCase(),
                          )
                        : (_categories.isNotEmpty ? _categories.last : null);
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã tạo danh mục "$name".')),
                    );
                  }
                } else {
                  updateState(() => _isLoadingLookups = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _presenter.errorMessage ?? 'Không tạo được danh mục.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Tạo mới'),
            ),
          ],
        );
      },
    );
  }

  void _onQuickAddBrand() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final logoController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm mới thương hiệu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thương hiệu *',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: logoController,
                decoration: const InputDecoration(labelText: 'URL Logo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                final logo = logoController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                final logoError = BrandLogoUrlValidator.validate(logo);
                if (logoError != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(logoError)));
                  return;
                }
                Navigator.pop(ctx);

                updateState(() => _isLoadingLookups = true);
                final success = await _presenter.saveBrand(
                  name: name,
                  description: desc,
                  logo: BrandLogoUrlValidator.normalize(logo),
                  isActive: true,
                );
                if (success) {
                  await _loadLookups();
                  updateState(() {
                    _selectedBrand =
                        _brands.any(
                          (b) => b.name.toLowerCase() == name.toLowerCase(),
                        )
                        ? _brands.firstWhere(
                            (b) => b.name.toLowerCase() == name.toLowerCase(),
                          )
                        : (_brands.isNotEmpty ? _brands.last : null);
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã tạo thương hiệu "$name".')),
                    );
                  }
                } else {
                  updateState(() => _isLoadingLookups = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _presenter.errorMessage ??
                              'Không tạo được thương hiệu.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Tạo mới'),
            ),
          ],
        );
      },
    );
  }

  void _onQuickAddSport() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm mới môn thể thao'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn thể thao *',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                Navigator.pop(ctx);

                updateState(() => _isLoadingLookups = true);
                final success = await _presenter.saveSport(
                  name: name,
                  description: desc,
                );
                if (success) {
                  await _loadLookups();
                  updateState(() {
                    _selectedSport =
                        _sports.any(
                          (s) => s.name.toLowerCase() == name.toLowerCase(),
                        )
                        ? _sports.firstWhere(
                            (s) => s.name.toLowerCase() == name.toLowerCase(),
                          )
                        : (_sports.isNotEmpty ? _sports.last : null);
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã tạo môn thể thao "$name".')),
                    );
                  }
                } else {
                  updateState(() => _isLoadingLookups = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _presenter.errorMessage ??
                              'Không tạo được môn thể thao.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Tạo mới'),
            ),
          ],
        );
      },
    );
  }
}
