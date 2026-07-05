import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/context_extensions.dart';
import 'product_card.dart';

Widget _box({double? width, double height = 16, double radius = 8}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

Shimmer _shimmer(BuildContext context, {required Widget child}) {
  final colors = context.colorScheme;
  return Shimmer.fromColors(
    baseColor: colors.surfaceContainerHighest,
    highlightColor: colors.surfaceContainerLow,
    child: child,
  );
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({
    super.key,
    this.padding = const EdgeInsets.all(16),
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        gridDelegate: productGridDelegate,
        itemCount: 8,
        itemBuilder: (context, index) => _box(height: 260, radius: 16),
      ),
    );
  }
}

class DetailsShimmer extends StatelessWidget {
  const DetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(aspectRatio: 1.2, child: _box(radius: 20)),
          const SizedBox(height: 24),
          _box(width: 120, height: 24),
          const SizedBox(height: 12),
          _box(height: 28),
          const SizedBox(height: 8),
          _box(width: 220, height: 28),
          const SizedBox(height: 24),
          for (var i = 0; i < 4; i++) ...[_box(), const SizedBox(height: 8)],
        ],
      ),
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _box(width: 180, height: 28),
          const SizedBox(height: 8),
          _box(width: 240),
          const SizedBox(height: 24),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _box(height: 88, radius: 16)),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _box(width: 160, height: 20),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _box(width: 90, height: 32, radius: 16),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _box(width: 140, height: 20),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _box(width: 165, height: 250, radius: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
