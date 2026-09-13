import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'api_config.dart';
import 'api_service.dart';

/// Gallery image data returned from the API.
class GalleryImageItem {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String? caption;
  final String? uploaderName;
  final DateTime createdAt;

  const GalleryImageItem({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.caption,
    this.uploaderName,
    required this.createdAt,
  });

  factory GalleryImageItem.fromJson(Map<String, dynamic> json) {
    return GalleryImageItem(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String?,
      uploaderName: (json['uploadedBy'] is Map)
          ? (json['uploadedBy'] as Map)['name'] as String?
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Pagination info from gallery API.
class GalleryPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const GalleryPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory GalleryPagination.fromJson(Map<String, dynamic> json) {
    return GalleryPagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 30,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

/// Result from fetching event gallery.
class EventGalleryResult {
  final String eventTitle;
  final List<GalleryImageItem> images;
  final GalleryPagination pagination;

  const EventGalleryResult({
    required this.eventTitle,
    required this.images,
    required this.pagination,
  });
}

class EventGalleryService {
  /// Fetch gallery images for an event (public).
  static Future<EventGalleryResult> fetchEventGallery(
    String eventId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final url = ApiConfig.eventGallery(eventId);
      final res = await ApiService.get(url, queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final data = res['data'] as Map<String, dynamic>? ?? {};
      final event = data['event'] as Map<String, dynamic>? ?? {};
      final imagesList = data['images'] as List? ?? [];
      final paginationMap = data['pagination'] as Map<String, dynamic>? ?? {};

      return EventGalleryResult(
        eventTitle: event['title'] as String? ?? 'Event Gallery',
        images: imagesList
            .map((item) => GalleryImageItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        pagination: GalleryPagination.fromJson(paginationMap),
      );
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[EventGalleryService] fetchEventGallery error: $err');
      }
      rethrow;
    }
  }

  /// Upload images to event gallery (faculty only). Uses MultipartFile.fromBytes for full Flutter Web and mobile compatibility.
  static Future<Map<String, dynamic>> uploadGalleryImages(
    String eventId,
    List<dynamic> files, {
    String? caption,
  }) async {
    try {
      final url = ApiConfig.facultyEventGalleryUpload(eventId);

      final formData = FormData();

      for (final item in files) {
        Uint8List bytes;
        String filename;

        if (item is XFile) {
          bytes = await item.readAsBytes();
          filename = item.name.isNotEmpty
              ? item.name
              : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        } else if (item is String) {
          final xf = XFile(item);
          bytes = await xf.readAsBytes();
          filename = xf.name.isNotEmpty
              ? xf.name
              : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        } else if (item is Uint8List) {
          bytes = item;
          filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        } else {
          continue;
        }

        // Determine image format for Multer validation
        final ext = filename.contains('.')
            ? filename.split('.').last.toLowerCase()
            : 'jpg';
        final subType = (ext == 'png' || ext == 'webp' || ext == 'gif')
            ? ext
            : 'jpeg';

        formData.files.add(MapEntry(
          'images',
          MultipartFile.fromBytes(
            bytes,
            filename: filename,
            contentType: DioMediaType('image', subType),
          ),
        ));
      }

      if (caption != null && caption.isNotEmpty) {
        formData.fields.add(MapEntry('caption', caption));
      }

      // Use Dio directly with auth token for multipart upload.
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 120),
      ));

      final token = ApiService.token;
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Upload failed';
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
      }
      throw ApiException(message, statusCode: e.response?.statusCode, responseData: data);
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[EventGalleryService] uploadGalleryImages error: $err');
      }
      rethrow;
    }
  }

  /// Delete a gallery image (faculty only).
  static Future<Map<String, dynamic>> deleteGalleryImage(
    String eventId,
    String imageId,
  ) async {
    final url = ApiConfig.facultyEventGalleryImage(eventId, imageId);
    return await ApiService.delete(url);
  }

  /// Update gallery image caption (faculty only).
  static Future<Map<String, dynamic>> updateGalleryCaption(
    String eventId,
    String imageId,
    String? caption,
  ) async {
    final url = ApiConfig.facultyEventGalleryImage(eventId, imageId);

    // Use Dio directly for PATCH since ApiService doesn't have a PATCH method.
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    final token = ApiService.token;
    final response = await dio.patch(
      url,
      data: {'caption': caption},
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {'success': true};
  }
}
