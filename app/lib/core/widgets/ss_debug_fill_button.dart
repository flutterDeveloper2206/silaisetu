import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/ss_layout.dart';

/// Dev-only autofill for forms. Hidden in release builds.
class SsDebugFillButton extends StatelessWidget {
  const SsDebugFillButton({
    super.key,
    required this.onPressed,
    this.label = 'Debug fill',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: SsLayout.item),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.tertiary,
          side: BorderSide(color: scheme.tertiary.withValues(alpha: 0.45)),
          minimumSize: const Size(64, 40),
        ),
        icon: const Icon(Icons.bolt_outlined, size: 18),
        label: Text(label),
      ),
    );
  }
}
