import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Material(
      color: colors.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: colors.onErrorContainer),
              const SizedBox(width: 8),
              Text(
                context.l10n.offlineBanner,
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
