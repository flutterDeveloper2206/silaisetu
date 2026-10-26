import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/services/local_profile_photo.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  final photo = Get.find<LocalProfilePhoto>();

  late final name = TextEditingController(
    text: '${auth.user.value?['fullName'] ?? ''}',
  );
  late final phone = TextEditingController(
    text: '${auth.user.value?['phone'] ?? ''}',
  );

  final saving = false.obs;

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    super.onClose();
  }

  Future<void> changePhoto() async {
    final ctx = Get.context;
    if (ctx == null) return;
    final l = AppLocalizations.of(ctx)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: ctx,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.chooseFromGallery),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.takePhoto),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            if (photo.path.value != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(sheetCtx).colorScheme.error,
                ),
                title: Text(l.removePhoto),
                onTap: () async {
                  await photo.clear();
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await photo.pickAndSave(source: source);
  }

  Future<void> save() async {
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx)! : null;
    saving.value = true;
    try {
      await auth.api.dio.patch('/auth/me', data: {
        'fullName': name.text.trim(),
        'phone': phone.text.trim(),
      });
      await auth.hydrate();
      Get.snackbar(l?.profile ?? 'Profile', l?.save ?? 'Saved');
    } finally {
      saving.value = false;
    }
  }
}

class ChangePasswordController extends GetxController {
  final auth = Get.find<AuthController>();
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  final saving = false.obs;

  @override
  void onClose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx)! : null;
    if (next.text != confirm.text || next.text.length < 8) {
      Get.snackbar(
        l?.changePassword ?? 'Change password',
        l?.passwordMismatch ?? 'Password mismatch',
      );
      return;
    }
    saving.value = true;
    try {
      await auth.api.dio.post('/auth/change-password', data: {
        'currentPassword': current.text,
        'newPassword': next.text,
      });
      Get.offAllNamed('/sign-in');
      Get.snackbar(
        l?.changePassword ?? 'Change password',
        l?.signIn ?? 'Sign in',
      );
    } finally {
      saving.value = false;
    }
  }
}
