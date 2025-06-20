import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/entity/stored_image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/repository/stored_image_metadata_repository.dart';

import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:uuid/uuid.dart';

class ImageServiceChatImpl with Logger {
  final picker = ImagePicker();
  final StoredImageMetadataRepository repository;

  ImageServiceChatImpl({
    required this.repository,
  });

  Future<String> _getAppImagesDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appImagesPath = '${directory.path}/app_images';
    await Directory(appImagesPath).create(recursive: true);
    return appImagesPath;
  }


  String _getMimeTypeFromPath(String path) {
    final lowerCasePath = path.toLowerCase();
    if (lowerCasePath.endsWith('.jpg') || lowerCasePath.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lowerCasePath.endsWith('.png')) {
      return 'image/png';
    } else if (lowerCasePath.endsWith('.gif')) {
      return 'image/gif';
    } else if (lowerCasePath.endsWith('.bmp')) {
      return 'image/bmp';
    } else if (lowerCasePath.endsWith('.webp')) {
      return 'image/webp';
    }
    logger.warning("Could not determine specific image MIME type for $path. Defaulting to image/jpeg.");
    return 'image/jpeg';
  }

  @override
  Future<List<ImageMetadata>> loadImageData() async {
    final storedImageMetadata = await repository.getAll();
    final imageFutures = storedImageMetadata.map((item) async {
      try {
        final file = File(item.filename);
        if (!await file.exists()) {
          logger.warning("Image file not found on disk: ${item.filename}");
          return null;
        }
        final stat = await file.stat();

        final fileType = item.fileType;

        logger.debug(
            "Reading stat for file \"${item.filename}\": date = ${stat.changed}");
        return ImageMetadata(
          id: item.id,
          filename: item.filename.split(Platform.pathSeparator).last,
          path: item.filename,
          date: stat.changed,
          fileType: fileType,
        );
      } catch (ex) {
        logger.warning("Could not stat file ${item.filename} for ImageMetadata: $ex");
        return null;
      }
    });

    final data = await Future.wait(imageFutures);
    return data
        .where((item) => item != null)
        .map((item) => item!)
        .toList(growable: false);
  }

  Future<bool> checkIfSaved(String filename) async {
    final metadata = await loadImageData();
    return metadata.any((entry) => entry.filename == filename);
  }

  @override
  Future<(List<ImageMetadata>, List<XFile>)>
  selectAndAddImagesFromGallery() async {
    final pickedFiles = await picker.pickMultiImage(limit: 10);
    List<ImageMetadata> metadataList = [];
    List<XFile> savedXFiles = [];
    for (var file in pickedFiles) {
      try {
        final metadata = await _processAndSaveImage(file);
        if (metadata != null) {
          metadataList.add(metadata);
          savedXFiles.add(file);
        }
      } catch (e) {
        logger.error("Failed to process and save picked file ${file.name}: $e");
      }
    }
    return (metadataList, savedXFiles);
  }


  Future<ImageMetadata?> _processAndSaveImage(XFile? pickedFile) async {
    if (pickedFile == null) {
      logger.debug("Image not selected (in _processAndSaveImage).");
      return null;
    }

    final appImagesPath = await _getAppImagesDirectory();
    final newFileName = '${const Uuid().v4()}_${pickedFile.name}';
    final newFilePath = '$appImagesPath/$newFileName';

    try {
      final savedFile = await File(pickedFile.path).copy(newFilePath);
      logger.debug("Image copied to permanent storage: ${savedFile.path}");


      final determinedFileType = pickedFile.mimeType ?? _getMimeTypeFromPath(pickedFile.name);
      final metadata = StoredImageMetadata(
        id: const Uuid().v4(),
        filename: savedFile.path,
        fileType: determinedFileType,
      );


      await repository.save(metadata);
      logger.debug("Image metadata saved to repository: ${metadata.filename}");

      return ImageMetadata(
        id: metadata.id,
        filename: pickedFile.name,
        path: savedFile.path,
        date: (await savedFile.stat()).changed,
        fileType: determinedFileType,
      );
    } catch (e) {
      logger.error("Error copying/saving image from ${pickedFile.path} to $newFilePath: $e");
      return null;
    }
  }

  @override
  Future<ImageMetadata> saveImage(XFile file) async {

    final determinedFileType = file.mimeType ?? _getMimeTypeFromPath(file.name);
    final metadata = StoredImageMetadata(
      id: const Uuid().v4(),
      filename: file.path,
      fileType: determinedFileType,
    );


    await repository.save(metadata);
    logger.debug("Downloaded image metadata saved to repository: ${metadata.filename}");

    return ImageMetadata(
      id: metadata.id,
      filename: file.name,
      path: file.path,
      date: (await FileStat.stat(file.path)).changed,
      fileType: determinedFileType,
    );
  }
}