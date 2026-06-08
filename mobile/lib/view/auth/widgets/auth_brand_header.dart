import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_text_styles.dart';

class AuthBrandHeader extends StatelessWidget implements PreferredSizeWidget {
  const AuthBrandHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          }
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        'APEX VELOCITY',
        style: AppTextStyles.display.copyWith(
          fontSize: 28,
          fontStyle: FontStyle.italic,
        ),
      ),
      centerTitle: true,
      actions: [if (trailing != null) trailing!],
    );
  }
}
