import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class NotificationsController extends GetxController {
  final api = Get.find<ApiClient>();
  final items = <dynamic>[].obs;
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await api.dio.get('/notifications');
      items.assignAll(
        res.data is List
            ? res.data as List
            : ((res.data as Map?)?['items'] as List? ?? []),
      );
      loading.value = false;
    } catch (e) {
      error.value = ssErrorMessage(e);
      loading.value = false;
    }
  }

  bool isUnread(Map n) {
    if (n['isRead'] is bool) return n['isRead'] != true;
    return n['readAt'] == null;
  }

  String? orderIdFrom(Map n) {
    final payload = n['payload'];
    if (payload is Map && payload['orderId'] != null) {
      return '${payload['orderId']}';
    }
    return null;
  }

  IconData iconFor(String? type) {
    switch (type) {
      case 'DELIVERY_REMINDER':
        return Icons.local_shipping_outlined;
      case 'OVERDUE':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Future<void> onTap(Map n) async {
    if (n['id'] != null && isUnread(n)) {
      try {
        await api.dio.post('/notifications/${n['id']}/read');
      } catch (_) {}
    }
    // Deep-link: DELIVERY_REMINDER / OVERDUE (and any type with orderId) → order detail.
    final orderId = orderIdFrom(n);
    if (orderId != null && orderId.isNotEmpty && orderId != 'null') {
      await Get.toNamed('/orders/$orderId');
      load();
      return;
    }
    load();
  }

  Future<void> markAllRead() async {
    final l = AppLocalizations.of(Get.context!)!;
    try {
      await api.dio.post('/notifications/read-all');
      load();
    } catch (e) {
      SsSnack.fromError(e, title: l.notifications);
    }
  }
}
