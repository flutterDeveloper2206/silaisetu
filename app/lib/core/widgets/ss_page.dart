import 'package:flutter/material.dart';
import '../theme/ss_layout.dart';
import 'ss_widgets.dart';

/// Standard app page: wash background, consistent app bar, padded body.
class SsPage extends StatelessWidget {
  const SsPage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    this.padding,
    this.leading,
    this.centerTitle = false,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottom;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SsScaffoldWash(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: centerTitle,
          leading: leading,
          title: Text(
            title,
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                  color: SsLayout.title(scheme),
                ),
          ),
          actions: actions,
          bottom: bottom == null
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SsLayout.pageH,
                      0,
                      SsLayout.pageH,
                      SsLayout.tight,
                    ),
                    child: bottom!,
                  ),
                ),
        ),
        floatingActionButton: floatingActionButton,
        body: padding == null
            ? body
            : Padding(padding: padding!, child: body),
      ),
    );
  }
}

/// Consistent search field used across list screens.
class SsSearchField extends StatelessWidget {
  const SsSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
    this.onRefresh,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      style: TextStyle(color: SsLayout.title(scheme)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: SsLayout.muted(scheme)),
        prefixIcon: Icon(Icons.search, color: SsLayout.body(scheme)),
        suffixIcon: onRefresh == null
            ? null
            : IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh, color: SsLayout.body(scheme)),
              ),
      ),
    );
  }
}

/// Standard list row with readable title/subtitle contrast.
class SsListTile extends StatelessWidget {
  const SsListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: SsLayout.tilePadding,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: SsLayout.title(scheme),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(color: SsLayout.body(scheme)),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class SsPrimaryIconBox extends StatelessWidget {
  const SsPrimaryIconBox(this.icon, {super.key});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(SsLayout.radiusSm),
      ),
      child: Icon(icon, size: 20, color: SsLayout.body(scheme)),
    );
  }
}

/// Bottom sheet / form action bar spacing helper.
class SsFormActions extends StatelessWidget {
  const SsFormActions({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SsLayout.section),
      child: child,
    );
  }
}

extension SsContrast on BuildContext {
  Color get titleColor => SsLayout.title(Theme.of(this).colorScheme);
  Color get bodyColor => SsLayout.body(Theme.of(this).colorScheme);
  Color get mutedColor => SsLayout.muted(Theme.of(this).colorScheme);
}
