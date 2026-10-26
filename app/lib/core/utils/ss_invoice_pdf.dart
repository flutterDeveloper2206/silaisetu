import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'ss_feedback.dart';

class SsInvoiceData {
  const SsInvoiceData({
    required this.shopName,
    this.shopPhone,
    this.shopAddress,
    this.receiptHeader,
    this.receiptFooter,
    required this.orderNumber,
    required this.customerName,
    this.customerPhone,
    required this.statusLabel,
    this.trialDate,
    this.deliveryDate,
    required this.total,
    required this.paid,
    required this.balance,
    required this.items,
    required this.payments,
  });

  final String shopName;
  final String? shopPhone;
  final String? shopAddress;
  final String? receiptHeader;
  final String? receiptFooter;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final String statusLabel;
  final String? trialDate;
  final String? deliveryDate;
  final String total;
  final String paid;
  final String balance;
  final List<SsInvoiceLine> items;
  final List<SsInvoicePayment> payments;
}

class SsInvoiceLine {
  const SsInvoiceLine({
    required this.name,
    required this.qty,
    required this.amount,
  });
  final String name;
  final String qty;
  final String amount;
}

class SsInvoicePayment {
  const SsInvoicePayment({
    required this.amount,
    required this.kind,
    required this.method,
    this.date,
  });
  final String amount;
  final String kind;
  final String method;
  final String? date;
}

Future<pw.Document> ssBuildInvoicePdf(SsInvoiceData data) async {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => [
        if (data.receiptHeader != null && data.receiptHeader!.trim().isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              data.receiptHeader!,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
        pw.Text(
          data.shopName,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        if (data.shopPhone != null && data.shopPhone!.isNotEmpty)
          pw.Text('Phone: ${data.shopPhone}', style: const pw.TextStyle(fontSize: 10)),
        if (data.shopAddress != null && data.shopAddress!.isNotEmpty)
          pw.Text(data.shopAddress!, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 16),
        pw.Text(
          'Invoice / Receipt',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Order: ${data.orderNumber}'),
        pw.Text('Customer: ${data.customerName}'),
        if (data.customerPhone != null && data.customerPhone!.isNotEmpty)
          pw.Text('Phone: ${data.customerPhone}'),
        pw.Text('Status: ${data.statusLabel}'),
        if (data.trialDate != null) pw.Text('Trial: ${data.trialDate}'),
        if (data.deliveryDate != null)
          pw.Text('Delivery: ${data.deliveryDate}'),
        pw.SizedBox(height: 16),
        pw.Text(
          'Garments',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Item', 'Qty', 'Amount'],
          data: [
            for (final line in data.items)
              [line.name, line.qty, '₹${line.amount}'],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerRight,
          },
        ),
        pw.SizedBox(height: 16),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Total: ₹${data.total}'),
              pw.Text('Paid: ₹${data.paid}'),
              pw.Text(
                'Balance: ₹${data.balance}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        if (data.payments.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          pw.Text(
            'Payments',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          for (final p in data.payments)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(
                '₹${p.amount} · ${p.kind} · ${p.method}${p.date != null ? ' · ${p.date}' : ''}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
        ],
        if (data.receiptFooter != null &&
            data.receiptFooter!.trim().isNotEmpty) ...[
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Text(
            data.receiptFooter!,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 12),
        pw.Text(
          'Generated by SilaiSetu',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    ),
  );
  return doc;
}

Future<File> ssWriteInvoiceFile(SsInvoiceData data) async {
  final doc = await ssBuildInvoicePdf(data);
  final bytes = await doc.save();
  final dir = await getTemporaryDirectory();
  final safe = data.orderNumber.replaceAll(RegExp(r'[^\w\-]+'), '_');
  final file = File('${dir.path}/invoice_$safe.pdf');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<void> ssShareInvoicePdf(
  BuildContext context,
  SsInvoiceData data, {
  String? title,
}) async {
  final l = AppLocalizations.of(context)!;
  try {
    final file = await ssWriteInvoiceFile(data);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Invoice ${data.orderNumber}',
        text: '${data.shopName} — ${data.orderNumber}',
      ),
    );
    if (context.mounted) {
      SsSnack.success(
        l.pdfShared,
        title: title ?? l.sharePdf,
        context: context,
      );
    }
  } catch (e) {
    if (context.mounted) {
      SsSnack.error(
        l.pdfCreateFailed,
        title: title ?? l.sharePdf,
        context: context,
      );
    }
  }
}

Future<void> ssPreviewInvoicePdf(
  BuildContext context,
  SsInvoiceData data, {
  String? title,
}) async {
  final l = AppLocalizations.of(context)!;
  try {
    final doc = await ssBuildInvoicePdf(data);
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  } catch (e) {
    if (context.mounted) {
      SsSnack.error(
        l.pdfCreateFailed,
        title: title ?? l.previewPdf,
        context: context,
      );
    }
  }
}

SsInvoiceData ssInvoiceFromOrder({
  required Map order,
  required List payments,
  required String statusLabel,
  required String Function(String?) kindLabel,
  required String Function(String?) methodLabel,
  Map? shop,
  Map? settings,
}) {
  final customer = order['customer'] as Map? ?? {};
  final items = order['items'] as List? ?? [];
  String? d(dynamic v) {
    final s = '$v';
    if (s.length >= 10 && s != 'null') return s.substring(0, 10);
    return null;
  }

  final addressParts = <String>[
    if ('${shop?['addressLine1'] ?? ''}'.isNotEmpty) '${shop?['addressLine1']}',
    if ('${shop?['city'] ?? ''}'.isNotEmpty) '${shop?['city']}',
    if ('${shop?['pincode'] ?? ''}'.isNotEmpty) '${shop?['pincode']}',
  ];
  final legacyAddress = '${shop?['address'] ?? ''}';
  final address = addressParts.isNotEmpty
      ? addressParts.join(', ')
      : (legacyAddress.isEmpty || legacyAddress == 'null' ? null : legacyAddress);

  return SsInvoiceData(
    shopName: '${shop?['name'] ?? 'Shop'}',
    shopPhone: '${shop?['phone'] ?? ''}'.isEmpty ? null : '${shop?['phone']}',
    shopAddress: address,
    receiptHeader: settings?['receiptHeader']?.toString(),
    receiptFooter: settings?['receiptFooter']?.toString(),
    orderNumber: '${order['orderNumber']}',
    customerName: '${customer['fullName'] ?? ''}',
    customerPhone:
        '${customer['phone'] ?? ''}'.isEmpty ? null : '${customer['phone']}',
    statusLabel: statusLabel,
    trialDate: d(order['trialDate']),
    deliveryDate: d(order['deliveryDate']),
    total: '${order['totalAmount']}',
    paid: '${order['amountPaid']}',
    balance: '${order['balanceDue']}',
    items: [
      for (final it in items)
        if (it is Map)
          SsInvoiceLine(
            name: '${it['garmentName']}',
            qty: '${it['quantity'] ?? 1}',
            amount: '${it['lineTotal'] ?? it['unitPrice'] ?? 0}',
          ),
    ],
    payments: [
      for (final p in payments)
        if (p is Map)
          SsInvoicePayment(
            amount: '${p['amount']}',
            kind: kindLabel('${p['kind']}'),
            method: methodLabel('${p['method']}'),
            date: d(p['createdAt']),
          ),
    ],
  );
}
