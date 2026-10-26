import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'ss_feedback.dart';

/// Digits-only international form for wa.me (defaults India +91).
String? ssNormalizeWhatsAppPhone(String? raw) {
  if (raw == null) return null;
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.length == 10) digits = '91$digits';
  if (digits.startsWith('0') && digits.length == 11) {
    digits = '91${digits.substring(1)}';
  }
  if (digits.length < 10) return null;
  return digits;
}

String ssOrderWhatsAppMessage({
  required String shopName,
  required String orderNumber,
  required String customerName,
  required String statusLabel,
  String? deliveryDate,
  required String total,
  required String paid,
  required String balance,
}) {
  final buf = StringBuffer()
    ..writeln(shopName)
    ..writeln('Order: $orderNumber')
    ..writeln('Customer: $customerName')
    ..writeln('Status: $statusLabel');
  if (deliveryDate != null && deliveryDate.isNotEmpty) {
    buf.writeln('Delivery: $deliveryDate');
  }
  buf
    ..writeln('Total: ₹$total')
    ..writeln('Paid: ₹$paid')
    ..writeln('Balance: ₹$balance')
    ..writeln()
    ..writeln('— SilaiSetu');
  return buf.toString().trim();
}

Future<void> ssOpenWhatsApp({
  required BuildContext context,
  required String? phone,
  required String message,
  String? title,
}) async {
  final l = AppLocalizations.of(context)!;
  final digits = ssNormalizeWhatsAppPhone(phone);
  if (digits == null) {
    SsSnack.error(
      l.phoneRequiredForWhatsApp,
      title: title ?? l.shareWhatsApp,
      context: context,
    );
    return;
  }
  final uri = Uri.parse(
    'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
  );
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      SsSnack.error(
        l.whatsAppOpenFailed,
        title: title ?? l.shareWhatsApp,
        context: context,
      );
    }
  } catch (e) {
    if (context.mounted) {
      SsSnack.error(
        l.whatsAppOpenFailed,
        title: title ?? l.shareWhatsApp,
        context: context,
      );
    }
  }
}
