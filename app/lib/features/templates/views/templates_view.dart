import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/templates_controller.dart';

class TemplatesView extends StatelessWidget {
  const TemplatesView({super.key});

  Future<void> _showAddDialog(
    BuildContext context,
    TemplatesController c,
  ) async {
    final l = AppLocalizations.of(context)!;
    c.prepareAddDialog();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.addTemplate),
          content: Form(
            key: c.addFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: c.addName,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.templateName),
                  onChanged: c.onAddNameChanged,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: c.addCode,
                  decoration: InputDecoration(labelText: l.templateCode),
                  onChanged: (_) => c.markCodeEdited(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  l.templateFieldsHint,
                  style: SsLayout.captionStyle(ctx),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (c.addFormKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
              child: Text(l.save),
            ),
          ],
        );
      },
    );

    if (ok != true || !context.mounted) {
      c.disposeAddDialog();
      return;
    }

    final name = c.addName?.text.trim() ?? '';
    final rawCode = c.addCode?.text.trim() ?? '';
    final code = c.slugCode(rawCode.isEmpty ? name : rawCode);
    c.disposeAddDialog();
    await c.create(name: name, code: code, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TemplatesController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return SsPage(
      title: l.garmentTemplates,
      actions: [
        IconButton(
          tooltip: l.addTemplate,
          onPressed: () => _showAddDialog(context, c),
          icon: const Icon(Icons.add),
        ),
      ],
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.load, message: c.error.value);
        }
        if (c.items.isEmpty) {
          return SsEmpty(
            message: l.empty,
            action: FilledButton.icon(
              onPressed: () => _showAddDialog(context, c),
              icon: const Icon(Icons.add),
              label: Text(l.addTemplate),
            ),
          );
        }
        return ListView.separated(
          padding: SsLayout.listPadding,
          itemCount: c.items.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          itemBuilder: (_, i) {
            final t = c.items[i] as Map;
            final fields = t['fields'];
            final count = fields is List ? fields.length : 0;
            return SsListTile(
              leading: const SsPrimaryIconBox(
                Icons.checkroom_outlined,
              ),
              title: '${t['name']}',
              subtitle: '${t['code']} · $count fields',
              trailing: t['isActive'] == false
                  ? Text(
                      l.archived,
                      style: TextStyle(
                        color: SsLayout.muted(scheme),
                      ),
                    )
                  : null,
            );
          },
        );
      }),
    );
  }
}
