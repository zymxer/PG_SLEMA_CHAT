import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';

class ImageScreen extends StatelessWidget with Logger {
  final ImageMetadata metadata;
  late final Future<Uint8List> future;

  ImageScreen({
    super.key,
    required this.metadata,
  }) {
    future = File(metadata.path).readAsBytes();
    logger.debug("ImageScreen: Attempting to read file from path: ${metadata.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DefaultAppBar(title: "Zdjęcie"),
        Expanded(
          child: DefaultBody(
            mainWidgetsPaddingHorizontal: 0.0,
            child: FutureBuilder<Uint8List>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  logger.error("ImageScreen: Error loading image from ${metadata.path}: ${snapshot.error}");
                  return Center(child: Text("Error loading image: ${snapshot.error}"));
                }

                if (snapshot.data == null) {
                  logger.warning("ImageScreen: No image data received for ${metadata.path}.");
                  return const Center(child: Text("No image data."));
                }

                final data = snapshot.data!;
                logger.debug("ImageScreen: Image data loaded. Size: ${data.lengthInBytes} bytes");

                final image = Image.memory(
                  data,
                  fit: BoxFit.contain,
                );
                return InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 10.0,
                  child: image,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}