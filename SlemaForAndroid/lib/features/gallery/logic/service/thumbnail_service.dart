import 'package:flutter/material.dart';

abstract class ThumbnailService {
  Future<ImageProvider?> loadThumbnail(String id, String imagePath, int width);
}
