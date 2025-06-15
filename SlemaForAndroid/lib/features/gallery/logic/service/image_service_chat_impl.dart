import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/entity/stored_image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/repository/stored_image_metadata_repository.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:uuid/uuid.dart';

class ImageServiceChatImpl with Logger {
  final picker = ImagePicker();

  final StoredImageMetadataRepository repository;

  ImageServiceChatImpl({
    required this.repository,
  });

  Future<List<ImageMetadata>> loadImageData() async {
    final storedImageMetadata = await repository.getAll();
    final imageFutures = storedImageMetadata.map((item) async {
      try {
        final stat = await FileStat.stat(item.filename);

        logger.debug(
            "Reading stat for file \"${item.filename}\": date = ${stat.changed}");
        return ImageMetadata(
          id: item.id,
          filename: item.filename,
          date: stat.changed,
        );
      } catch (ex) {
        logger.warning("Could not stat file ${item.filename}");
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

  Future<(List<ImageMetadata>, List<XFile>)>
      selectAndAddImagesFromGallery() async {
    final pickedFiles = await picker.pickMultiImage(limit: 10);
    return _saveImages(pickedFiles);
  }

  Future<ImageMetadata> saveImage(XFile file) async {
    final metadata = StoredImageMetadata(
      id: const Uuid().v4(),
      filename: file.path,
    );
    await repository.save(metadata);
    return ImageMetadata(
        id: metadata.id,
        filename: metadata.filename,
        date: (await FileStat.stat(metadata.filename)).changed);
  }

  Future<(List<ImageMetadata>, List<XFile>)> _saveImages(
      List<XFile> pickedFiles) async {
    if (pickedFiles.isEmpty) {
      logger.debug("Images not selected.");
      return (<ImageMetadata>[], <XFile>[]);
    }
    List<ImageMetadata> metadataList = [];
    for (var file in pickedFiles) {
      final metadata = StoredImageMetadata(
        id: const Uuid().v4(),
        filename: file.path,
      );
      await repository.save(metadata);
      metadataList.add(ImageMetadata(
        id: metadata.id,
        filename: metadata.filename,
        date: (await FileStat.stat(metadata.filename)).changed,
      ));
    }
    return (metadataList, pickedFiles);
  }
}
