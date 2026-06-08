import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedColor = 0;
  int selectedSize = 40;

  @override
  Widget build(BuildContext context) {
    final price = NumberFormat.decimalPattern('vi_VN').format(3500000);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Center(child: Text('CHI TIẾT')),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.share_outlined)),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 500,
            color: const Color(0xFFECEFF1),
            child: InkWell(
              onTap: () => context.go('/customer/products/${widget.productId}/gallery'),
              child: const Center(
                child: Icon(Icons.directions_run, size: 180, color: AppColors.secondary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'RUNNING PERFORMANCE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: AppColors.surfaceMuted,
                      child: Icon(Icons.favorite_border, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('NIKE AIR MAX 270', style: AppTextStyles.display.copyWith(fontSize: 28)),
                const SizedBox(height: AppSpacing.sm),
                Text('$priceđ', style: AppTextStyles.display.copyWith(fontSize: 30)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Nike Air Max 270 mang đến phong cách hiện đại kết hợp với đệm Air lớn nhất từ trước đến nay, mang lại cảm giác siêu mềm mại và vẻ ngoài ấn tượng.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.78)),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text('MÀU SẮC', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _ColorDot(color: Colors.black, selected: selectedColor == 0, onTap: () => setState(() => selectedColor = 0)),
                    _ColorDot(color: AppColors.secondary, selected: selectedColor == 1, onTap: () => setState(() => selectedColor = 1)),
                    _ColorDot(color: Colors.white, selected: selectedColor == 2, onTap: () => setState(() => selectedColor = 2)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Text('CHỌN SIZE (VN)', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('Bảng size', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, decoration: TextDecoration.underline)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [38, 39, 40, 41, 42, 43, 44].map((size) {
                    return ChoiceChip(
                      label: SizedBox(width: 48, child: Center(child: Text('$size'))),
                      selected: selectedSize == size,
                      onSelected: (_) => setState(() => selectedSize = size),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selectedSize == size ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _InfoTile(title: 'Chính sách vận chuyển'),
                const _InfoTile(title: 'Chính sách đổi trả'),
                const _InfoTile(title: 'Đánh giá (128)', trailing: '☆ 4.8'),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'THÊM VÀO GIỎ',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.go(AppRoutes.cart),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'MUA NGAY',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go(AppRoutes.cart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == Colors.white ? Border.all(color: AppColors.border) : null,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
      trailing: Text(trailing ?? '›', style: AppTextStyles.body.copyWith(color: AppColors.secondary)),
    );
  }
}
