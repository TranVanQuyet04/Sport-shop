import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/order_status.dart';
import '../admin/widgets/admin_app_bar.dart';

class ShopStaffHandoverPage extends StatefulWidget {
  const ShopStaffHandoverPage({super.key});

  @override
  State<ShopStaffHandoverPage> createState() => _ShopStaffHandoverPageState();
}

class _ShopStaffHandoverPageState extends State<ShopStaffHandoverPage> {
  static const _shippers = [
    'Lê Minh Khang - DELIVERY_STAFF',
    'Trần Quốc Bảo - DELIVERY_STAFF',
    'Nguyễn Hoàng Nam - SHIPPER',
  ];

  final Set<String> _selectedOrderIds = {'AV-8829', 'AV-8830', 'AV-8831'};
  String _selectedShipper = _shippers.first;

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedOrderIds.length;
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _Header(),
          const SizedBox(height: AppSpacing.xl),
          const _DemoBanner(),
          const SizedBox(height: AppSpacing.xl),
          Text('Chọn nhân viên giao hàng', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: _showShipperPicker,
            child: AbsorbPointer(
              child: AppTextField(
                label: 'Nhân viên giao hàng',
                initialValue: _selectedShipper,
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
                  'Đơn hàng sẵn sàng (03)',
                  style: AppTextStyles.subtitle,
                ),
              ),
              TextButton(
                onPressed: _toggleAll,
                child: Text(
                  selectedCount == 3 ? 'Bỏ chọn' : 'Chọn tất cả',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadyOrder(
            id: 'AV-8829',
            name: 'Apex Velocity Pro-Run V2',
            price: '1.250.000đ',
            icon: Icons.directions_run,
            selected: _selectedOrderIds.contains('AV-8829'),
            onChanged: _toggleOrder,
          ),
          _ReadyOrder(
            id: 'AV-8830',
            name: 'Apex Stealth Watch Edition',
            price: '3.400.000đ',
            icon: Icons.watch_outlined,
            selected: _selectedOrderIds.contains('AV-8830'),
            onChanged: _toggleOrder,
          ),
          _ReadyOrder(
            id: 'AV-8831',
            name: 'Aero-Carbon Performance',
            price: '5.100.000đ',
            icon: Icons.sports_football_outlined,
            selected: _selectedOrderIds.contains('AV-8831'),
            onChanged: _toggleOrder,
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppTextField(
            label: 'Ghi chú bàn giao',
            prefixIcon: Icons.edit_note_outlined,
            maxLines: 4,
            hintText:
                'Nhập lưu ý cho nhân viên giao hàng, ví dụ: giao trong sáng nay...',
          ),
          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Đã chọn: ', style: AppTextStyles.caption),
                  Text(
                    '$selectedCount đơn hàng',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text('Tổng cộng: ', style: AppTextStyles.caption),
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
                label: 'BÀN GIAO GIAO HÀNG',
                variant: AppButtonVariant.secondary,
                icon: Icons.local_shipping_outlined,
                onPressed: selectedCount == 0 ? null : _handover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _selectedTotal {
    final values = {'AV-8829': 1250000, 'AV-8830': 3400000, 'AV-8831': 5100000};
    final total = _selectedOrderIds.fold<int>(
      0,
      (sum, id) => sum + (values[id] ?? 0),
    );
    final text = total.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$textđ';
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
      if (_selectedOrderIds.length == 3) {
        _selectedOrderIds.clear();
      } else {
        _selectedOrderIds
          ..clear()
          ..addAll(['AV-8829', 'AV-8830', 'AV-8831']);
      }
    });
  }

  void _showShipperPicker() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Chọn nhân viên giao hàng',
      subtitle: 'Danh sách mẫu dùng cho demo UI-first.',
      child: Column(
        children: _shippers
            .map(
              (shipper) => ListTile(
                onTap: () {
                  setState(() => _selectedShipper = shipper);
                  Navigator.pop(context);
                },
                leading: Icon(
                  _selectedShipper == shipper
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _selectedShipper == shipper
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                ),
                title: Text(shipper, style: AppTextStyles.body),
              ),
            )
            .toList(),
      ),
    );
  }

  void _handover() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã bàn giao ${_selectedOrderIds.length} đơn cho $_selectedShipper ở chế độ demo.',
        ),
      ),
    );
    context.go(AppRoutes.shopStaffOrderTimeline.replaceFirst(':id', 'AV-8829'));
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
          'Bàn giao vận chuyển',
          style: AppTextStyles.display.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Kiểm tra và xác nhận bàn giao các đơn hàng đã đóng gói cho nhân viên giao hàng.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Handover đang dùng dữ liệu mẫu. Sau này backend cần API lưu phân công shipper.',
                style: AppTextStyles.caption.copyWith(color: AppColors.info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyOrder extends StatelessWidget {
  const _ReadyOrder({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  final String id;
  final String name;
  final String price;
  final IconData icon;
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
            child: Icon(icon, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#$id', style: AppTextStyles.body),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  price,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const OrderStatusBadge(status: OrderStatus.packing),
          Checkbox(
            value: selected,
            onChanged: (value) => onChanged(id, value ?? false),
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
