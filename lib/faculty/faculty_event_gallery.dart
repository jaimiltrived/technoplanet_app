// lib/faculty/faculty_event_gallery.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/event_gallery_service.dart';
import '../services/api_service.dart';
import '../providers/event_gallery_providers.dart';

// ─── GALLERY PAGE ────────────────────────────────────────────────────────────

class FacultyEventGalleryScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final UserModel user;
  final bool isCoordinator;

  const FacultyEventGalleryScreen({
    super.key,
    required this.event,
    required this.user,
    this.isCoordinator = true,
  });

  @override
  ConsumerState<FacultyEventGalleryScreen> createState() =>
      _FacultyEventGalleryScreenState();
}

class _FacultyEventGalleryScreenState
    extends ConsumerState<FacultyEventGalleryScreen> {
  List<GalleryImageItem> _images = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  // Upload state
  final List<XFile> _selectedFiles = [];
  final _captionCtrl = TextEditingController();
  bool _showUploadSheet = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _loadMore();
    }
  }

  Future<void> _loadGallery() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await EventGalleryService.fetchEventGallery(
        widget.event.id,
        page: 1,
        limit: 30,
      );
      if (mounted) {
        setState(() {
          _images = result.images;
          _currentPage = result.pagination.page;
          _totalPages = result.pagination.totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await EventGalleryService.fetchEventGallery(
        widget.event.id,
        page: _currentPage + 1,
        limit: 30,
      );
      if (mounted) {
        setState(() {
          _images.addAll(result.images);
          _currentPage = result.pagination.page;
          _totalPages = result.pagination.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        limit: 20,
      );
      if (picked.isNotEmpty && mounted) {
        setState(() {
          // Limit to 20 total
          final remaining = 20 - _selectedFiles.length;
          _selectedFiles.addAll(picked.take(remaining));
          _showUploadSheet = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeSelectedFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      if (_selectedFiles.isEmpty) _showUploadSheet = false;
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedFiles.isEmpty || _isUploading) return;
    setState(() => _isUploading = true);
    try {
      final caption = _captionCtrl.text.trim();

      await EventGalleryService.uploadGalleryImages(
        widget.event.id,
        _selectedFiles,
        caption: caption.isNotEmpty ? caption : null,
      );

      if (mounted) {
        setState(() {
          _selectedFiles.clear();
          _captionCtrl.clear();
          _showUploadSheet = false;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photos uploaded successfully!'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        _loadGallery(); // Refresh
        ref.invalidate(eventGalleryProvider(widget.event.id));
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteImage(GalleryImageItem image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to delete this photo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await EventGalleryService.deleteGalleryImage(widget.event.id, image.id);
      if (mounted) {
        setState(() {
          _images.removeWhere((img) => img.id == image.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        ref.invalidate(eventGalleryProvider(widget.event.id));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _editCaption(GalleryImageItem image) async {
    final controller = TextEditingController(text: image.caption ?? '');
    final newCaption = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Caption'),
        content: TextField(
          controller: controller,
          maxLength: 1000,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a caption...',
            border: OutlineInputBorder(borderRadius: AppRadius.smRadius),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newCaption == null) return;

    try {
      await EventGalleryService.updateGalleryCaption(
        widget.event.id,
        image.id,
        newCaption.isEmpty ? null : newCaption,
      );
      if (mounted) {
        setState(() {
          final idx = _images.indexWhere((img) => img.id == image.id);
          if (idx != -1) {
            _images[idx] = GalleryImageItem(
              id: image.id,
              imageUrl: image.imageUrl,
              thumbnailUrl: image.thumbnailUrl,
              caption: newCaption.isEmpty ? null : newCaption,
              uploaderName: image.uploaderName,
              createdAt: image.createdAt,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Caption updated'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _openLightbox(int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _GalleryLightbox(
          images: _images,
          initialIndex: index,
          isCoordinator: widget.isCoordinator,
          onDelete: widget.isCoordinator ? _deleteImage : null,
          onEditCaption: widget.isCoordinator ? _editCaption : null,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Gallery',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(widget.event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (widget.isCoordinator)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 24),
              tooltip: 'Upload Photos',
              onPressed: _pickImages,
            ),
        ],
      ),
      body: Column(
        children: [
          // Upload preview sheet
          if (_showUploadSheet) _buildUploadSheet(),
          // Gallery content
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: widget.isCoordinator && !_showUploadSheet
          ? FloatingActionButton.extended(
              onPressed: _pickImages,
              backgroundColor: AppColors.primaryContainer,
              icon: const Icon(Icons.add_a_photo_rounded,
                  color: Colors.white, size: 20),
              label: Text('Upload Photos',
                  style: AppTypography.labelBold
                      .copyWith(color: Colors.white, fontSize: 13)),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingSkeleton();
    if (_error != null) return _buildError();
    if (_images.isEmpty) return _buildEmpty();
    return _buildGalleryGrid();
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.smRadius,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.outline.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Failed to load gallery',
                style: AppTypography.headlineMd
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadGallery,
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
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.photo_library_outlined,
                  size: 36, color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text('No photos yet',
                style: AppTypography.headlineMd
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              widget.isCoordinator
                  ? 'Tap the button below to upload event photos.'
                  : 'No photos have been added to this event yet.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return RefreshIndicator(
      onRefresh: _loadGallery,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: _images.length + (_isLoadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= _images.length) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: AppRadius.smRadius,
              ),
            );
          }
          return _GalleryTile(
            image: _images[index],
            isCoordinator: widget.isCoordinator,
            onTap: () => _openLightbox(index),
            onDelete: widget.isCoordinator ? () => _deleteImage(_images[index]) : null,
          );
        },
      ),
    );
  }

  Widget _buildUploadSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: 20, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Text('Upload Photos',
                    style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface, fontSize: 15)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => setState(() {
                    _selectedFiles.clear();
                    _showUploadSheet = false;
                  }),
                ),
              ],
            ),
          ),
          // Selected images preview
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _selectedFiles.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedFiles.length) {
                  // Add more button
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 74,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryContainer, width: 1.5),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              color: AppColors.primaryContainer, size: 24),
                          const SizedBox(height: 2),
                          Text('Add',
                              style: AppTypography.labelBold.copyWith(
                                  color: AppColors.primaryContainer,
                                  fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }
                return _SelectedFilePreview(
                  file: _selectedFiles[index],
                  onRemove: () => _removeSelectedFile(index),
                );
              },
            ),
          ),
          // Caption field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _captionCtrl,
              style: AppTypography.bodySm.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add a caption (optional)',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: AppColors.canvasBackground,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.smRadius,
                    borderSide: BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.smRadius,
                    borderSide: BorderSide(color: AppColors.cardBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.smRadius,
                    borderSide:
                        BorderSide(color: AppColors.primaryContainer, width: 1.5)),
              ),
            ),
          ),
          // Upload button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Text('${_selectedFiles.length} photo(s) selected',
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 12)),
                const Spacer(),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed:
                        _selectedFiles.isNotEmpty && !_isUploading
                            ? _uploadImages
                            : null,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload_rounded,
                            size: 18, color: Colors.white),
                    label: Text(
                        _isUploading ? 'Uploading...' : 'Upload',
                        style: AppTypography.labelBold
                            .copyWith(color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.fullRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GALLERY TILE ────────────────────────────────────────────────────────────

class _GalleryTile extends StatelessWidget {
  final GalleryImageItem image;
  final bool isCoordinator;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _GalleryTile({
    required this.image,
    required this.isCoordinator,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.smRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              image.thumbnailUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
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
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: Icon(Icons.broken_image_outlined,
                    size: 28,
                    color: AppColors.outline.withValues(alpha: 0.4)),
              ),
            ),
            // Caption indicator
            if (image.caption != null && image.caption!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    image.caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 9, height: 1.2),
                  ),
                ),
              ),
            // Delete button for coordinator
            if (isCoordinator && onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── SELECTED FILE PREVIEW ───────────────────────────────────────────────────

class _SelectedFilePreview extends StatefulWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _SelectedFilePreview({
    required this.file,
    required this.onRemove,
  });

  @override
  State<_SelectedFilePreview> createState() => _SelectedFilePreviewState();
}

class _SelectedFilePreviewState extends State<_SelectedFilePreview> {
  late final Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = widget.file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: AppRadius.smRadius,
            child: FutureBuilder<Uint8List>(
              future: _bytesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    width: 74,
                    height: 74,
                    fit: BoxFit.cover,
                  );
                }
                return Container(
                  width: 74,
                  height: 74,
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LIGHTBOX ────────────────────────────────────────────────────────────────

class _GalleryLightbox extends StatefulWidget {
  final List<GalleryImageItem> images;
  final int initialIndex;
  final bool isCoordinator;
  final Function(GalleryImageItem)? onDelete;
  final Function(GalleryImageItem)? onEditCaption;

  const _GalleryLightbox({
    required this.images,
    required this.initialIndex,
    this.isCoordinator = false,
    this.onDelete,
    this.onEditCaption,
  });

  @override
  State<_GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<_GalleryLightbox> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  GalleryImageItem get _currentImage => widget.images[_currentIndex];

  void _goToPage(int index) {
    if (index < 0 || index >= widget.images.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image page view
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    image.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            size: 48, color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text('Failed to load image',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  if (widget.isCoordinator) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 22),
                      tooltip: 'Edit Caption',
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEditCaption?.call(_currentImage);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade300, size: 22),
                      tooltip: 'Delete',
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete?.call(_currentImage);
                      },
                    ),
                  ] else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          // Bottom caption bar
          if (_currentImage.caption != null &&
              _currentImage.caption!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  _currentImage.caption!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Navigation arrows (for wider screens)
          if (MediaQuery.of(context).size.width > 500) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white, size: 28),
                    ),
                    onPressed: () => _goToPage(_currentIndex - 1),
                  ),
                ),
              ),
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right_rounded,
                          color: Colors.white, size: 28),
                    ),
                    onPressed: () => _goToPage(_currentIndex + 1),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
