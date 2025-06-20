import 'package:flutter/material.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/service/thumbnail_service.dart';
import 'package:pg_slema/features/gallery/presentation/screen/image_screen.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';

class SingleImageWidget extends StatefulWidget {
  final ImageMetadata metadata;
  final ThumbnailService thumbnailService;

  const SingleImageWidget({
    super.key,
    required this.metadata,
    required this.thumbnailService,
  });

  @override
  State<SingleImageWidget> createState() => _SingleImageWidgetState();
}

class _SingleImageWidgetState extends State<SingleImageWidget> with Logger {
  static const int imageWidth = 80;
  static const int imageHeight = 100;

  late Future<ImageProvider?> thumbnailFuture;

  @override
  void initState() {
    super.initState();
    if (widget.metadata.path.isNotEmpty) {
      thumbnailFuture = widget.thumbnailService.loadThumbnail(
        widget.metadata.id,
        widget.metadata.path,
        imageWidth,
      );
    } else {
      // If path is somehow empty, create an error future
      logger.error("ImageMetadata path is empty for ID: ${widget.metadata.id}. Cannot load thumbnail.");
      thumbnailFuture = Future.error("Empty path provided for thumbnail.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: InkWell(
        onTap: () => _onTapped(context),
        child: SizedBox(
          width: imageWidth.toDouble(),
          height: imageHeight.toDouble(),
          child: FutureBuilder<ImageProvider?>(
            future: thumbnailFuture,
            builder: _futureBuilder,
          ),
        ),
      ),
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot<ImageProvider?> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      logger.error("Error loading thumbnail for ${widget.metadata.path}: ${snapshot.error}");
      return const Center(child: Text("Error loading image."));
    }

    if (snapshot.data == null) {
      logger.warning("No thumbnail data for ${widget.metadata.path}. Displaying placeholder.");
      return const Center(child: Icon(Icons.broken_image));
    }

    return Image(
      image: snapshot.data!,
      fit: BoxFit.cover,
      width: imageWidth.toDouble(),
      height: imageHeight.toDouble(),
      errorBuilder: (context, error, stackTrace) {
        logger.error("Failed to render Image widget for ${widget.metadata.path}: $error");
        return const Center(child: Icon(Icons.error));
      },
    );
  }

  void _onTapped(BuildContext context) {
    logger.debug("Tapped image ${widget.metadata.filename}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageScreen(
          metadata: widget.metadata,
        ),
      ),
    );
  }
}