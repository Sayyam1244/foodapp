import 'dart:io';

import 'package:image_picker/image_picker.dart';

class FilePickerService {
  // Method to pick a file from the gallery
  static Future<File?> pickFile() async {
    // Use ImagePicker to select an image from the gallery
    XFile? result = await ImagePicker.platform.getImageFromSource(source: ImageSource.gallery);

    // If a file is selected, return it as a File object
    if (result != null) {
      return File(result.path);
    } else {
      // Return null if no file is selected
      return null;
    }
  }
}
