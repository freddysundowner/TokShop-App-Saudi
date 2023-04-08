import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tokshop/screens/exceptions/local_files_handling/image_picking_exceptions.dart';

import '../utils/text.dart';
import '../utils/utils.dart';

choseImageFromLocalFiles(BuildContext context,
    {CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
    int maxSizeInKB = 1024,
    int minSizeInKB = 5}) async {
  final imgSource = await showDialog(
    builder: (context) {
      return AlertDialog(
        title: const Text(chose_image_source),
        actions: [
          TextButton(
            child: const Text(camera),
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text(gallery),
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      );
    },
    context: context,
  );

  var imgPicker = ImagePicker();
  if (imgSource == null) {
    printOut("Image source empty");
    throw LocalImagePickingInvalidImageException(
        message: no_image_source_selected);
  }
  XFile? imagePicked =
      await imgPicker.pickImage(source: imgSource, imageQuality: 40);

  PickedFile newimagePicked = PickedFile((await ImageCropper().cropImage(
          sourcePath: imagePicked!.path,
          aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2),
          cropStyle: CropStyle.rectangle))!
      .path);

  return newimagePicked.path;
}
