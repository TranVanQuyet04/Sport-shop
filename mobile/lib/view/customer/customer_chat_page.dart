import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../model/chat/chat_model.dart';
import '../../model/customer/product_detail_model.dart';
import '../../presenter/chat/chat_presenter.dart' as app_chat;

class CustomerChatPage extends StatefulWidget {
  const CustomerChatPage({super.key});

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  late final app_chat.ChatPresenter _presenter;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  int _lastMessageCount = 0;
  bool _pendingForceScroll = false;

  static const List<_PromptGroup> _promptGroups = [
    _PromptGroup(
      title: 'Mua nhanh',
      prompts: [
        _QuickPrompt(
          label: 'T\u00ecm gi\u00e0y ch\u1ea1y b\u1ed9',
          icon: Icons.directions_run_outlined,
          intent: 'RUNNING_SHOES',
          message:
              'T\u00f4i mu\u1ed1n t\u00ecm gi\u00e0y ch\u1ea1y b\u1ed9. H\u00e3y g\u1ee3i \u00fd s\u1ea3n ph\u1ea9m theo nhu c\u1ea7u t\u1eadp luy\u1ec7n v\u00e0 ng\u00e2n s\u00e1ch.',
        ),
        _QuickPrompt(
          label: 'T\u00ecm \u0111\u1ed3 gym',
          icon: Icons.fitness_center_outlined,
          intent: 'GYM_PRODUCTS',
          message:
              'T\u00f4i mu\u1ed1n t\u00ecm \u0111\u1ed3 gym tho\u1ea3i m\u00e1i, d\u1ec5 v\u1eadn \u0111\u1ed9ng. H\u00e3y g\u1ee3i \u00fd s\u1ea3n ph\u1ea9m ph\u00f9 h\u1ee3p.',
        ),
        _QuickPrompt(
          label: 'S\u1ea3n ph\u1ea9m gi\u1ea3m gi\u00e1',
          icon: Icons.local_offer_outlined,
          intent: 'DISCOUNT_SEARCH',
          message:
              'Hi\u1ec7n c\u00f3 s\u1ea3n ph\u1ea9m th\u1ec3 thao n\u00e0o \u0111ang gi\u1ea3m gi\u00e1 ho\u1eb7c \u0111\u00e1ng mua kh\u00f4ng?',
        ),
      ],
    ),
    _PromptGroup(
      title: 'T\u01b0 v\u1ea5n ch\u1ecdn \u0111\u1ed3',
      prompts: [
        _QuickPrompt(
          label: 'T\u01b0 v\u1ea5n size',
          icon: Icons.straighten_outlined,
          intent: 'SIZE_GUIDE',
          message:
              'T\u00f4i c\u1ea7n t\u01b0 v\u1ea5n size gi\u00e0y ho\u1eb7c qu\u1ea7n \u00e1o th\u1ec3 thao. T\u00f4i n\u00ean cung c\u1ea5p s\u1ed1 \u0111o n\u00e0o?',
        ),
        _QuickPrompt(
          label: 'Theo m\u00f4n th\u1ec3 thao',
          icon: Icons.sports_soccer_outlined,
          intent: 'SPORT_GUIDE',
          message:
              'H\u00e3y g\u1ee3i \u00fd trang ph\u1ee5c ho\u1eb7c gi\u00e0y theo m\u00f4n th\u1ec3 thao t\u00f4i \u0111ang t\u1eadp.',
        ),
        _QuickPrompt(
          label: 'Theo ng\u00e2n s\u00e1ch',
          icon: Icons.payments_outlined,
          intent: 'BUDGET_GUIDE',
          message:
              'T\u00f4i mu\u1ed1n ch\u1ecdn s\u1ea3n ph\u1ea9m theo ng\u00e2n s\u00e1ch. H\u00e3y g\u1ee3i \u00fd v\u00e0i l\u1ef1a ch\u1ecdn t\u1ed1t.',
        ),
      ],
    ),
    _PromptGroup(
      title: 'Sau mua',
      prompts: [
        _QuickPrompt(
          label: 'Tra c\u1ee9u \u0111\u01a1n h\u00e0ng',
          icon: Icons.receipt_long_outlined,
          intent: 'ORDER_LOOKUP',
          message:
              'T\u00f4i mu\u1ed1n tra c\u1ee9u t\u00ecnh tr\u1ea1ng \u0111\u01a1n h\u00e0ng c\u1ee7a m\u00ecnh.',
        ),
        _QuickPrompt(
          label: '\u0110\u1ed5i tr\u1ea3',
          icon: Icons.assignment_return_outlined,
          intent: 'RETURN_POLICY',
          message:
              'T\u00f4i c\u1ea7n h\u1ed7 tr\u1ee3 v\u1ec1 ch\u00ednh s\u00e1ch \u0111\u1ed5i tr\u1ea3 s\u1ea3n ph\u1ea9m.',
        ),
        _QuickPrompt(
          label: 'G\u1eb7p nh\u00e2n vi\u00ean',
          icon: Icons.support_agent_outlined,
          intent: 'HUMAN_HANDOFF',
          message:
              'T\u00f4i mu\u1ed1n g\u1eb7p nh\u00e2n vi\u00ean t\u01b0 v\u1ea5n \u0111\u1ec3 \u0111\u01b0\u1ee3c h\u1ed7 tr\u1ee3 tr\u1ef1c ti\u1ebfp.',
        ),
      ],
    ),
  ];
  @override
  void initState() {
    super.initState();
    _presenter = app_chat.ChatPresenter(
      chatRepository: AppDependencies.instance.chatRepository,
    );
    _presenter.addListener(_onControllerChanged);
    _openSupportRoom();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _presenter.removeListener(_onControllerChanged);
    _presenter.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final nextMessageCount = _presenter.messages.length;
    final hasNewMessage = nextMessageCount > _lastMessageCount;
    final shouldScroll =
        _pendingForceScroll ||
        _lastMessageCount == 0 ||
        (hasNewMessage && _isNearBottom);
    _lastMessageCount = nextMessageCount;
    setState(() {});
    if (shouldScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _pendingForceScroll = false;
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) {
      return true;
    }
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels <= 96;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openSupportRoom() async {
    final email = await AppDependencies.instance.tokenStorage.readEmail();
    if (!mounted) {
      return;
    }
    await _presenter.openCustomerSupportRoom(email ?? 'Kh\u00e1ch h\u00e0ng');
    _refreshTimer?.cancel();
    final roomId = _presenter.activeRoom?.id;
    if (roomId != null && roomId.isNotEmpty) {
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _presenter.loadRoomMessages(roomId, silent: true),
      );
    }
  }

