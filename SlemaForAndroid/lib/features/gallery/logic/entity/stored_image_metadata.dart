
import 'dart:convert';

class StoredImageMetadata {
  final String id;
  final String filename;
  final String fileType;

  StoredImageMetadata({
    required this.id,
    required this.filename,
    required this.fileType,
  });

  static StoredImageMetadata fromJson(String value) {
    return _fromJsonObject(jsonDecode(value));
  }

  String toJson() {
    return jsonEncode(_toJsonObject());
  }

  Map<String, dynamic> _toJsonObject() {
    return {
      "id": id,
      "filename": filename,
      "fileType": fileType,
    };
  }

  static StoredImageMetadata _fromJsonObject(Map<String, dynamic> map) {
    return StoredImageMetadata(
      id: map["id"] as String,
      filename: map["filename"] as String,
      fileType: map["fileType"] as String,
    );
  }

  @override
  String toString() {
    return toJson();
  }
}