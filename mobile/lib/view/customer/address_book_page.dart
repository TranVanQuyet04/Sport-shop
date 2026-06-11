import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/address_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/address_model.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  late final AddressController _controller = AddressController(
    addressRepository: AppDependencies.instance.addressRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadAddresses();
  }

  @override
  void dispose() {
    _controller
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
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Sổ địa chỉ'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadAddresses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadAddresses,
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: 'Thêm địa chỉ mới',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.addAddress),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.addresses.isEmpty) {
      return const AppLoadingState(title: 'Đang tải địa chỉ');
    }

    if (_controller.errorMessage != null && _controller.addresses.isEmpty) {
      return AppErrorState(
        title: 'Không tải được địa chỉ',
        message: _controller.errorMessage!,
        onAction: _controller.loadAddresses,
      );
    }

    if (_controller.addresses.isEmpty) {
      return AppEmptyState(
        title: 'Bạn chưa có địa chỉ',
        message: 'Thêm địa chỉ để có thể thanh toán đơn hàng.',
        actionLabel: 'Thêm địa chỉ',
        onAction: () => context.go(AppRoutes.addAddress),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.addresses.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final address = _controller.addresses[index];
        return _AddressCard(
          address: address,
          isBusy: _controller.isSubmitting,
          onSetDefault: () => _controller.setDefault(address.id),
          onDelete: () => _controller.deleteAddress(address.id),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isBusy,
    required this.onSetDefault,
    required this.onDelete,
  });

  final AddressModel address;
  final bool isBusy;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.displayName,
                    style: AppTextStyles.subtitle,
                  ),
                ),
                if (address.isDefault)
                  Text(
                    'Mặc định',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              address.displayAddress,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                TextButton(
                  onPressed: isBusy ? null : onDelete,
                  child: const Text('Xóa'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: isBusy || address.isDefault ? null : onSetDefault,
                  child: const Text('Đặt mặc định'),
                ),
                Icon(
                  address.isDefault
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: address.isDefault
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
