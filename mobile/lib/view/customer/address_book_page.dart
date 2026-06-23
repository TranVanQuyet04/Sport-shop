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
import '../../core/widgets/app_text_field.dart';
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
        title: const Text('Address book'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
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
            label: 'Add new address',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.addAddress),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.addresses.isEmpty) {
      return const AppLoadingState(title: 'Loading addresses');
    }

    if (_controller.errorMessage != null && _controller.addresses.isEmpty) {
      return AppErrorState(
        title: 'Could not load addresses',
        message: _controller.errorMessage!,
        onAction: _controller.loadAddresses,
      );
    }

    if (_controller.addresses.isEmpty) {
      return AppEmptyState(
        title: 'No addresses yet',
        message: 'Add a shipping address before checkout.',
        actionLabel: 'Add address',
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
          onEdit: () => _showEditAddressSheet(address),
          onSetDefault: () => _controller.setDefault(address.id),
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
          title: const Text('Delete address?'),
          content: Text(address.displayAddress),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _controller.deleteAddress(address.id);
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
              String? requiredError(TextEditingController controller, String label) {
                if (!hasSubmitted || controller.text.trim().isNotEmpty) {
                  return null;
                }
                return '$label is required.';
              }

              final phoneText = phoneController.text.trim();
              final phoneError = !hasSubmitted || phoneText.isEmpty
                  ? requiredError(phoneController, 'Phone number')
                  : RegExp(r'^(0|\+84)[0-9\s.]{8,13}$').hasMatch(phoneText)
                      ? null
                      : 'Phone number is invalid.';

              final canSubmit = nameController.text.trim().isNotEmpty &&
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
                final success = await _controller.updateAddress(
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
                    content: Text(_controller.errorMessage ?? 'Could not update address.'),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Edit address', style: AppTextStyles.title),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Recipient name',
                      controller: nameController,
                      prefixIcon: Icons.person_outline,
                      errorText: requiredError(nameController, 'Recipient name'),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Phone number',
                      controller: phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText: phoneError,
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'City',
                      controller: cityController,
                      prefixIcon: Icons.location_city_outlined,
                      errorText: requiredError(cityController, 'City'),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'District',
                      controller: districtController,
                      prefixIcon: Icons.map_outlined,
                      errorText: requiredError(districtController, 'District'),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Ward',
                      controller: wardController,
                      prefixIcon: Icons.place_outlined,
                      errorText: requiredError(wardController, 'Ward'),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Street',
                      controller: streetController,
                      prefixIcon: Icons.home_outlined,
                      maxLines: 3,
                      errorText: requiredError(streetController, 'Street'),
                      onChanged: (_) => setSheetState(() {}),
                      onSubmitted: (_) => save(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SwitchListTile(
                      value: isDefault,
                      onChanged: isSaving ? null : (value) => setSheetState(() => isDefault = value),
                      title: const Text('Set as default address'),
                      secondary: const Icon(Icons.star_border_outlined),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Save address',
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
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isBusy,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final AddressModel address;
  final bool isBusy;
  final VoidCallback onEdit;
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
                    'Default',
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
                IconButton(
                  tooltip: 'Edit',
                  onPressed: isBusy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: isBusy ? null : onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
                const Spacer(),
                TextButton(
                  onPressed: isBusy || address.isDefault ? null : onSetDefault,
                  child: const Text('Set default'),
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
