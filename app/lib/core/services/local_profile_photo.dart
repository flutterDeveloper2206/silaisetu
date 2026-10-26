import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shop logo / profile photo stored only on this device.
class LocalProfilePhoto extends GetxController {
  static const _prefsKey = 'ss_profile_photo';
  static const _fileName = 'ss_profile_photo.jpg';

  final path = RxnString();

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final stored = p.getString(_prefsKey);
    if (stored != null && File(stored).existsSync()) {
      path.value = stored;
    } else {
      path.value = null;
    }
  }

  Future<File?> pickAndSave({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return saveFromPath(picked.path);
  }

  Future<File> saveFromPath(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/$_fileName');
    await File(sourcePath).copy(dest.path);
    // Touch mtime so Image.file rebuilds when replaced.
    await dest.setLastModified(DateTime.now());
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, dest.path);
    path.value = dest.path;
    path.refresh();
    return dest;
  }

  Future<void> clear() async {
    final current = path.value;
    if (current != null) {
      final f = File(current);
      if (await f.exists()) await f.delete();
    }
    final p = await SharedPreferences.getInstance();
    await p.remove(_prefsKey);
    path.value = null;
  }
}
