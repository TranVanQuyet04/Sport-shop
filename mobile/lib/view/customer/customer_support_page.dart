import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class CustomerSupportPage extends StatefulWidget {
  const CustomerSupportPage({super.key});

  @override
  State<CustomerSupportPage> createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'Tôi có thể đổi size sau khi nhận hàng không?',
      'answer':
          'Có. Bạn có thể gửi yêu cầu đổi size trong vòng 7 ngày nếu sản phẩm còn nguyên tem và chưa qua sử dụng.',
      'category': 'Đổi trả',
    },
    {
      'question': 'Làm sao để theo dõi đơn hàng của tôi?',
      'answer':
          'Vào mục Đơn hàng, chọn đơn cần xem và bấm Theo dõi để xem trạng thái vận chuyển.',
      'category': 'Vận chuyển',
    },
    {
      'question': 'StrideX hỗ trợ phương thức thanh toán nào?',
      'answer':
          'Ứng dụng hỗ trợ thanh toán khi nhận hàng (COD) và VNPay nếu đơn hàng được tạo bằng phương thức online.',
      'category': 'Thanh toán',
    },
    {
      'question': 'Tôi muốn hủy đơn hàng thì làm thế nào?',
      'answer':
          'Đơn hàng ở trạng thái Chờ xác nhận có thể hủy trong chi tiết đơn hàng. Với đơn đã xử lý, hãy liên hệ hỗ trợ.',
      'category': 'Đơn hàng',
    },
    {
      'question': 'Tôi có thể cập nhật địa chỉ giao hàng không?',
      'answer':
          'Bạn có thể thêm, sửa, xóa và đặt mặc định địa chỉ trong mục Sổ địa chỉ trước khi thanh toán.',
      'category': 'Tài khoản',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesCategory =
          _selectedCategory == 'Tất cả' || faq['category'] == _selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.customerHome);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Trung tâm hỗ trợ'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Bạn cần hỗ trợ gì?',
            style: AppTextStyles.display.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tìm câu trả lời nhanh hoặc nhắn tin trực tiếp với bot hỗ trợ.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Tìm kiếm hướng dẫn',
            prefixIcon: Icons.search,
            hintText: 'Nhập câu hỏi hoặc từ khóa...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PrioritySupportCard(
            onChat: () => context.go(AppRoutes.customerChat),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Danh mục câu hỏi', style: AppTextStyles.subtitle),
              ),
              if (_selectedCategory != 'Tất cả')
                TextButton(
                  onPressed: () => setState(() => _selectedCategory = 'Tất cả'),
                  child: const Text('Đặt lại'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                'Tất cả',
                'Đơn hàng',
                'Thanh toán',
                'Vận chuyển',
                'Đổi trả',
                'Tài khoản',
              ].map(_buildCategoryChip).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Câu hỏi thường gặp', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          if (filteredFaqs.isEmpty)
            const _NoFaqResult()
          else
            ...filteredFaqs.map((faq) {
              return _FaqTile(
                question: faq['question']!,
                answer: faq['answer']!,
                category: faq['category']!,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedCategory = category);
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        showCheckmark: false,
        labelStyle: AppTextStyles.caption.copyWith(
          color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderStrong,
          ),
        ),
      ),
    );
  }
}

class _PrioritySupportCard extends StatelessWidget {
  const _PrioritySupportCard({required this.onChat});

  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00408F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'ONLINE',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Cần trò chuyện trực tiếp?',
              style: AppTextStyles.title.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bot hỗ trợ dùng dữ liệu sản phẩm từ backend để trả lời nhanh các câu hỏi thường gặp.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textInverse.withValues(alpha: 0.82),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Liên hệ hỗ trợ ngay',
              icon: Icons.chat_bubble_outline,
              variant: AppButtonVariant.secondary,
              onPressed: onChat,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFaqResult extends StatelessWidget {
  const _NoFaqResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.help_outline,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Không tìm thấy giải đáp phù hợp',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.category,
  });

  final String question;
  final String answer;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          collapsedIconColor: AppColors.primary,
          iconColor: AppColors.secondary,
          title: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  question,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            Text(
              answer,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
