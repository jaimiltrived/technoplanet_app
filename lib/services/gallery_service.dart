import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_config.dart';
import 'api_service.dart';

class GalleryService {
  /// Fetches gallery photos from the live API.
  ///
  /// When [year] is provided the live API path `/api/gallery/{year}` is used
  /// (path parameter, not a query parameter — behaviour changed from local API).
  static Future<List<Map<String, dynamic>>> fetchGallery({int? year}) async {
    try {
      // Live API: GET /api/gallery/{year} when year is specified,
      //           GET /api/gallery            when fetching all.
      final url = year != null
          ? ApiConfig.galleryByYear(year)
          : ApiConfig.gallery;

      final res = await ApiService.get(url);
      final data = res['data'] ?? res;
      final List list = data is List
          ? data
          : (data is Map<String, dynamic>
              ? (data['photos'] ?? data['gallery'] ?? data['items'] ?? [])
              : []);

      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final yr = map['year']?.toString() ??
            year?.toString() ??
            DateTime.now().year.toString();
        final categoryRaw =
            (map['category'] ?? map['eventCategory'] ?? 'academic')
                .toString()
                .toLowerCase();

        Color color;
        if (categoryRaw.contains('tech')) {
          color = const Color(0xFF1565C0);
        } else if (categoryRaw.contains('sport') ||
            categoryRaw.contains('gaming')) {
          color = const Color(0xFF2E7D32);
        } else if (categoryRaw.contains('cultur')) {
          color = const Color(0xFF6A1B9A);
        } else if (categoryRaw.contains('art')) {
          color = const Color(0xFFE65100);
        } else {
          color = const Color(0xFF00838F);
        }

        // Build full image URL if the API returns a relative path.
        String? imageUrl = map['imageUrl']?.toString() ??
            map['url']?.toString() ??
            map['photo']?.toString();
        if (imageUrl != null &&
            imageUrl.isNotEmpty &&
            !imageUrl.startsWith('http')) {
          imageUrl = 'https://api.techno.rku.ac.in$imageUrl';
        }

        return {
          'year': yr,
          'eventTitle':
              map['eventTitle'] ?? map['title'] ?? map['name'] ?? 'Gallery',
          'category': categoryRaw,
          'caption': map['caption'] ?? map['description'] ?? '',
          'imageUrl': imageUrl,
          'color': color,
        };
      }).toList();
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[GalleryService] fetchGallery error: $err');
      }
      return [];
    }
  }
}
