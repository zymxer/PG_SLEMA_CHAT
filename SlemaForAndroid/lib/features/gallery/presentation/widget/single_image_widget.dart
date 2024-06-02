import 'package:flutter/material.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';

class SingleImageWidget extends StatelessWidget {
  final ImageMetadata metadata;

  const SingleImageWidget({
    super.key,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(),
    );
  }
}
