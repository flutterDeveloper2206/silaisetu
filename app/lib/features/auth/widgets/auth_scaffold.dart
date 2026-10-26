import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/brand.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_widgets.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.showBack = false,
  });

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SsScaffoldWash(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              if (showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: SsLayout.title(scheme)),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: SsLayout.formPadding,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: child,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: SsLayout.section),
                child: Text(
                  Brand.name,
                  style: GoogleFonts.fraunces(
                    fontSize: 12,
                    color: SsLayout.muted(scheme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.subtitle});
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.onSurface,
            borderRadius: BorderRadius.circular(SsLayout.radiusSm),
          ),
          child: Text(
            'S',
            style: GoogleFonts.fraunces(
              color: scheme.surface,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          Brand.name,
          style: GoogleFonts.fraunces(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: SsLayout.title(scheme),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: SsLayout.tight),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SsLayout.body(scheme),
                ),
          ),
        ],
      ],
    );
  }
}
