// lib/student/student_gallery.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../providers/gallery_providers.dart';

String _normalizeImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  String u = url.trim();
  
  if (u.contains('wsrv.nl') && u.contains('catbox.moe')) {
    try {
      final uri = Uri.tryParse(u);
      if (uri != null && uri.queryParameters.containsKey('url')) {
        u = Uri.decodeComponent(uri.queryParameters['url']!);
      }
    } catch (_) {}
  }
  
  return u;
}

class StudentGalleryScreen extends ConsumerStatefulWidget {
  const StudentGalleryScreen({super.key});

  @override
  ConsumerState<StudentGalleryScreen> createState() => _StudentGalleryScreenState();
}

class _StudentGalleryScreenState extends ConsumerState<StudentGalleryScreen> {
  String _selectedYear = 'All';
  String _selectedCategory = 'All';

  List<String> _getYears(List<Map<String, dynamic>> items) {
    final ys = items
        .map((g) => g['year']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return ['All', ...ys];
  }

  List<String> _getCategories(List<Map<String, dynamic>> items) {
    final cats = items
        .map((g) => g['category']?.toString() ?? 'General')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...cats];
  }

  List<Map<String, dynamic>> _getFiltered(List<Map<String, dynamic>> items) {
    return items.where((g) {
      final yearMatch = _selectedYear == 'All' || g['year']?.toString() == _selectedYear;
      final catMatch = _selectedCategory == 'All' ||
          (g['category']?.toString().toLowerCase() == _selectedCategory.toLowerCase());
      return yearMatch && catMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(galleryProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: galleryAsync.when(
          data: (items) {
            final years = _getYears(items);
            final categories = _getCategories(items);
            final filteredItems = _getFiltered(items);

            return Column(
              children: [
                _buildHeader(items.length),
                if (years.length > 1) _buildYearFilter(years),
                if (categories.length > 1) _buildCategoryFilter(categories),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(galleryProvider);
                    },
                    child: filteredItems.isEmpty
                        ? _buildEmptyState()
                        : _buildGalleryGrid(filteredItems),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text('Failed to load gallery',
                      style: AppTypography.headlineMd
                          .copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 6),
                  Text('$err',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(galleryProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: AppRadius.smRadius,
            ),
            child: const Icon(Icons.photo_library_rounded,
                color: AppColors.primaryContainer, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Gallery',
                  style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.onSurface, fontWeight: FontWeight.bold)),
              Text('Memories & Moments ($totalCount photos)',
                  style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.onSurfaceVariant, size: 22),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(galleryProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter(List<String> years) {
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(
          children: years.map((year) {
            final sel = _selectedYear == year;
            return GestureDetector(
              onTap: () => setState(() => _selectedYear = year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryContainer : AppColors.canvasBackground,
                  border: Border.all(
                    color: sel ? AppColors.primaryContainer : AppColors.cardBorder,
                  ),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(year,
                    style: AppTypography.labelBold.copyWith(
                      color: sel ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          children: categories.map((cat) {
            final sel = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: sel ? AppColors.secondary : AppColors.surfaceContainerHigh,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(cat,
                    style: TextStyle(
                      color: sel ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_outlined,
                    size: 36, color: AppColors.outline),
              ),
              const SizedBox(height: 16),
              Text('No gallery photos found',
                  style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: 6),
              Text('Photos uploaded by faculty for events will appear here.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(galleryProvider),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _GalleryCard(
        item: items[i],
        onTap: () => _showFullscreen(context, items[i]),
      ),
    );
  }

  void _showFullscreen(BuildContext context, Map<String, dynamic> item) {
    final imageUrl = _normalizeImageUrl(item['imageUrl']?.toString());
    final eventTitle = item['eventTitle']?.toString() ?? 'Event Gallery';
    final caption = item['caption']?.toString() ?? item['description']?.toString() ?? '';
    final year = item['year']?.toString() ?? '';
    final category = item['category']?.toString() ?? 'General';
    final uploader = item['uploadedBy']?.toString();

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button top right
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Image with interactive viewer
            ClipRRect(
              borderRadius: AppRadius.lgRadius,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                  maxWidth: double.infinity,
                ),
                color: Colors.black,
                child: imageUrl.isNotEmpty
                    ? InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 3.5,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 250,
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            color: const Color(0xFF1E293B),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_rounded, color: Colors.white60, size: 48),
                                  SizedBox(height: 8),
                                  Text('Unable to load photo',
                                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 250,
                        color: AppColors.primaryContainer,
                        child: const Center(
                          child: Icon(Icons.photo_rounded, color: Colors.white, size: 64),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Caption & event metadata card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(eventTitle,
                            style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      if (year.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.12),
                            borderRadius: AppRadius.fullRadius,
                          ),
                          child: Text(year,
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.primaryContainer,
                                fontSize: 11,
                              )),
                        ),
                    ],
                  ),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(caption,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.4,
                        )),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: AppRadius.smRadius,
                        ),
                        child: Text(category,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      if (uploader != null && uploader.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text('By $uploader',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                              fontSize: 11,
                            )),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _GalleryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = item['color'] is Color ? item['color'] as Color : AppColors.primaryContainer;
    final eventTitle = item['eventTitle']?.toString() ?? 'Event';
    final caption = item['caption']?.toString() ?? item['description']?.toString() ?? '';
    final year = item['year']?.toString() ?? '';
    final rawUrl = item['imageUrl']?.toString() ?? item['url']?.toString();
    final imageUrl = _normalizeImageUrl(rawUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgRadius,
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.lgRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image display or fallback gradient
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [color.withValues(alpha: 0.7), color],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.photo_camera_rounded,
                          color: Colors.white.withValues(alpha: 0.4), size: 40),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.photo_camera_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 40),
                  ),
                ),

              // Subtle gradient overlay at top for year tag contrast
              if (year.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(year,
                        style: AppTypography.labelBold.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        )),
                  ),
                ),

              // Content overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(eventTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          )),
                      if (caption.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.white70,
                              fontSize: 10,
                            )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
