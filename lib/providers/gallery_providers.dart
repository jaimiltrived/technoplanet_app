// lib/providers/gallery_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gallery_service.dart';

final galleryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await GalleryService.fetchGallery();
});
