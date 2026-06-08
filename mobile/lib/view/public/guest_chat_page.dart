import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class GuestChatPage extends StatelessWidget {
  const GuestChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chat hỗ trợ'),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.support_agent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sportshop Support', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bạn chưa đăng nhập. Hãy để lại email hoặc số điện thoại nếu cần kiểm tra đơn hàng.',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [
                _GuestMessageBubble(
                  text: 'Xin chào, Sportshop có thể hỗ trợ gì cho bạn?',
                  fromMe: false,
                ),
                _GuestMessageBubble(
                  text: 'Tôi muốn hỏi về size giày Nike Air Max.',
                  fromMe: true,
                ),
                _GuestMessageBubble(
                  text: 'Bạn cho mình biết chiều dài bàn chân hoặc size thường mang nhé. Tư vấn viên sẽ hỗ trợ chọn size phù hợp.',
                  fromMe: false,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.add)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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

class _GuestMessageBubble extends StatelessWidget {
  const _GuestMessageBubble({required this.text, required this.fromMe});

  final String text;
  final bool fromMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 292),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: fromMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: fromMe ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: fromMe ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
