import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/ss_layout.dart';

class SsScaffoldWash extends StatelessWidget {
  const SsScaffoldWash({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.gradients.scaffoldWash),
      child: child,
    );
  }
}

class SsEmpty extends StatelessWidget {
  const SsEmpty({super.key, this.message, this.action});
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.onSurface.withValues(alpha: 0.06),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                Icons.inbox_outlined,
                color: scheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? l.empty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class SsLoading extends StatelessWidget {
  const SsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 12),
          Text(l.loading),
        ],
      ),
    );
  }
}

class SsError extends StatelessWidget {
  const SsError({super.key, required this.onRetry, this.message});
  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message ?? l.errorGeneric, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}

class SsStatTile extends StatelessWidget {
  const SsStatTile({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.icon,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradients = context.gradients;
    final fg = emphasized ? SsLayout.onInk : SsLayout.title(scheme);
    final muted = emphasized ? SsLayout.onInkBody : SsLayout.body(scheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: emphasized ? gradients.accentCard : gradients.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: emphasized ? 0.0 : 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SsLayout.pageH,
              SsLayout.section,
              SsLayout.pageH,
              SsLayout.item,
            ),
            // Spacer/Expanded only when height is bounded (e.g. grid).
            // ListView gives infinite height — use shrink-wrap spacing there.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final expand = constraints.hasBoundedHeight;
                return Column(
                  mainAxisSize:
                      expand ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null)
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: fg.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, size: 18, color: muted),
                          ),
                          const Spacer(),
                          if (onTap != null)
                            Icon(
                              Icons.north_east,
                              size: 14,
                              color: muted,
                            ),
                        ],
                      ),
                    if (expand)
                      const Spacer()
                    else
                      const SizedBox(height: 12),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: fg,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SsSectionTitle extends StatelessWidget {
  const SsSectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, SsLayout.section, 0, SsLayout.tight),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primary,
                  scheme.tertiary.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: SsLayout.titleStyle(context)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SsGlassCard extends StatelessWidget {
  const SsGlassCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: context.gradients.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(4),
      child: child,
    );
  }
}
