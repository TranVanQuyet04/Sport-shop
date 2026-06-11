  import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'sportshop_router.dart';

class SportshopApp extends StatelessWidget {
  const SportshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sportshop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: sportshopRouter,
    );
  }
}
