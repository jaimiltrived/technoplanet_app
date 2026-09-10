// lib/student/student_gallery.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_providers.dart';

class StudentGalleryScreen extends ConsumerStatefulWidget {
  const StudentGalleryScreen({super.key});

  @override
  ConsumerState<StudentGalleryScreen> createState() => _StudentGalleryScreenState();
}

class _StudentGalleryScreenState extends ConsumerState<StudentGalleryScreen> {
  String _selectedYear = 'All';

  List<String> _getYears(List<Map<String, dynamic>> items) {
    final ys = items
        .map((g) => g['year'] as String)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return ['All', ...ys];
  }

  List<Map<String, dynamic>> _getFiltered(List<Map<String, dynamic>> items) {
    if (_selectedYear == 'All') return items;
    return items
        .where((g) => g['year'] == _selectedYear)
        .toList();
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
            final filteredItems = _getFiltered(items);
            return Column(
              children: [
                _buildHeader(),
                _buildYearFilter(years),
                Expanded(child: _buildGalleryGrid(filteredItems)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(child: Text('Error loading gallery')),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          const Icon(Icons.photo_library_rounded,
              color: AppColors.primaryContainer, size: 24),
          const SizedBox(width: 10),
          Text('Gallery',
              style: AppTypography.headlineLgMobile.copyWith(
                  color: AppColors.onSurface)),
          const Spacer(),
          Text('Previous Events',
              style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildYearFilter(List<String> years) {
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: years.map((year) {
            final sel = _selectedYear == year;
            return GestureDetector(
              onTap: () => setState(() => _selectedYear = year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildGalleryGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _GalleryCard(item: items[i]),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _GalleryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item['color'] is Color ? item['color'] as Color : AppColors.primaryContainer;
    final eventTitle = item['eventTitle']?.toString() ?? 'Event';
    final caption = item['caption']?.toString() ?? '';
    final year = item['year']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Hero(
        tag: 'gallery_$eventTitle',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgRadius,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lgRadius,
            child: Stack(
              children: [
                // Background gradient (placeholder for real image)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.7),
                        color,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.photo_camera_rounded,
                        color: Colors.white.withValues(alpha: 0.3), size: 48),
                  ),
                ),
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -10,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (year.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppRadius.fullRadius,
                                ),
                                child: Text(year,
                                    style: AppTypography.labelBold.copyWith(
                                        color: Colors.white, fontSize: 10)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    final color = item['color'] as Color;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: AppRadius.lgRadius,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.7), color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.photo_camera_rounded,
                      color: Colors.white.withValues(alpha: 0.4), size: 80),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['eventTitle'] as String,
                      style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text(item['caption'] as String,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Year: ${item['year']}',
                      style: AppTypography.labelBold.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
