import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'sportshop_router.dart';

class StrideXApp extends StatelessWidget {
  const StrideXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StrideX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const CupertinoScrollBehavior(),
      routerConfig: stridexRouter,
    );
  }
}
