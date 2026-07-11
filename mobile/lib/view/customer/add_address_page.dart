import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../presenter/customer/address_presenter.dart';

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
  bool _hasSubmitted = false;

  late final AddressPresenter _presenter = AddressPresenter(
    addressRepository: AppDependencies.instance.addressRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _presenter
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

  String? _requiredError(TextEditingController controller, String message) {
    if (!_hasSubmitted || controller.text.trim().isNotEmpty) {
      return null;
    }
    return message;
  }

  String? get _phoneError {
    final phone = _phoneController.text.trim();
    if (!_hasSubmitted || phone.isEmpty) {
      return _requiredError(_phoneController, 'Vui lòng nhập số điện thoại.');
    }
    return _isVietnamesePhone(phone)
        ? null
        : 'Số điện thoại chưa đúng định dạng.';
  }

  bool get _canSubmit {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _phoneError == null &&
        _cityController.text.trim().isNotEmpty &&
        _districtController.text.trim().isNotEmpty &&
        _wardController.text.trim().isNotEmpty &&
        _streetController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _leavePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Thêm địa chỉ mới'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Thông tin người nhận', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Họ và tên',
            hintText: 'Nhập họ và tên',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            errorText: _requiredError(_nameController, 'Vui lòng nhập họ tên.'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Số điện thoại',
            hintText: 'Nhập số điện thoại',
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            errorText: _phoneError,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Địa chỉ giao hàng', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Tỉnh / Thành phố',
            hintText: 'Nhập tỉnh hoặc thành phố',
            controller: _cityController,
            prefixIcon: Icons.location_city_outlined,
            textInputAction: TextInputAction.next,
            errorText: _requiredError(
              _cityController,
              'Vui lòng nhập tỉnh/thành phố.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Quận / Huyện',
            hintText: 'Nhập quận hoặc huyện',
            controller: _districtController,
            prefixIcon: Icons.map_outlined,
            textInputAction: TextInputAction.next,
            errorText: _requiredError(
              _districtController,
              'Vui lòng nhập quận/huyện.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Phường / Xã',
            hintText: 'Nhập phường hoặc xã',
            controller: _wardController,
            prefixIcon: Icons.place_outlined,
            textInputAction: TextInputAction.next,
            errorText: _requiredError(
              _wardController,
              'Vui lòng nhập phường/xã.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Địa chỉ cụ thể',
            hintText: 'Số nhà, tên đường, tòa nhà...',
            controller: _streetController,
            prefixIcon: Icons.home_outlined,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            errorText: _requiredError(
              _streetController,
              'Vui lòng nhập địa chỉ cụ thể.',
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _saveAddress(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SwitchListTile(
              value: _isDefault,
              onChanged: _presenter.isSubmitting
                  ? null
                  : (value) => setState(() => _isDefault = value),
              title: const Text('Đặt làm địa chỉ mặc định'),
              secondary: const Icon(Icons.star_border_outlined),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          if (_presenter.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _presenter.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
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
            isLoading: _presenter.isSubmitting,
            onPressed: _saveAddress,
          ),
        ),
      ),
    );
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
    context.go('/customer/addresses');
  }

  Future<void> _saveAddress() async {
    setState(() => _hasSubmitted = true);
    if (!_canSubmit) {
      return;
    }

    final success = await _presenter.createAddress(
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
      _leavePage();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_presenter.errorMessage ?? 'Không thể lưu địa chỉ.'),
      ),
    );
  }
}
