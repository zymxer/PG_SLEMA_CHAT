import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:path_provider/path_provider.dart';
import 'package:pg_slema/features/gallery/logic/service/thumbnail_service.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:image/image.dart' as img_lib;

class ThumbnailServiceImpl extends ThumbnailService with Logger {
  @override
  Future<material.ImageProvider?> loadThumbnail(
      String id, String imagePath, int width) async {

    final directory = await getTemporaryDirectory();
    final thumbnailPath = "${directory.path}/_thumbnails/$id.png";


    final thumbnailProviderA = await _loadThumbnailProvider(thumbnailPath);
    if (thumbnailProviderA != null) {
      return thumbnailProviderA;
    }


    return _generateThumbnailProvider(imagePath, thumbnailPath, width);
  }


  Future<material.ImageProvider?> _loadThumbnailProvider(String thumbnailPath) async {
    try {
      final file = File(thumbnailPath);
      if (await file.exists()) {
        return material.FileImage(file);
      }
      return null;
    } catch (ex) {
      logger.warning("Could not load thumbnail from path: $thumbnailPath. Exception: $ex");
      return null;
    }
  }


  Future<material.ImageProvider?> _generateThumbnailProvider(
      String imagePath, String thumbnailPath, int width) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        logger.warning("Original image file not found at path: $imagePath for thumbnail generation.");
        return null;
      }

      final imageBytes = await imageFile.readAsBytes();
      final image = img_lib.decodeImage(imageBytes);

      if (image == null) {
        logger.warning("Could not decode image from bytes for path: $imagePath");
        return null;
      }

      final resizedImage = img_lib.copyResize(
        image,
        width: width,
      );
      final thumbnailImageBytes = img_lib.encodePng(resizedImage);

      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.create(recursive: true);
      await thumbnailFile.writeAsBytes(thumbnailImageBytes);

      logger.debug(
          "Generated thumbnail for image \"$imagePath\" at \"$thumbnailPath\"");


      return material.FileImage(thumbnailFile);
    } catch (ex) {
      logger.error("Could not generate thumbnail for image $imagePath. Exception: $ex");
      return null;
    }
  }
}