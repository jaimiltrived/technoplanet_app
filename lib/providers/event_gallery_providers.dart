import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/event_gallery_service.dart';

/// Provider for fetching gallery images for a specific event.
/// Keyed by eventId — refetches when the eventId changes.
final eventGalleryProvider =
    FutureProvider.family<EventGalleryResult, String>((ref, eventId) async {
  return await EventGalleryService.fetchEventGallery(eventId);
});
