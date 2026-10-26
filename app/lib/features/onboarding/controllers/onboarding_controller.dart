import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class OnboardingController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

  final step = 1.obs;
  final loading = false.obs;
  final error = ''.obs;
  final draftReady = false.obs;
  /// Bumped when debug fill runs so form fields remount with new values.
  final formEpoch = 0.obs;
  bool _pendingDebugFill = false;

  // Step 1
  final shopName = ''.obs;
  final ownerName = ''.obs;
  final shopPhone = ''.obs;
  final shopEmail = ''.obs;
  final altPhone = ''.obs;
  final description = ''.obs;

  // Step 2
  final address1 = ''.obs;
  final address2 = ''.obs;
  final area = ''.obs;
  final city = ''.obs;
  final state = ''.obs;
  final pincode = ''.obs;
  final country = 'IN'.obs;

  // Step 3
  final businessTypes = <String>[].obs;
  final garments = <String>[].obs;
  final unit = 'INCH'.obs;
  final language = 'gu'.obs;
  final currency = 'INR'.obs;

  // Step 4
  final receiptHeader = ''.obs;
  final receiptFooter = ''.obs;
  final receiptContact = ''.obs;
  final paymentMethods = <String>['CASH', 'UPI'].obs;

  late final String idempotencyKey;

  static String _uuidV4() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String h(int i) => bytes[i].toRadixString(16).padLeft(2, '0');
    return '${h(0)}${h(1)}${h(2)}${h(3)}-${h(4)}${h(5)}-${h(6)}${h(7)}-${h(8)}${h(9)}-${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
  }

  @override
  void onInit() {
    super.onInit();
    idempotencyKey = _uuidV4();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    try {
      final res = await api.dio.get('/auth/onboarding');
      final data = res.data as Map<String, dynamic>;
      final draft = data['onboardingDraft'];
      step.value = (data['onboardingStep'] as int?)?.clamp(1, 5) ?? 1;
      if (draft is Map) {
        shopName.value = '${draft['shopName'] ?? ''}';
        ownerName.value = '${draft['ownerName'] ?? ''}';
        shopPhone.value = '${draft['shopPhone'] ?? ''}';
        shopEmail.value = '${draft['shopEmail'] ?? ''}';
        altPhone.value = '${draft['altPhone'] ?? ''}';
        description.value = '${draft['description'] ?? ''}';
        address1.value = '${draft['address1'] ?? ''}';
        address2.value = '${draft['address2'] ?? ''}';
        area.value = '${draft['area'] ?? ''}';
        city.value = '${draft['city'] ?? ''}';
        state.value = '${draft['state'] ?? ''}';
        pincode.value = '${draft['pincode'] ?? ''}';
        country.value = '${draft['country'] ?? 'IN'}';
        unit.value = '${draft['unit'] ?? 'INCH'}';
        language.value = '${draft['language'] ?? 'gu'}';
        receiptHeader.value = '${draft['receiptHeader'] ?? ''}';
        receiptFooter.value = '${draft['receiptFooter'] ?? ''}';
        if (draft['businessTypes'] is List) {
          businessTypes.assignAll(
            (draft['businessTypes'] as List).map((e) => '$e'),
          );
        }
        if (draft['garments'] is List) {
          garments.assignAll((draft['garments'] as List).map((e) => '$e'));
        }
      }
      final u = auth.user.value;
      if (ownerName.value.isEmpty) {
        ownerName.value = '${u?['fullName'] ?? ''}';
      }
      if (shopPhone.value.isEmpty) {
        shopPhone.value = '${u?['phone'] ?? ''}'.replaceFirst('+91', '');
      }
      if (shopEmail.value.isEmpty) {
        shopEmail.value = '${u?['email'] ?? ''}';
      }
    } catch (_) {
      // offline / first visit — start empty
    } finally {
      draftReady.value = true;
      if (_pendingDebugFill) {
        _pendingDebugFill = false;
        _applyDebugData();
      }
    }
  }

  Map<String, dynamic> _draftPayload() => {
        'shopName': shopName.value,
        'ownerName': ownerName.value,
        'shopPhone': shopPhone.value,
        'shopEmail': shopEmail.value,
        'altPhone': altPhone.value,
        'description': description.value,
        'address1': address1.value,
        'address2': address2.value,
        'area': area.value,
        'city': city.value,
        'state': state.value,
        'pincode': pincode.value,
        'country': country.value,
        'businessTypes': businessTypes.toList(),
        'garments': garments.toList(),
        'unit': unit.value,
        'language': language.value,
        'currency': currency.value,
        'receiptHeader': receiptHeader.value,
        'receiptFooter': receiptFooter.value,
        'receiptContact': receiptContact.value,
        'paymentMethods': paymentMethods.toList(),
      };

  Future<bool> saveDraft() async {
    loading.value = true;
    error.value = '';
    try {
      await api.dio.post('/auth/onboarding/draft', data: {
        'step': step.value,
        'data': _draftPayload(),
      });
      return true;
    } on DioException catch (e) {
      error.value = e.response?.data?['message']?.toString() ?? 'error';
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> next() async {
    if (!validateCurrent()) return false;
    final ok = await saveDraft();
    if (!ok) return false;
    if (step.value < 5) step.value++;
    return true;
  }

  void back() {
    if (step.value > 1) step.value--;
  }

  bool validateCurrent() {
    error.value = '';
    switch (step.value) {
      case 1:
        if (shopName.value.trim().length < 2) {
          error.value = 'Shop name required';
          return false;
        }
        return true;
      case 2:
        if (address1.value.trim().isEmpty ||
            city.value.trim().isEmpty ||
            state.value.trim().isEmpty ||
            pincode.value.trim().length < 6) {
          error.value = 'Complete address fields';
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void fillDebugData() {
    if (!draftReady.value) {
      _pendingDebugFill = true;
      return;
    }
    _applyDebugData();
  }

  void _applyDebugData() {
    final u = auth.user.value;
    shopName.value = 'SilaiSetu Demo Shop';
    ownerName.value = '${u?['fullName'] ?? 'Kishan Tailor'}';
    shopPhone.value = '${u?['phone'] ?? '9876543210'}'.replaceFirst('+91', '');
    shopEmail.value = '${u?['email'] ?? 'debug@silaisetu.test'}';
    altPhone.value = '9123456780';
    description.value = 'Men & women custom stitching — Ahmedabad.';
    address1.value = '12, Relief Road';
    address2.value = 'Near Lal Darwaja';
    area.value = 'Kalupur';
    city.value = 'Ahmedabad';
    state.value = 'Gujarat';
    pincode.value = '380001';
    country.value = 'IN';
    businessTypes.assignAll(['mens', 'womens', 'unisex']);
    garments.assignAll(['shirt', 'trouser', 'kurta', 'blouse']);
    unit.value = 'INCH';
    language.value = 'gu';
    currency.value = 'INR';
    receiptHeader.value = 'SilaiSetu Demo Shop';
    receiptFooter.value = 'Thank you — visit again!';
    receiptContact.value = shopPhone.value;
    paymentMethods.assignAll(['CASH', 'UPI']);
    error.value = '';
    formEpoch.value++;
  }

  Future<bool> finish() async {
    if (!validateCurrent()) return false;
    loading.value = true;
    error.value = '';
    try {
      final res = await api.dio.post('/auth/onboarding/complete', data: {
        'shopName': shopName.value.trim(),
        'ownerDisplayName': ownerName.value.trim(),
        'shopPhone': shopPhone.value.trim(),
        'shopEmail': shopEmail.value.trim().isEmpty
            ? null
            : shopEmail.value.trim(),
        'altPhone': altPhone.value.trim().isEmpty ? null : altPhone.value.trim(),
        'description': description.value.trim().isEmpty
            ? null
            : description.value.trim(),
        'addressLine1': address1.value.trim(),
        'addressLine2':
            address2.value.trim().isEmpty ? null : address2.value.trim(),
        'area': area.value.trim().isEmpty ? null : area.value.trim(),
        'city': city.value.trim(),
        'state': state.value.trim(),
        'pincode': pincode.value.trim(),
        'country': country.value,
        'measurementUnit': unit.value,
        'defaultLanguage': language.value,
        'preferences': {
          'businessTypes': businessTypes.toList(),
          'garments': garments.toList(),
          'currency': currency.value,
        },
        'receiptHeader':
            receiptHeader.value.trim().isEmpty ? null : receiptHeader.value,
        'receiptFooter':
            receiptFooter.value.trim().isEmpty ? null : receiptFooter.value,
        'receiptContact':
            receiptContact.value.trim().isEmpty ? null : receiptContact.value,
        'receiptLanguage': language.value,
        'paymentMethods': paymentMethods.toList(),
        'idempotencyKey': idempotencyKey,
      });
      final data = res.data as Map;
      final shop = data['shop'] as Map?;
      final shopId = shop?['id'] as String?;
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      // New tokens include shop memberships — required for X-Shop-Id APIs.
      if (access != null && access.isNotEmpty) {
        await api.persistAuth(
          accessToken: access,
          refreshToken: refresh,
          shopId: shopId,
        );
      } else if (shopId != null) {
        await api.setShopId(shopId);
      }
      if (data['user'] is Map) {
        final u = Map<String, dynamic>.from(data['user'] as Map);
        auth.user.value = u;
        await api.cacheUser(u);
        await api.ensureShopFromMemberships(
          (u['memberships'] as List?) ?? const [],
        );
      } else {
        await auth.hydrate();
      }
      return true;
    } on DioException catch (e) {
      error.value = e.response?.data?['message']?.toString() ?? 'error';
      return false;
    } finally {
      loading.value = false;
    }
  }
}
