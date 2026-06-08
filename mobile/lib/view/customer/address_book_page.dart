import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class AddressBookPage extends StatelessWidget {
  const AddressBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Sổ địa chỉ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _AddressCard(
            name: 'Nguyễn Văn A',
            phone: '090 123 4567',
            address: '123 Đường Lê Lợi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh',
            isDefault: true,
          ),
          SizedBox(height: AppSpacing.lg),
          _AddressCard(
            name: 'Nguyễn Văn A',
            phone: '091 888 7777',
            address: '45 Nguyễn Trãi, Phường 2, Quận 5, TP. Hồ Chí Minh',
          ),
        ],
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
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  final String name;
  final String phone;
  final String address;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: isDefault ? AppColors.primary : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('$name • $phone', style: AppTextStyles.subtitle)),
                if (isDefault)
                  Text('Mặc định', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(address, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Sửa')),
                TextButton(onPressed: () {}, child: const Text('Xóa')),
                const Spacer(),
                Icon(
                  isDefault ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isDefault ? AppColors.secondary : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
