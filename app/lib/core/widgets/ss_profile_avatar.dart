import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/local_profile_photo.dart';
import '../theme/ss_layout.dart';

class SsProfileAvatar extends StatelessWidget {
  const SsProfileAvatar({
    super.key,
    this.size = 48,
    this.borderWidth = 0,
    this.borderColor,
    this.fallbackIcon = Icons.storefront_outlined,
    this.onInk = false,
  });

  final double size;
  final double borderWidth;
  final Color? borderColor;
  final IconData fallbackIcon;
  final bool onInk;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!Get.isRegistered<LocalProfilePhoto>()) {
      return _fallback(scheme);
    }
    return Obx(() {
      final photo = Get.find<LocalProfilePhoto>();
      final p = photo.path.value;
      final file = p != null ? File(p) : null;
      final hasFile = file != null && file.existsSync();
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.35),
                  width: borderWidth,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: hasFile
            ? Image.file(
                file,
                key: ValueKey('${p}_${file.lastModifiedSync().millisecondsSinceEpoch}'),
                fit: BoxFit.cover,
                width: size,
                height: size,
              )
            : _fallback(scheme),
      );
    });
  }

  Widget _fallback(ColorScheme scheme) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onInk
            ? Colors.white.withValues(alpha: 0.14)
            : scheme.onSurface.withValues(alpha: 0.08),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.42,
        color: onInk ? SsLayout.onInk : SsLayout.title(scheme),
      ),
    );
  }
}
