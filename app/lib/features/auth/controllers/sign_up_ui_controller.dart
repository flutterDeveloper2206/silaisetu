import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/services/local_profile_photo.dart';

class SignUpUiController extends GetxController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final altPhone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final photo = Get.find<LocalProfilePhoto>();

  final usePhone = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;
  final pickingPhoto = false.obs;
  final passwordDraft = ''.obs;

  int get passwordStrength {
    final p = passwordDraft.value;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  void onPasswordChanged(String v) => passwordDraft.value = v;

  void toggleObscurePassword() => obscurePassword.toggle();
  void toggleObscureConfirm() => obscureConfirm.toggle();

  void debugFill() {
    usePhone.value = false;
    name.text = 'Kishan Tailor';
    email.text = 'debug@silaisetu.test';
    phone.text = '9876543210';
    altPhone.text = '9123456780';
    password.text = 'Debug@1234';
    confirm.text = 'Debug@1234';
    passwordDraft.value = password.text;
    obscurePassword.value = false;
    obscureConfirm.value = false;
  }

  Future<void> pickPhoto(BuildContext context) async {
    pickingPhoto.value = true;
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          final l = AppLocalizations.of(ctx)!;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l.chooseFromGallery),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l.takePhoto),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                if (photo.path.value != null)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: Theme.of(ctx).colorScheme.error,
                    ),
                    title: Text(l.removePhoto),
                    onTap: () async {
                      await photo.clear();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          );
        },
      );
      if (source == null) return;
      await photo.pickAndSave(source: source);
    } finally {
      pickingPhoto.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    altPhone.dispose();
    password.dispose();
    confirm.dispose();
    super.onClose();
  }
}
