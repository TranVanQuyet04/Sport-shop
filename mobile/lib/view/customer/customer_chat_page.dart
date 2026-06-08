import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomerChatPage extends StatelessWidget {
  const CustomerChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Hỗ trợ khách hàng'),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.more_vert))],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [
                _MessageBubble(text: 'Xin chào, Sportshop có thể hỗ trợ gì cho bạn?', fromMe: false),
                _MessageBubble(text: 'Tôi muốn hỏi về đơn #SW99281.', fromMe: true),
                _MessageBubble(text: 'Đơn của bạn đang được giao. Shipper dự kiến đến trong hôm nay.', fromMe: false),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textInverse,
                    child: IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.fromMe});

  final String text;
  final bool fromMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: fromMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: fromMe ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(color: fromMe ? AppColors.textInverse : AppColors.textPrimary),
        ),
      ),
    );
  }
}
