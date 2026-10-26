import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

enum OrdersListMode { total, pending, overdue, pendingPayment, status }

class OrdersListController extends GetxController {
  OrdersListController({required this.mode, this.status});

  final OrdersListMode mode;
  final String? status;

  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();
  final search = TextEditingController();

  final items = <dynamic>[].obs;
  final loading = true.obs;
  final error = RxnString();

  static const pendingStatuses = {
    'NEW',
    'CUTTING',
    'STITCHING',
    'TRIAL',
    'READY',
  };

  static String tagFor(OrdersListMode mode, String? status) =>
      '${mode.name}_${status ?? 'all'}';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    search.dispose();
    super.onClose();
  }

  String title(AppLocalizations l) => switch (mode) {
        OrdersListMode.total => l.navTotal,
        OrdersListMode.pending => l.navPending,
        OrdersListMode.overdue => l.overdue,
        OrdersListMode.pendingPayment => l.outstanding,
        OrdersListMode.status => status ?? l.orders,
      };

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      await auth.ensureShopContext();
      final params = <String, dynamic>{'pageSize': 50};
      switch (mode) {
        case OrdersListMode.overdue:
          params['overdue'] = 'true';
        case OrdersListMode.status:
          if (status != null) params['status'] = status;
        case OrdersListMode.pending:
        case OrdersListMode.pendingPayment:
        case OrdersListMode.total:
          break;
      }
      final res = await api.dio.get('/orders', queryParameters: params);
      var list = (res.data as Map)['items'] as List? ?? [];
      if (mode == OrdersListMode.pending) {
        list = list
            .where((o) => pendingStatuses.contains('${(o as Map)['status']}'))
            .toList();
      }
      if (mode == OrdersListMode.pendingPayment) {
        list = list.where((o) {
          final m = o as Map;
          final bal = num.tryParse('${m['balanceDue']}') ?? 0;
          return bal > 0 && m['status'] != 'CANCELLED';
        }).toList();
      }
      final q = search.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        list = list.where((o) {
          final m = o as Map;
          final c = m['customer'] as Map? ?? {};
          return '${m['orderNumber']}'.toLowerCase().contains(q) ||
              '${c['fullName']}'.toLowerCase().contains(q) ||
              '${c['phone']}'.contains(q);
        }).toList();
      }
      items.assignAll(list);
      loading.value = false;
    } on DioException catch (e) {
      error.value = e.response?.data is Map
          ? '${(e.response!.data as Map)['message'] ?? e.message}'
          : e.message;
      loading.value = false;
    } catch (e) {
      error.value = '$e';
      loading.value = false;
    }
  }
}
