import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/customer/address_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _streetController = TextEditingController();
  bool _isDefault = true;

  late final AddressController _controller = AddressController(
    addressRepository: AppDependencies.instance.addressRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _streetController.dispose();
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
        title: const Text('Thêm địa chỉ mới'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Thông tin người nhận', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Địa chỉ giao hàng', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Tỉnh / Thành phố',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _districtController,
            decoration: const InputDecoration(labelText: 'Quận / Huyện'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _wardController,
            decoration: const InputDecoration(labelText: 'Phường / Xã'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _streetController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Địa chỉ cụ thể'),
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value),
            title: const Text('Đặt làm địa chỉ mặc định'),
          ),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: 'Lưu địa chỉ',
            variant: AppButtonVariant.secondary,
            isLoading: _controller.isSubmitting,
            onPressed: _saveAddress,
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    final success = await _controller.createAddress(
      recipientName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      ward: _wardController.text.trim(),
      street: _streetController.text.trim(),
      isDefault: _isDefault,
    );
    if (!mounted) {
      return;
    }
    if (success) {
      context.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.errorMessage ?? 'Không thể lưu địa chỉ.'),
      ),
    );
  }
}
