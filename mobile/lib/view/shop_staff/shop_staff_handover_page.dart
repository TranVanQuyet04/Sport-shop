import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../admin/widgets/admin_app_bar.dart';

class ShopStaffHandoverPage extends StatefulWidget {
  const ShopStaffHandoverPage({super.key});

  @override
  State<ShopStaffHandoverPage> createState() => _ShopStaffHandoverPageState();
}

class _ShopStaffHandoverPageState extends State<ShopStaffHandoverPage> {
  late final AdminOrdersController _ordersController = AdminOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );
  late final AdminCatalogController _catalogController = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final _noteController = TextEditingController();
  final Set<String> _selectedOrderIds = {};
  AdminUserModel? _selectedShipper;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ordersController.addListener(_onControllerChanged);
    _catalogController.addListener(_onControllerChanged);
    _loadData();
  }

  @override
  void dispose() {
    _ordersController
      ..removeListener(_onControllerChanged)
      ..dispose();
    _catalogController
      ..removeListener(_onControllerChanged)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _ordersController.loadOrders(),
      _catalogController.loadUsers(),
    ]);
  }

  List<OrderModel> get _readyOrders {
    return _ordersController.orders.where((order) {
      final status = order.status.toUpperCase();
      return status == 'PACKING' || status == 'SHIPPED';
    }).toList();
  }

  List<AdminUserModel> get _shippers {
    return _catalogController.users.where((user) {
      final role = user.roleName.toUpperCase();
      return user.status && (role == 'SHIPPER' || role == 'DELIVERY_STAFF');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedOrderIds.length;
    final isLoading =
        (_ordersController.isLoading || _catalogController.isLoading) &&
        _readyOrders.isEmpty;
    final errorMessage =
        _ordersController.errorMessage ?? _catalogController.errorMessage;

    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const AppLoadingState(title: 'Dang tai don ban giao')
            : errorMessage != null && _readyOrders.isEmpty
            ? AppErrorState(
                title: 'Khong tai duoc ban giao',
                message: errorMessage,
                onAction: _loadData,
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const _Header(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Chon nhan vien giao hang', style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: _showShipperPicker,
                    child: AbsorbPointer(
                      child: AppTextField(
                        label: 'Nhan vien giao hang',
                        initialValue: _selectedShipper == null
                            ? ''
                            : '${_selectedShipper!.fullName} - ${_selectedShipper!.roleName}',
                        prefixIcon: Icons.local_shipping_outlined,
                        suffixIcon: Icons.keyboard_arrow_down,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Don hang san sang (${_readyOrders.length})',
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleAll,
                        child: Text(
                          selectedCount == _readyOrders.length
                              ? 'Bo chon'
                              : 'Chon tat ca',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_readyOrders.isEmpty)
                    const AppEmptyState(
                      title: 'Khong co don san sang',
                      message: 'Don PACKING hoac SHIPPED se hien thi tai day.',
                    )
                  else
                    ..._readyOrders.map(
                      (order) => _ReadyOrder(
                        order: order,
                        selected: _selectedOrderIds.contains(order.id),
                        onChanged: _toggleOrder,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: _noteController,
                    label: 'Ghi chu ban giao',
                    prefixIcon: Icons.edit_note_outlined,
                    maxLines: 4,
                    hintText: 'Nhap luu y cho nhan vien giao hang...',
                  ),
                  const SizedBox(height: 120),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Da chon: ', style: AppTextStyles.caption),
                  Text(
                    '$selectedCount don hang',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text('Tong cong: ', style: AppTextStyles.caption),
                  Text(
                    _selectedTotal,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'BAN GIAO GIAO HANG',
                variant: AppButtonVariant.secondary,
                icon: Icons.local_shipping_outlined,
                isLoading: _isSubmitting,
                onPressed: selectedCount == 0 || _selectedShipper == null
                    ? null
                    : _handover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _selectedTotal {
    final total = _readyOrders
        .where((order) => _selectedOrderIds.contains(order.id))
        .fold<int>(0, (sum, order) => sum + order.totalAmount);
    return '${NumberFormat.decimalPattern('vi_VN').format(total)}d';
  }

  void _toggleOrder(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedOrderIds.add(id);
      } else {
        _selectedOrderIds.remove(id);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_selectedOrderIds.length == _readyOrders.length) {
        _selectedOrderIds.clear();
      } else {
        _selectedOrderIds
          ..clear()
          ..addAll(_readyOrders.map((order) => order.id));
      }
    });
  }

  void _showShipperPicker() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Chon nhan vien giao hang',
      subtitle: 'Danh sach lay truc tiep tu backend.',
      child: _shippers.isEmpty
          ? const AppEmptyState(
              title: 'Chua co shipper',
              message: 'Tao user SHIPPER hoac DELIVERY_STAFF truoc.',
            )
          : Column(
              children: _shippers
                  .map(
                    (shipper) => ListTile(
                      onTap: () {
                        setState(() => _selectedShipper = shipper);
                        Navigator.pop(context);
                      },
                      leading: Icon(
                        _selectedShipper?.id == shipper.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _selectedShipper?.id == shipper.id
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                      ),
                      title: Text(shipper.fullName, style: AppTextStyles.body),
                      subtitle: Text(shipper.roleName),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Future<void> _handover() async {
    final shipper = _selectedShipper;
    if (shipper == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      for (final orderId in _selectedOrderIds) {
        await AppDependencies.instance.apiClient.putJson(
          '/admin/order-assignments/orders/$orderId',
          data: {
            'staffId': int.parse(shipper.id),
            'note': _noteController.text.trim(),
          },
        );
      }
      if (!mounted) return;
      final selectedCount = _selectedOrderIds.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da ban giao $selectedCount don cho ${shipper.fullName}.')),
      );
      final firstOrderId = _selectedOrderIds.isEmpty ? '' : _selectedOrderIds.first;
      context.go(
        AppRoutes.shopStaffOrderTimeline.replaceFirst(':id', firstOrderId),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ban giao van chuyen',
          style: AppTextStyles.display.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Kiem tra va xac nhan ban giao don hang cho nhan vien giao hang.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ReadyOrder extends StatelessWidget {
  const _ReadyOrder({
    required this.order,
    required this.selected,
    required this.onChanged,
  });

  final OrderModel order;
  final bool selected;
  final void Function(String id, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${order.id}', style: AppTextStyles.body),
                Text(order.firstProductName, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  '${NumberFormat.decimalPattern('vi_VN').format(order.totalAmount)}d',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          OrderStatusBadge(status: OrderStatus.fromApi(order.status)),
          Checkbox(
            value: selected,
            onChanged: (value) => onChanged(order.id, value ?? false),
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
