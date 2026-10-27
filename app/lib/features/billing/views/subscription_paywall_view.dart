import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/utils/ss_feedback.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionPaywallView extends StatelessWidget {
  const SubscriptionPaywallView({super.key});

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty || iso == 'null') return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat.yMMMd().format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final existed =
        Get.isRegistered<SubscriptionController>(tag: 'paywall');
    final c = Get.put(SubscriptionController(), tag: 'paywall');
    if (existed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        c.refreshStatus();
      });
    }

    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.subscriptionTitle),
        automaticallyImplyLeading: canPop,
        actions: [
          if (!canPop)
            TextButton(
              onPressed: () => Get.find<AuthController>().logout(),
              child: Text(l.logout),
            ),
        ],
      ),
      body: Obx(() {
        if (c.loading.value && c.status.value == null) {
          return const SsLoading();
        }
        if (c.error.value.isNotEmpty && c.status.value == null) {
          return SsError(
            message: c.error.value,
            onRetry: c.refreshStatus,
          );
        }

        final gated = c.required || c.pending || c.showPayForm.value;
        final cfg = c.config ?? {};
        final amount = cfg['amountInr'] ?? '—';
        final paidDays = cfg['paidDays'] ?? 365;
        final upi = '${cfg['upiId'] ?? ''}';
        final qr = ApiConfig.mediaUrl('${cfg['qrImageUrl'] ?? ''}');
        final instructions = '${cfg['instructions'] ?? ''}';

        return ListView(
          padding: SsLayout.formPadding,
          children: [
            if (!c.required) ...[
              SsGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          c.lifetimeFree
                              ? Icons.verified
                              : Icons.check_circle_outline,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.lifetimeFree
                                ? l.subscriptionLifetimeFreeStatus
                                : (!c.enabled
                                    ? l.subscriptionNotEnforced
                                    : l.subscriptionActive),
                            style: SsLayout.titleStyle(context),
                          ),
                        ),
                      ],
                    ),
                    if (c.trialEndsAt != null &&
                        c.trialEndsAt!.isNotEmpty &&
                        c.trialEndsAt != 'null') ...[
                      const SizedBox(height: 8),
                      Text(
                        l.subscriptionTrialUntil(_fmtDate(c.trialEndsAt)),
                        style: SsLayout.bodyStyle(context),
                      ),
                    ],
                    if (c.subscriptionExpiresAt != null &&
                        c.subscriptionExpiresAt!.isNotEmpty &&
                        c.subscriptionExpiresAt != 'null') ...[
                      const SizedBox(height: 8),
                      Text(
                        l.subscriptionExpiresOn(
                            _fmtDate(c.subscriptionExpiresAt)),
                        style: SsLayout.bodyStyle(context),
                      ),
                    ],
                  ],
                ),
              ),
              if (!c.lifetimeFree && c.enabled && !c.pending) ...[
                const SizedBox(height: SsLayout.item),
                OutlinedButton.icon(
                  onPressed: () {
                    if (c.showPayForm.value) {
                      c.closePayForm();
                    } else {
                      c.openPayForm();
                    }
                  },
                  icon: Icon(
                    c.showPayForm.value
                        ? Icons.expand_less
                        : Icons.payments_outlined,
                  ),
                  label: Text(
                    c.showPayForm.value ? l.cancel : l.subscriptionRenew,
                  ),
                ),
              ],
              const SizedBox(height: SsLayout.section),
            ],
            if (gated) ...[
              Text(
                l.subscriptionHeadline,
                style: SsLayout.titleStyle(context).copyWith(fontSize: 22),
              ),
              const SizedBox(height: SsLayout.tight),
              Text(
                l.subscriptionBody(amount.toString(), paidDays.toString()),
                style: SsLayout.bodyStyle(context),
              ),
              if (instructions.isNotEmpty) ...[
                const SizedBox(height: SsLayout.section),
                SsGlassCard(
                  padding: const EdgeInsets.all(16),
                  child:
                      Text(instructions, style: SsLayout.bodyStyle(context)),
                ),
              ],
              if (qr.isNotEmpty) ...[
                const SizedBox(height: SsLayout.section),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      qr,
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        l.subscriptionQrMissing,
                        style: SsLayout.captionStyle(context),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: SsLayout.section),
                Text(
                  l.subscriptionQrMissing,
                  style: SsLayout.captionStyle(context),
                ),
              ],
              if (upi.isNotEmpty) ...[
                const SizedBox(height: SsLayout.item),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.subscriptionUpi),
                  subtitle: Text(upi),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: upi));
                      SsSnack.success(l.copied, title: l.subscriptionUpi);
                    },
                  ),
                ),
              ],
              if (c.pending) ...[
                const SizedBox(height: SsLayout.section),
                SsGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.subscriptionPending,
                          style: SsLayout.bodyStyle(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SsLayout.item),
                OutlinedButton(
                  onPressed: c.refreshStatus,
                  child: Text(l.retry),
                ),
              ] else ...[
                const SizedBox(height: SsLayout.section),
                TextField(
                  onChanged: (v) => c.transactionId.value = v,
                  decoration: InputDecoration(
                    labelText: l.subscriptionTxnId,
                  ),
                ),
                const SizedBox(height: SsLayout.item),
                TextField(
                  onChanged: (v) => c.note.value = v,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l.notes,
                  ),
                ),
                const SizedBox(height: SsLayout.item),
                OutlinedButton.icon(
                  onPressed: c.pickScreenshot,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    c.screenshotPath.value == null
                        ? l.subscriptionPickScreenshot
                        : l.subscriptionScreenshotSelected,
                  ),
                ),
                if (c.screenshotPath.value != null) ...[
                  const SizedBox(height: SsLayout.item),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(c.screenshotPath.value!),
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                if (c.error.value.isNotEmpty) ...[
                  const SizedBox(height: SsLayout.item),
                  Text(
                    c.error.value == 'transaction_screenshot_required'
                        ? l.subscriptionTxnScreenshotRequired
                        : c.error.value,
                    style: TextStyle(color: scheme.error),
                  ),
                ],
                const SizedBox(height: SsLayout.section),
                FilledButton(
                  onPressed: c.submitting.value
                      ? null
                      : () async {
                          final ok = await c.submitProof();
                          if (ok) {
                            c.closePayForm();
                            SsSnack.success(
                              l.subscriptionSubmitted,
                              title: l.subscriptionTitle,
                            );
                          }
                        },
                  child: Text(
                    c.submitting.value ? l.loading : l.subscriptionSubmit,
                  ),
                ),
              ],
              if (c.required) ...[
                const SizedBox(height: SsLayout.section),
                TextButton(
                  onPressed: () async {
                    final s = await c.refreshStatus();
                    if (s != null && s['required'] != true) {
                      Get.offAllNamed('/home');
                    }
                  },
                  child: Text(l.subscriptionCheckAccess),
                ),
              ],
            ],
          ],
        );
      }),
    );
  }
}
