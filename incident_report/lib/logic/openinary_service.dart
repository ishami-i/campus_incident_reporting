import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// What gets stored in Firestore (`incidents.image`, `users.photo`).
class OpeninaryImage {
  final String path;
  final String url;
  const OpeninaryImage({required this.path, required this.url});

  Map<String, String> toMap() => {'path': path, 'url': url};

  static OpeninaryImage? fromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final path = m['path'], url = m['url'];
    if (path is String && url is String) {
      return OpeninaryImage(path: path, url: url);
    }
    return null;
  }
}

class OpeninaryException implements Exception {
  final String message;
  const OpeninaryException(this.message);
  @override
  String toString() => 'OpeninaryException: $message';
}

class OpeninaryService {
  static const String apiHost = 'https://cdn.openinary.dev';
  static const String bucketId = '42a4c7a2-1798-4ac2-9028-571a59ab6a93';
  static const String deliveryBase = '$apiHost/b/$bucketId';

  static const int maxBytes = 5 * 1024 * 1024; // 5 MB
  static const Set<String> _allowedExt = {'jpg', 'jpeg', 'png', 'webp'};

  static String get _apiKey {
    final key = dotenv.env['openinary_key'];
    if (key == null || key.isEmpty) {
      throw const OpeninaryException('openinary_key is missing from .env');
    }
    return key;
  }

  /// Uploads an image and returns its path + delivery URL.
  /// Throws [OpeninaryException] on any failure. It never returns a URL for a
  /// file that was not actually uploaded.
  static Future<OpeninaryImage> uploadImage({
    required List<int> bytes,
    required String fileName,
  }) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    if (!_allowedExt.contains(ext)) {
      throw const OpeninaryException('Only JPG, PNG or WEBP images are allowed');
    }
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const OpeninaryException('Image must be between 1 byte and 5 MB');
    }

    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$apiHost/upload'))
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..headers['User-Agent'] = 'CampusIncidentReportingApp/1.0'
        ..fields['bucket_id'] = bucketId
        ..files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: uniqueName));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw OpeninaryException('Upload failed (HTTP ${response.statusCode})');
      }

      final data = jsonDecode(response.body);
      final path = data is Map ? (data['path'] ?? data['filename']) : null;
      if (path is! String || path.isEmpty) {
        throw const OpeninaryException('Upload response had no file path');
      }
      return OpeninaryImage(path: path, url: urlFor(path));
    } on OpeninaryException {
      rethrow;
    } catch (e) {
      throw OpeninaryException('Upload failed: $e');
    }
  }

  /// Builds the delivery URL for a stored path.
  static String urlFor(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '$deliveryBase/t/$clean';
  }
}
