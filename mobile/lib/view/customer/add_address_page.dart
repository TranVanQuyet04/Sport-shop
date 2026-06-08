import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Thêm địa chỉ mới'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Thông tin người nhận', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          const TextField(decoration: InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: AppSpacing.lg),
          const TextField(decoration: InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: AppSpacing.xl),
          Text('Địa chỉ giao hàng', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          const TextField(decoration: InputDecoration(labelText: 'Tỉnh / Thành phố', prefixIcon: Icon(Icons.location_city_outlined))),
          const SizedBox(height: AppSpacing.lg),
          const TextField(decoration: InputDecoration(labelText: 'Quận / Huyện')),
          const SizedBox(height: AppSpacing.lg),
          const TextField(decoration: InputDecoration(labelText: 'Phường / Xã')),
          const SizedBox(height: AppSpacing.lg),
          const TextField(minLines: 3, maxLines: 4, decoration: InputDecoration(labelText: 'Địa chỉ cụ thể')),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Đặt làm địa chỉ mặc định')),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(label: 'Lưu địa chỉ', variant: AppButtonVariant.secondary, onPressed: context.pop),
        ),
      ),
    );
  }
}
