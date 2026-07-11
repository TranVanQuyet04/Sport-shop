import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/customer/address_model.dart';
import '../../presenter/customer/address_presenter.dart';

part 'address_book_page_parts/address_card_widgets.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  late final AddressPresenter _presenter = AddressPresenter(
    addressRepository: AppDependencies.instance.addressRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadAddresses();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _leavePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Sổ địa chỉ'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _presenter.isLoading ? null : _presenter.loadAddresses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadAddresses,
        child: _buildBody(),
      ),
      bottomNavigationBar: _presenter.addresses.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: AppButton(
                  label: 'Thêm địa chỉ mới',
                  icon: Icons.add_location_alt_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go(AppRoutes.addAddress),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_presenter.isLoading && _presenter.addresses.isEmpty) {
      return const AppLoadingState(title: 'Đang tải địa chỉ');
    }

    if (_presenter.errorMessage != null && _presenter.addresses.isEmpty) {
      return AppErrorState(
        title: 'Không tải được địa chỉ',
        message: _presenter.errorMessage!,
        actionLabel: _presenter.isUnauthorized ? 'Đăng nhập lại' : 'Thử lại',
        onAction: _presenter.isUnauthorized
            ? () => context.go(AppRoutes.login)
            : _presenter.loadAddresses,
      );
    }

    if (_presenter.addresses.isEmpty) {
      return _AddressEmptyState(
        onAdd: () => context.go(AppRoutes.addAddress),
        onRefresh: _presenter.loadAddresses,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: _presenter.addresses.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final address = _presenter.addresses[index];
        return _AddressCard(
          address: address,
          isBusy: _presenter.isSubmitting,
          onEdit: () => _showEditAddressSheet(address),
          onSetDefault: () => _presenter.setDefault(address.id),
          onDelete: () => _confirmDeleteAddress(address),
        );
      },
    );
  }

  Future<void> _confirmDeleteAddress(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa địa chỉ?'),
          content: Text(address.displayAddress),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _presenter.deleteAddress(address.id);
    }
  }

  Future<void> _showEditAddressSheet(AddressModel address) async {
    final nameController = TextEditingController(text: address.recipientName);
    final phoneController = TextEditingController(text: address.phoneNumber);
    final cityController = TextEditingController(text: address.city);
    final districtController = TextEditingController(text: address.district);
    final wardController = TextEditingController(text: address.ward);
    final streetController = TextEditingController(text: address.street);
    var isDefault = address.isDefault;
    var hasSubmitted = false;
    var isSaving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              String? requiredError(
                TextEditingController controller,
                String label,
              ) {
                if (!hasSubmitted || controller.text.trim().isNotEmpty) {
                  return null;
                }
                return '$label là bắt buộc.';
              }

              final phoneText = phoneController.text.trim();
              final phoneError = !hasSubmitted || phoneText.isEmpty
                  ? requiredError(phoneController, 'Số điện thoại')
                  : _isVietnamesePhone(phoneText)
                  ? null
                  : 'Số điện thoại không hợp lệ.';

              final canSubmit =
                  nameController.text.trim().isNotEmpty &&
                  phoneText.isNotEmpty &&
                  phoneError == null &&
                  cityController.text.trim().isNotEmpty &&
                  districtController.text.trim().isNotEmpty &&
                  wardController.text.trim().isNotEmpty &&
                  streetController.text.trim().isNotEmpty;

              Future<void> save() async {
                setSheetState(() => hasSubmitted = true);
                if (!canSubmit || isSaving) {
                  return;
                }
                setSheetState(() => isSaving = true);
                final success = await _presenter.updateAddress(
                  id: address.id,
                  recipientName: nameController.text.trim(),
                  phoneNumber: phoneText,
                  city: cityController.text.trim(),
                  district: districtController.text.trim(),
                  ward: wardController.text.trim(),
                  street: streetController.text.trim(),
                  isDefault: isDefault,
                );
                if (!context.mounted) {
                  return;
                }
                setSheetState(() => isSaving = false);
                if (success) {
                  Navigator.of(context).pop();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _presenter.errorMessage ?? 'Không thể cập nhật địa chỉ.',
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Chỉnh sửa địa chỉ',
                            style: AppTextStyles.title,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Đóng',
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Người nhận',
                      controller: nameController,
                      prefixIcon: Icons.person_outline,
                      errorText: requiredError(nameController, 'Người nhận'),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Số điện thoại',
                      controller: phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText: phoneError,
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Tỉnh/Thành phố',
                      controller: cityController,
                      prefixIcon: Icons.location_city_outlined,
                      errorText: requiredError(
                        cityController,
                        'Tỉnh/Thành phố',
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Quận/Huyện',
                      controller: districtController,
                      prefixIcon: Icons.map_outlined,
                      errorText: requiredError(
                        districtController,
                        'Quận/Huyện',
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Phường/Xã',
                      controller: wardController,
                      prefixIcon: Icons.place_outlined,
                      errorText: requiredError(wardController, 'Phường/Xã'),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Địa chỉ cụ thể',
                      controller: streetController,
                      prefixIcon: Icons.home_outlined,
                      maxLines: 3,
                      errorText: requiredError(
                        streetController,
                        'Địa chỉ cụ thể',
                      ),
                      onChanged: (_) => setSheetState(() {}),
                      onSubmitted: (_) => save(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SwitchListTile(
                      value: isDefault,
                      onChanged: isSaving
                          ? null
                          : (value) => setSheetState(() => isDefault = value),
                      title: const Text('Đặt làm địa chỉ mặc định'),
                      secondary: const Icon(Icons.star_border_outlined),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Lưu địa chỉ',
                      variant: AppButtonVariant.secondary,
                      isLoading: isSaving,
                      onPressed: save,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      cityController.dispose();
      districtController.dispose();
      wardController.dispose();
      streetController.dispose();
    }
  }

  bool _isVietnamesePhone(String value) {
    return RegExp(
      r'^(0|\+84)(\s|\.)?((3[2-9])|(5[689])|(7[06-9])|(8[1-689])|(9[0-46-9]))(\d)(\s|\.)?(\d{3})(\s|\.)?(\d{3})$',
    ).hasMatch(value);
  }

  void _leavePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.customerHome);
  }
}

class _AddressEmptyState extends StatelessWidget {
  const _AddressEmptyState({required this.onAdd, required this.onRefresh});

  final VoidCallback onAdd;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textSecondary,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Chưa có địa chỉ',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Thêm địa chỉ giao hàng để đặt hàng nhanh hơn và chọn làm mặc định khi thanh toán.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Thêm địa chỉ',
          icon: Icons.add_location_alt_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: onAdd,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 48,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tải lại danh sách'),
          ),
        ),
      ],
    );
  }
}
