import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class CalendarController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

  final data = Rxn<Map<String, dynamic>>();
  final loading = true.obs;
  final error = RxnString();
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>(DateTime.now());
  final format = CalendarFormat.month.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String dateOnly(dynamic v) {
    final s = '$v';
    if (s.length >= 10) return s.substring(0, 10);
    return s.isEmpty || s == 'null' ? '—' : s;
  }

  DateTime? parseDay(dynamic v) {
    final s = dateOnly(v);
    if (s == '—' || s.length < 10) return null;
    return DateTime.tryParse(s);
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      await auth.ensureShopContext();
      final focused = focusedDay.value;
      final from = DateTime(focused.year, focused.month - 1, 1);
      final to = DateTime(focused.year, focused.month + 2, 0);
      final res = await api.dio.get('/calendar', queryParameters: {
        'from': iso(from),
        'to': iso(to),
      });
      data.value = res.data as Map<String, dynamic>;
      loading.value = false;
    } on DioException catch (e) {
      error.value = e.response?.data is Map
          ? '${(e.response!.data as Map)['message'] ?? e.message}'
          : (e.type == DioExceptionType.connectionError
              ? 'offline'
              : e.message);
      loading.value = false;
    } catch (e) {
      error.value = '$e';
      loading.value = false;
    }
  }

  List<Map> get orders {
    final raw = data.value?['orders'] as List? ?? [];
    return raw.map((e) => e as Map).toList();
  }

  bool hasTrial(DateTime day) => orders.any((m) {
        final d = parseDay(m['trialDate']);
        return d != null && isSameDay(d, day);
      });

  bool hasDelivery(DateTime day) => orders.any((m) {
        final d = parseDay(m['deliveryDate']);
        return d != null && isSameDay(d, day);
      });

  List<Map> get filteredOrders {
    final day = selectedDay.value;
    if (day == null) return orders;
    return orders.where((m) {
      final trial = parseDay(m['trialDate']);
      final delivery = parseDay(m['deliveryDate']);
      return (trial != null && isSameDay(trial, day)) ||
          (delivery != null && isSameDay(delivery, day));
    }).toList();
  }

  void clearSelection() => selectedDay.value = null;

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
    load();
  }

  void onFormatChanged(CalendarFormat f) => format.value = f;
}
