import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StyleThumbnailImage extends StatelessWidget {
  const StyleThumbnailImage({
    super.key,
    required this.source,
    required this.fallbackIcon,
  });

  final String source;
  final IconData fallbackIcon;

  Widget _fallback() {
    return ColoredBox(
      color: AppTheme.surfaceSecondary,
      child: Icon(
        fallbackIcon,
        color: AppTheme.textMuted,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _fallback();

    if (source.startsWith('asset/')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ColoredBox(
        color: AppTheme.surfaceSecondary,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.accentPurple,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }
}
