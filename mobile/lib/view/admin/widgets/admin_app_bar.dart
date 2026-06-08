import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({super.key, this.largeLogo = false});

  final bool largeLogo;

  @override
  Size get preferredSize => Size.fromHeight(largeLogo ? 88 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      title: Text(
        largeLogo ? 'APEX\nVELOCITY' : 'APEX VELOCITY',
        style: AppTextStyles.display.copyWith(
          fontSize: largeLogo ? 36 : 20,
          height: 0.95,
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        if (!largeLogo)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          ),
      ],
    );
  }
}
