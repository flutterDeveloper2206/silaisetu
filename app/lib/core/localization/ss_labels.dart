import 'package:silaisetu/core/localization/l10n/app_localizations.dart';

/// Shared label helpers for API enums shown in UI.
extension SsOrderLabels on AppLocalizations {
  String orderStatusLabel(String? status) => switch (status) {
        'NEW' => statusNew,
        'CUTTING' => statusCutting,
        'STITCHING' => statusStitching,
        'TRIAL' => statusTrial,
        'READY' => statusReady,
        'DELIVERED' => statusDelivered,
        'CANCELLED' => statusCancelled,
        _ => status ?? '—',
      };

  String paymentKindLabel(String? kind) => switch (kind) {
        'ADVANCE' => kindAdvance,
        'BALANCE' => kindBalance,
        'FULL' => kindFull,
        _ => kind ?? '—',
      };

  String paymentMethodLabel(String? method) => switch (method) {
        'CASH' => methodCash,
        'UPI' => methodUpi,
        'CARD' => methodCard,
        'BANK' || 'BANK_TRANSFER' => methodBank,
        _ => method ?? '—',
      };

  String unitLabel(String? unit) {
    final u = (unit ?? '').toUpperCase();
    if (u == 'CM' || u == 'CENTIMETRE' || u == 'CENTIMETER') return unitCm;
    if (u == 'INCH' || u == 'INCHES' || u == 'IN') return unitInches;
    return unit ?? '';
  }
}