  Future<void> _sendQuickPrompt(_QuickPrompt prompt) {
    return _sendText(prompt.message, intent: prompt.intent);
  }

  Future<void> _sendMessage() {
    return _sendText(_messageController.text);
  }

  Future<void> _confirmClearHistory() async {
    if (_presenter.messages.isEmpty ||
        _presenter.isLoading ||
        _presenter.isSending) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa lịch sử chat?'),
        content: const Text(
          'Toàn bộ tin nhắn sẽ bị xóa và AI sẽ không còn dùng ngữ cảnh cũ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Xóa lịch sử'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _presenter.clearActiveRoomHistory();
    if (mounted && _presenter.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa lịch sử trò chuyện.')),
      );
    }
  }

  Future<void> _sendText(String rawText, {String? intent}) async {
    final text = rawText.trim();
    if (text.isEmpty || _presenter.isSending) {
      return;
    }

    if (_presenter.activeRoom?.id.isNotEmpty != true) {
      await _openSupportRoom();
    }
    final roomId = _presenter.activeRoom?.id;
    if (roomId == null || roomId.isEmpty) {
      return;
    }

    _messageController.clear();
    _pendingForceScroll = true;
    await _presenter.sendRoomMessage(
      roomId: roomId,
      content: text,
      sender: 'CUSTOMER',
      intent: intent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _presenter.isLoading || _presenter.isSending;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/support');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('H\u1ed7 tr\u1ee3 kh\u00e1ch h\u00e0ng'),
        actions: [
          IconButton(
            tooltip: 'Xóa lịch sử chat',
            onPressed: _presenter.messages.isEmpty || isBusy
                ? null
                : _confirmClearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_presenter.errorMessage != null)
            _ChatErrorBanner(message: _presenter.errorMessage!),
          const _ChatStatusHeader(),
          _QuickPromptPanel(
            groups: _promptGroups,
            enabled: !isBusy,
            onSelected: _sendQuickPrompt,
          ),
          Expanded(
            child: _presenter.isLoading && _presenter.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _presenter.messages.isEmpty
                ? const _ChatEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _presenter.messages.length,
                    itemBuilder: (context, index) {
                      final message = _presenter.messages[index];
                      return _MessageBubble(
                        message: message,
                        fromMe: message.fromMe,
                        onViewProduct: _viewProduct,
                        onAddToCart: (variantId) => _addToCart(variantId),
                        onBuyNow: (variantId) =>
                            _addToCart(variantId, goToCheckout: true),
                        onOpenRoute: (route) => context.go(route),
                      );
                    },
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
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nh\u1eadp tin nh\u1eafn...',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textInverse,
                    child: IconButton(
                      tooltip: 'G\u1eedi',
                      onPressed: isBusy ? null : _sendMessage,
                      icon: _presenter.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewProduct(String productId) {
    context.go('/customer/products/$productId');
  }

  Future<void> _addToCart(String variantId, {bool goToCheckout = false}) async {
    if (variantId.isEmpty) {
      return;
    }

    try {
      await AppDependencies.instance.cartRepository.addToCart(
        variantId: variantId,
        quantity: 1,
      );
      if (!mounted) {
        return;
      }
      context.go(goToCheckout ? AppRoutes.checkout : AppRoutes.cart);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add to cart failed: $error')));
    }
  }
}

class _PromptGroup {
  const _PromptGroup({required this.title, required this.prompts});

  final String title;
  final List<_QuickPrompt> prompts;
}

class _QuickPrompt {
  const _QuickPrompt({
    required this.label,
    required this.icon,
    required this.intent,
    required this.message,
  });

  final String label;
  final IconData icon;
  final String intent;
  final String message;
}

class _QuickPromptPanel extends StatelessWidget {
  const _QuickPromptPanel({
    required this.groups,
    required this.enabled,
    required this.onSelected,
  });

  final List<_PromptGroup> groups;
  final bool enabled;
  final ValueChanged<_QuickPrompt> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'B\u1ea1n mu\u1ed1n StrideX h\u1ed7 tr\u1ee3 g\u00ec?',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final group in groups) ...[
            Text(
              group.title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final prompt in group.prompts) ...[
                    _PromptChip(
                      prompt: prompt,
                      enabled: enabled,
                      onSelected: onSelected,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            if (group != groups.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.prompt,
    required this.enabled,
    required this.onSelected,
  });

  final _QuickPrompt prompt;
  final bool enabled;
  final ValueChanged<_QuickPrompt> onSelected;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(prompt.icon, size: 16),
      label: Text(prompt.label),
      onPressed: enabled ? () => onSelected(prompt) : null,
      backgroundColor: AppColors.secondarySoft,
      side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.22)),
      labelStyle: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.support_agent_outlined,
              color: AppColors.secondary,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ch\u1ecdn nhanh ho\u1eb7c nh\u1eadp c\u00e2u h\u1ecfi',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'StrideX c\u00f3 th\u1ec3 h\u1ed7 tr\u1ee3 t\u00ecm s\u1ea3n ph\u1ea9m, t\u01b0 v\u1ea5n size, theo d\u00f5i \u0111\u01a1n h\u00e0ng v\u00e0 \u0111\u1ed5i tr\u1ea3.',
              textAlign: TextAlign.center,
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

class _ChatErrorBanner extends StatelessWidget {
  const _ChatErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _ChatStatusHeader extends StatelessWidget {
  const _ChatStatusHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            child: Icon(Icons.support_agent_outlined),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('StrideX Support', style: AppTextStyles.subtitle),
                Text(
                  'Bot h\u1ed7 tr\u1ee3 t\u1ee9c th\u00ec, admin ph\u1ea3n h\u1ed3i khi c\u1ea7n',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.fromMe,
    required this.onViewProduct,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onOpenRoute,
  });

  final ChatMessageModel message;
  final bool fromMe;
  final ValueChanged<String> onViewProduct;
  final ValueChanged<String> onAddToCart;
  final ValueChanged<String> onBuyNow;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final actions = _ChatActions.fromContent(message.content);
    final visibleContent = actions.summaryContent;
    final bubbleBorderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: fromMe ? const Radius.circular(16) : const Radius.circular(2),
      bottomRight: fromMe
          ? const Radius.circular(2)
          : const Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: fromMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!fromMe) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              child: Icon(Icons.support_agent, size: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 276),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: fromMe ? AppColors.primary : AppColors.surface,
                borderRadius: bubbleBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: fromMe ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (visibleContent.isNotEmpty)
                    Text(
                      visibleContent,
                      style: AppTextStyles.body.copyWith(
                        color: fromMe
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  if (!fromMe && actions.hasAny) ...[
                    if (visibleContent.isNotEmpty)
                      const SizedBox(height: AppSpacing.md),
                    _MessageActionButtons(
                      actions: actions,
                      onViewProduct: onViewProduct,
                      onAddToCart: onAddToCart,
                      onBuyNow: onBuyNow,
                      onOpenRoute: onOpenRoute,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      fromMe ? '\u0110\u00e3 g\u1eedi' : 'H\u1ed7 tr\u1ee3',
                      style: AppTextStyles.caption.copyWith(
                        color: fromMe
                            ? AppColors.textInverse.withValues(alpha: 0.6)
                            : AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (fromMe) ...[
            const SizedBox(width: AppSpacing.sm),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textInverse,
              child: Icon(Icons.person, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageActionButtons extends StatelessWidget {
  const _MessageActionButtons({
    required this.actions,
    required this.onViewProduct,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onOpenRoute,
  });

  final _ChatActions actions;
  final ValueChanged<String> onViewProduct;
  final ValueChanged<String> onAddToCart;
  final ValueChanged<String> onBuyNow;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < actions.products.length; index++) ...[
          _ChatProductCard(
            action: actions.products[index],
            onViewProduct: onViewProduct,
            onAddToCart: onAddToCart,
            onBuyNow: onBuyNow,
          ),
          if (index < actions.products.length - 1 ||
              actions.services.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
        ],
        for (var index = 0; index < actions.services.length; index++) ...[
          _ChatActionButton(
            label: actions.services[index].label,
            icon: Icons.receipt_long_outlined,
            filled: true,
            onPressed: () => onOpenRoute(actions.services[index].route),
          ),
          if (index < actions.services.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ChatProductCard extends StatelessWidget {
  const _ChatProductCard({
    required this.action,
    required this.onViewProduct,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final _ChatProductAction action;
  final ValueChanged<String> onViewProduct;
  final ValueChanged<String> onAddToCart;
  final ValueChanged<String> onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (action.price != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        action.price!,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (action.stock != null)
                _ProductMetaChip(
                  icon: Icons.inventory_2_outlined,
                  label: action.stock!,
                ),
              if (action.size != null)
                _ProductMetaChip(
                  icon: Icons.straighten_outlined,
                  label: 'Size ${action.size}',
                ),
              if (action.color != null)
                _ProductMetaChip(
                  icon: Icons.palette_outlined,
                  label: action.color!,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (action.productId.isNotEmpty)
                _ChatActionButton(
                  label: 'Xem',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => onViewProduct(action.productId),
                ),
              _ResolvedOrderActions(
                action: action,
                onAddToCart: onAddToCart,
                onBuyNow: onBuyNow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductMetaChip extends StatelessWidget {
  const _ProductMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedOrderActions extends StatefulWidget {
  const _ResolvedOrderActions({
    required this.action,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final _ChatProductAction action;
  final ValueChanged<String> onAddToCart;
  final ValueChanged<String> onBuyNow;

  @override
  State<_ResolvedOrderActions> createState() => _ResolvedOrderActionsState();
}

class _ResolvedOrderActionsState extends State<_ResolvedOrderActions> {
  Future<String?>? _variantFuture;

  @override
  void initState() {
    super.initState();
    _variantFuture = _resolveVariantId();
  }

  @override
  void didUpdateWidget(covariant _ResolvedOrderActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action.productId != widget.action.productId ||
        oldWidget.action.addToCartVariantId !=
            widget.action.addToCartVariantId ||
        oldWidget.action.buyNowVariantId != widget.action.buyNowVariantId) {
      _variantFuture = _resolveVariantId();
    }
  }

  Future<String?> _resolveVariantId() async {
    final directVariantId =
        widget.action.addToCartVariantId ?? widget.action.buyNowVariantId;
    if (directVariantId != null && directVariantId.isNotEmpty) {
      return directVariantId;
    }
    if (widget.action.productId.isEmpty) {
      return null;
    }

    try {
      final product = await AppDependencies.instance.productRepository
          .getProductDetail(widget.action.productId);
      return _firstAvailableVariant(product)?.id;
    } catch (_) {
      return null;
    }
  }

  ProductVariantModel? _firstAvailableVariant(ProductDetailModel product) {
    for (final variant in product.variants) {
      if (variant.id.isNotEmpty && variant.stockQuantity > 0) {
        return variant;
      }
    }
    for (final variant in product.variants) {
      if (variant.id.isNotEmpty) {
        return variant;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _variantFuture,
      builder: (context, snapshot) {
        final variantId = snapshot.data;
        if (variantId == null || variantId.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ChatActionButton(
              label: 'Th\u00eam gi\u1ecf',
              icon: Icons.add_shopping_cart_rounded,
              onPressed: () => widget.onAddToCart(variantId),
            ),
            _ChatActionButton(
              label: 'Mua ngay',
              icon: Icons.flash_on_rounded,
              filled: true,
              onPressed: () => widget.onBuyNow(variantId),
            ),
          ],
        );
      },
    );
  }
}

class _ChatActionButton extends StatelessWidget {
  const _ChatActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.textInverse : AppColors.secondary;
    return SizedBox(
      height: 34,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: filled ? AppColors.secondary : AppColors.surface,
          side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.28)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          textStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ChatActions {
  const _ChatActions({
    required this.summaryContent,
    required this.products,
    required this.services,
  });

  static final RegExp _markerPattern = RegExp(
    r'\[\[ACTION:([A-Z_]+):([^\]]+)\]\]',
  );
  static final RegExp _productRoutePattern = RegExp(
    r'#\/customer\/products\/(\d+)|\/customer\/products\/(\d+)',
  );

  final String summaryContent;
  final List<_ChatProductAction> products;
  final List<_ChatServiceAction> services;

  bool get hasAny => products.isNotEmpty || services.isNotEmpty;

  factory _ChatActions.fromContent(String content) {
    final markerFreeContent = content.replaceAll(_markerPattern, '').trim();
    final actionsByProductId = <String, _MutableChatProductAction>{};
    final looseVariantActions = <String, String>{};
    final serviceActionsByRoute = <String, _ChatServiceAction>{};

    for (final match in _markerPattern.allMatches(content)) {
      final type = match.group(1);
      final payload = match.group(2) ?? '';
      final values = _readPayload(payload);
      if (type == 'OPEN_ORDERS') {
        final route = values['route']?.trim();
        if (route == AppRoutes.orders) {
          final label = values['label']?.trim();
          serviceActionsByRoute.putIfAbsent(
            route!,
            () => _ChatServiceAction(
              route: route,
              label: label == null || label.isEmpty
                  ? 'Xem \u0111\u01a1n h\u00e0ng c\u1ee7a t\u00f4i'
                  : label,
            ),
          );
        }
        continue;
      }
      final variantId = values['variantId'];
      final productId = values['productId'];

      if (productId == null || productId.isEmpty) {
        if (variantId != null && variantId.isNotEmpty) {
          looseVariantActions[type ?? ''] = variantId;
        }
        continue;
      }

      final action = actionsByProductId.putIfAbsent(
        productId,
        () => _MutableChatProductAction(productId: productId),
      );
      action.label ??= values['label'];
      switch (type) {
        case 'VIEW_PRODUCT':
          break;
        case 'ADD_TO_CART':
          action.addToCartVariantId = variantId;
          break;
        case 'BUY_NOW':
          action.buyNowVariantId = variantId;
          break;
      }
    }

    final productBlocks = _extractProductBlocks(markerFreeContent);
    for (final block in productBlocks) {
      final action = actionsByProductId.putIfAbsent(
        block.productId,
        () => _MutableChatProductAction(productId: block.productId),
      );
      action.label ??= block.name;
      action.price ??= block.price;
      action.stock ??= block.stock;
      action.size ??= block.size;
      action.color ??= block.color;
    }

    for (final match in _productRoutePattern.allMatches(markerFreeContent)) {
      final productId = match.group(1) ?? match.group(2);
      if (productId == null || productId.isEmpty) {
        continue;
      }
      actionsByProductId.putIfAbsent(
        productId,
        () => _MutableChatProductAction(productId: productId),
      );
    }

    if (actionsByProductId.length == 1 && looseVariantActions.isNotEmpty) {
      final onlyAction = actionsByProductId.values.first;
      onlyAction.addToCartVariantId ??= looseVariantActions['ADD_TO_CART'];
      onlyAction.buyNowVariantId ??= looseVariantActions['BUY_NOW'];
    }

    if (actionsByProductId.isEmpty && looseVariantActions.isNotEmpty) {
      actionsByProductId['quick-order'] =
          _MutableChatProductAction(productId: '', label: 'Thao t\u00e1c nhanh')
            ..addToCartVariantId = looseVariantActions['ADD_TO_CART']
            ..buyNowVariantId = looseVariantActions['BUY_NOW'];
    }

    final summary = _buildSummary(markerFreeContent, productBlocks);
    return _ChatActions(
      summaryContent: summary,
      products: actionsByProductId.values
          .map((action) => action.freeze())
          .toList(),
      services: serviceActionsByRoute.values.toList(),
    );
  }

  static List<_ParsedProductBlock> _extractProductBlocks(String content) {
    final matches = _productRoutePattern.allMatches(content).toList();
    final blocks = <_ParsedProductBlock>[];
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final productId = match.group(1) ?? match.group(2) ?? '';
      if (productId.isEmpty) {
        continue;
      }
      final start = _findProductBlockStart(content, match.start);
      final end = i + 1 < matches.length
          ? _findProductBlockStart(content, matches[i + 1].start)
          : _findProductBlockEnd(content, match.end);
      final blockText = content.substring(start, end).trim();
      blocks.add(_ParsedProductBlock.fromText(productId, blockText));
    }
    return blocks;
  }

  static int _findProductBlockStart(String content, int beforeIndex) {
    final prefix = content.substring(0, beforeIndex);
    final numbered = RegExp(r'\n\s*\d+\.\s*').allMatches(prefix).toList();
    if (numbered.isNotEmpty) {
      return numbered.last.start;
    }
    final doubleBreak = prefix.lastIndexOf('\n\n');
    return doubleBreak >= 0 ? doubleBreak + 2 : 0;
  }

  static int _findProductBlockEnd(String content, int afterIndex) {
    final suffix = content.substring(afterIndex);
    final nextBreak = suffix.indexOf('\n\n');
    if (nextBreak >= 0) {
      return afterIndex + nextBreak;
    }
    return content.length;
  }

  static String _buildSummary(
    String content,
    List<_ParsedProductBlock> productBlocks,
  ) {
    var source = content;
    for (final block in productBlocks) {
      source = source.replaceFirst(block.rawText, '').trim();
    }

    var cleaned = source
        .replaceAll(RegExp(r'\[\[ACTION:[^\]]+\]\]'), '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'\[([^\]]+)\]\s*\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[-*]\s*', multiLine: true), '')
        .replaceAll(RegExp(r'https?:\/\/[^\s\)]+'), '')
        .replaceAll(RegExp(r'^\s*\([^\)]*\)\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    cleaned = cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) {
          if (line.isEmpty) return true;
          final lower = line.toLowerCase();
          return !lower.startsWith('sku:') &&
              !lower.startsWith('- sku:') &&
              !lower.contains('gia tham khao:') &&
              !lower.contains('gia:') &&
              !lower.contains('ton kho:') &&
              !lower.contains('tinh trang:') &&
              !lower.contains('chi tiet:') &&
              !lower.contains('link chi') &&
              !lower.contains('xem tai day') &&
              !lower.contains('xem t');
        })
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    return cleaned;
  }

  static Map<String, String> _readPayload(String payload) {
    final values = <String, String>{};
    final parts = payload.contains(';') ? payload.split(';') : [payload];
    for (final part in parts) {
      final separator = part.indexOf('=');
      if (separator <= 0) {
        continue;
      }
      final key = part.substring(0, separator).trim();
      final value = part.substring(separator + 1).trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        values[key] = value;
      }
    }
    return values;
  }
}

class _ChatServiceAction {
  const _ChatServiceAction({required this.route, required this.label});

  final String route;
  final String label;
}

class _ParsedProductBlock {
  const _ParsedProductBlock({
    required this.productId,
    required this.rawText,
    this.name,
    this.price,
    this.stock,
    this.size,
    this.color,
  });

  final String productId;
  final String rawText;
  final String? name;
  final String? price;
  final String? stock;
  final String? size;
  final String? color;

  factory _ParsedProductBlock.fromText(String productId, String text) {
    final normalized = text
        .replaceAll('**', '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[-*]\s*', multiLine: true), '')
        .trim();

    final nameMatch = RegExp(
      r'\d+\.\s*([^\n(]+)|Ten san pham:\s*([^\n]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    final priceMatch = RegExp(
      r'(?:Gia(?: tham khao)?):\s*([^\n]+)|((?:\d{1,3}[\.]?)+\s*(?:VND|VN\.?)?)',
      caseSensitive: false,
    ).firstMatch(normalized);
    final stockMatch = RegExp(
      r'(?:Ton kho|Tinh trang):\s*([^\n]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    final skuMatch = RegExp(
      r'SKU:\s*([^\n]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    final skuLine = skuMatch?.group(1) ?? '';
    final sizeMatch = RegExp(
      r'Size:\s*([^|\n]+)',
      caseSensitive: false,
    ).firstMatch(skuLine);
    final colorMatch = RegExp(
      r'Mau:\s*([^|\n]+)',
      caseSensitive: false,
    ).firstMatch(skuLine);

    return _ParsedProductBlock(
      productId: productId,
      rawText: text,
      name: _cleanText(nameMatch?.group(1) ?? nameMatch?.group(2)),
      price: _cleanText(priceMatch?.group(1) ?? priceMatch?.group(2)),
      stock: _cleanText(stockMatch?.group(1)),
      size: _cleanText(sizeMatch?.group(1)),
      color: _cleanText(colorMatch?.group(1)),
    );
  }

  static String? _cleanText(String? value) {
    final cleaned = value
        ?.replaceAll('*', '')
        .replaceAll('-', '')
        .replaceAll('VND', 'd')
        .trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }
}

class _ChatProductAction {
  const _ChatProductAction({
    required this.productId,
    this.label,
    this.price,
    this.stock,
    this.size,
    this.color,
    this.addToCartVariantId,
    this.buyNowVariantId,
  });

  final String productId;
  final String? label;
  final String? price;
  final String? stock;
  final String? size;
  final String? color;
  final String? addToCartVariantId;
  final String? buyNowVariantId;

  String get displayName {
    final value = label?.replaceAll('*', '').trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return productId.isEmpty
        ? 'S\u1ea3n ph\u1ea9m ph\u00f9 h\u1ee3p'
        : 'S\u1ea3n ph\u1ea9m #$productId';
  }
}

class _MutableChatProductAction {
  _MutableChatProductAction({required this.productId, this.label});

  final String productId;
  String? label;
  String? price;
  String? stock;
  String? size;
  String? color;
  String? addToCartVariantId;
  String? buyNowVariantId;

  _ChatProductAction freeze() {
    return _ChatProductAction(
      productId: productId,
      label: label,
      price: price,
      stock: stock,
      size: size,
      color: color,
      addToCartVariantId: addToCartVariantId,
      buyNowVariantId: buyNowVariantId,
    );
  }
}
