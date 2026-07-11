import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/product_detail_model.dart';

class ProductGalleryPage extends StatefulWidget {
  const ProductGalleryPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductGalleryPage> createState() => _ProductGalleryPageState();
}

class _ProductGalleryPageState extends State<ProductGalleryPage> {
  ProductDetailModel? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await AppDependencies.instance.productRepository
          .getProductDetail(widget.productId);
      if (!mounted) {
        return;
      }
      setState(() => _product = product);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final images = product?.imageUrls ?? const <String>[];

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/products/${widget.productId}');
            }
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(product?.name ?? 'Thư viện ảnh'),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading && product == null) {
            return const AppLoadingState(title: 'Đang tải ảnh sản phẩm');
          }
          if (_errorMessage != null && product == null) {
            return AppErrorState(
              title: 'Không tải được ảnh',
              message: _errorMessage!,
              onAction: _loadProduct,
            );
          }
          if (images.isEmpty) {
            return AppEmptyState(
              title: 'Sản phẩm chưa có ảnh',
              message: 'Backend chưa trả ảnh cho sản phẩm này.',
              actionLabel: 'Thử lại',
              onAction: _loadProduct,
            );
          }

          return PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: ColoredBox(
                          color: AppColors.surface,
                          child: Image.network(
                            images[index],
                            width: double.infinity,
                            fit: BoxFit.contain,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textSecondary,
                                size: 72,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      '${index + 1}/${images.length}',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
