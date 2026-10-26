import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';

/// Extracts a short, readable message from API / Dio errors.
String ssErrorMessage(
  Object? error, {
  String? fallback,
  BuildContext? context,
}) {
  final l = context != null
      ? AppLocalizations.of(context)
      : (Get.context != null ? AppLocalizations.of(Get.context!) : null);
  final fb = fallback ?? l?.somethingWentWrong ?? 'Something went wrong';

  if (error == null) return fb;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is List && msg.isNotEmpty) {
        return msg.map((e) => '$e').where((e) => e.isNotEmpty).join('\n');
      }
      if (msg != null && '$msg'.trim().isNotEmpty) return '$msg';
    }
    if (error.response?.statusCode == 401) {
      return l?.sessionExpired ?? 'Session expired. Please sign in again.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return l?.noInternet ?? 'No internet connection. Please try again.';
    }
    // Avoid dumping Dio internals / stack-like messages to users.
    if (error.response == null) {
      return l?.noInternet ?? fb;
    }
  }
  final s = '$error'.trim();
  if (s.startsWith('DioException') || s.contains('Stack Overflow')) {
    return fb;
  }
  return s.isEmpty ? fb : s;
}

/// Floating, theme-aware snackbars (preferred over raw Get.snackbar).
class SsSnack {
  static void success(
    String message, {
    String? title,
    BuildContext? context,
  }) {
    _show(message, title: title, context: context, error: false);
  }

  static void error(
    String message, {
    String? title,
    BuildContext? context,
  }) {
    _show(message, title: title, context: context, error: true);
  }

  static void fromError(
    Object error, {
    String? title,
    BuildContext? context,
    String? fallback,
  }) {
    SsSnack.error(
      ssErrorMessage(error, fallback: fallback, context: context),
      title: title,
      context: context,
    );
  }

  static void _show(
    String message, {
    String? title,
    BuildContext? context,
    required bool error,
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) {
      Get.snackbar(
        title ?? (error ? 'Error' : 'Done'),
        message,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
        backgroundColor:
            error ? const Color(0xFFB3261E) : const Color(0xFF1C1B1F),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final scheme = Theme.of(ctx).colorScheme;
    final bg = error ? scheme.error : scheme.inverseSurface;
    final fg = error ? scheme.onError : scheme.onInverseSurface;

    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: Duration(seconds: error ? 4 : 3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.trim().isNotEmpty) ...[
              Text(
                title,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message,
              style: TextStyle(
                color: fg.withValues(alpha: 0.95),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
