import 'dart:io';

import 'package:image_picker/image_picker.dart';

class FilePickerService {
  static Future<File?> pickFile() async {
    XFile? result = await ImagePicker.platform
        .getImageFromSource(source: ImageSource.gallery);
    if (result != null) {
      return File(result.path);
    } else {
      return null;
    }
  }
}
