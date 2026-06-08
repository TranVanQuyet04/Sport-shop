import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminChatDetailPage extends StatelessWidget {
  const AdminChatDetailPage({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Row(children: [CircleAvatar(child: Icon(Icons.person)), SizedBox(width: AppSpacing.md), Expanded(child: Text('Hoàng Anh\nĐang hoạt động'))]),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.call_outlined)), IconButton(onPressed: null, icon: Icon(Icons.videocam_outlined))],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: const [
              _Bubble(text: 'Chào bạn! Shop có thể hỗ trợ gì về đơn hàng hay tư vấn size không ạ?', fromMe: false),
              _Bubble(text: 'Khách hỏi về mẫu áo khoác Pro-Performance. Cao 1m75 nặng 70kg thì size nào vừa?', fromMe: true),
              _ProductImage(),
              _Bubble(text: 'Đây là bảng size chi tiết cho dòng này, bạn tham khảo nhé!', fromMe: true),
              _ProductPreview(),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(children: [
              const Icon(Icons.add_circle_outline),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: TextField(decoration: InputDecoration(hintText: 'Nhập tin nhắn...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(999))))),
              const SizedBox(width: AppSpacing.md),
              CircleAvatar(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, child: IconButton(onPressed: () {}, icon: const Icon(Icons.send))),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromMe});
  final String text;
  final bool fromMe;
  @override
  Widget build(BuildContext context) => Align(
        alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: fromMe ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Text(text, style: AppTextStyles.body.copyWith(color: fromMe ? Colors.white : AppColors.primary, fontSize: 17)),
        ),
      );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage();
  @override
  Widget build(BuildContext context) => Container(height: 300, margin: const EdgeInsets.only(bottom: AppSpacing.lg), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.xl)), child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 130));
}

class _ProductPreview extends StatelessWidget {
  const _ProductPreview();
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)),
          child: Row(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Icon(Icons.directions_run, color: AppColors.success)), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ProRun X1 Ultra Speed', style: AppTextStyles.subtitle), Text('2.450.000đ', style: AppTextStyles.title.copyWith(color: AppColors.secondary))])), const Icon(Icons.chevron_right)]),
        ),
      );
}
