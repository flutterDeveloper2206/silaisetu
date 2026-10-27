import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';

class SubscriptionController extends GetxController {
  final api = Get.find<ApiClient>();

  final loading = true.obs;
  final submitting = false.obs;
  final error = ''.obs;
  final status = Rxn<Map<String, dynamic>>();
  final transactionId = ''.obs;
  final note = ''.obs;
  final screenshotPath = RxnString();

  bool get required => status.value?['required'] == true;
  bool get pending => status.value?['pendingProof'] != null;
  Map? get config => status.value?['config'] as Map?;

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
  }

  Future<Map<String, dynamic>?> refreshStatus() async {
    loading.value = true;
    error.value = '';
    try {
      final res = await api.dio.get('/billing/subscription');
      status.value = Map<String, dynamic>.from(res.data as Map);
      return status.value;
    } on DioException catch (e) {
      error.value = e.response?.data is Map
          ? '${(e.response!.data as Map)['message'] ?? e.message}'
          : '${e.message}';
      return null;
    } catch (e) {
      error.value = '$e';
      return null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> pickScreenshot() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) screenshotPath.value = file.path;
  }

  Future<bool> submitProof() async {
    final txn = transactionId.value.trim();
    final path = screenshotPath.value;
    if (txn.length < 4 || path == null || path.isEmpty) {
      error.value = 'transaction_screenshot_required';
      return false;
    }
    submitting.value = true;
    error.value = '';
    try {
      final form = FormData.fromMap({
        'transactionId': txn,
        if (note.value.trim().isNotEmpty) 'note': note.value.trim(),
        'screenshot': await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        ),
      });
      await api.dio.post(
        '/billing/subscription/proof',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      await refreshStatus();
      return true;
    } on DioException catch (e) {
      error.value = e.response?.data is Map
          ? '${(e.response!.data as Map)['message'] ?? e.message}'
          : '${e.message}';
      return false;
    } finally {
      submitting.value = false;
    }
  }
}
