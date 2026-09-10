// lib/events/events_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import 'event_detail_screen.dart';

class _EventData {
  final String id;
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String description;
  final List<Color> gradient;
  final Color badgeColor;
  final double rating;
  final int registered;
  final int maxParticipants;
  final String status;
  final Color statusColor;

  const _EventData({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.gradient,
    required this.badgeColor,
    required this.rating,
    required this.registered,
    required this.maxParticipants,
    required this.status,
    required this.statusColor,
  });

  factory _EventData.fromModel(EventModel model) {
    final Color baseColor = model.category.color;
    final gradient = [
      baseColor.withAlpha(230),
      baseColor,
      baseColor.withAlpha(180),
    ];

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dt = model.dateTime;
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '${hour.toString().padLeft(2, '0')}:$minute $amPm';

    String statusLabel;
    Color statusColor;
    if (model.status == EventStatus.ongoing) {
      statusLabel = 'LIVE';
      statusColor = const Color(0xFFEF4444);
    } else if (model.status == EventStatus.completed) {
      statusLabel = 'COMPLETED';
      statusColor = const Color(0xFF757575);
    } else if (model.currentParticipants >= model.maxParticipants) {
      statusLabel = 'FULL SOON';
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusLabel = 'OPEN';
      statusColor = const Color(0xFF22C55E);
    }

    return _EventData(
      id: model.id,
      title: model.title,
      category: model.category.name.toUpperCase(),
      date: dateStr,
      time: timeStr,
      location: model.location,
      description: model.description,
      gradient: gradient,
      badgeColor: baseColor,
      rating: 4.8,
      registered: model.currentParticipants,
      maxParticipants: model.maxParticipants,
      status: statusLabel,
      statusColor: statusColor,
    );
  }
}

class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  Timer? _searchTimer;
  bool _searchNotEmpty = false;

  final _filters = ['All', 'Tech', 'Sports', 'Cultural', 'Academic'];
  final _filterCategories = ['', 'TECH', 'SPORTS', 'CULTURAL', 'ACADEMIC'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchNotEmpty != _searchController.text.isNotEmpty) {
        setState(() => _searchNotEmpty = _searchController.text.isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      ref.read(eventsFilterProvider.notifier).state =
          ref.read(eventsFilterProvider).copyWith(search: value);
    });
  }

  Future<void> _onRefresh() async {
    ref.invalidate(eventsProvider);
    await ref.read(eventsProvider.future).catchError((_) => <EventModel>[]);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Events refreshed'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<_EventData> _getFilteredByCategory(List<EventModel> models) {
    final cat = _filterCategories[_selectedFilter];
    return models
        .map((m) => _EventData.fromModel(m))
        .where((e) => cat.isEmpty || e.category == cat)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (models) {
        final events = _getFilteredByCategory(models);
        return Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            _buildCountRow(events.length),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primaryContainer,
                child: events.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: events.length,
                        itemBuilder: (context, i) => _buildEventCard(events[i]),
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(err),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 30,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Failed to load events',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              err.toString().length > 80
                  ? 'Please check your connection and try again.'
                  : err.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(eventsProvider);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SEARCH BAR ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.canvasBackground,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Search events, places…',
            hintStyle: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
              fontSize: 13,
            ),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
            suffixIcon: _searchNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _searchTimer?.cancel();
                      ref.read(eventsFilterProvider.notifier).state =
                          ref.read(eventsFilterProvider).copyWith(search: '');
                    },
                    child: const Icon(Icons.close, size: 18, color: AppColors.outline),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ─── FILTER CHIPS ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            final selected = _selectedFilter == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryContainer : Colors.transparent,
                    borderRadius: AppRadius.fullRadius,
                    border: Border.all(
                      color: selected ? AppColors.primaryContainer : AppColors.cardBorder,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Text(
                    _filters[i],
                    style: AppTypography.labelBold.copyWith(
                      color: selected ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── COUNT ROW ─────────────────────────────────────────────────────────────

  Widget _buildCountRow(int count) {
    return Container(
      color: const Color(0xFFF5F6FA),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Text(
            '$count Event${count == 1 ? '' : 's'}',
            style: AppTypography.labelBold.copyWith(
              color: AppColors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.tune_outlined, size: 15, color: AppColors.primaryContainer),
              const SizedBox(width: 4),
              Text(
                'Filter',
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.primaryContainer,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── EVENT CARD ────────────────────────────────────────────────────────────

  Widget _buildEventCard(_EventData ev) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(
              eventTitle: ev.title,
              eventCategory: ev.category,
              eventDate: ev.date,
              eventTime: ev.time,
              eventLocation: ev.location,
              heroGradient: ev.gradient,
              badgeColor: ev.badgeColor,
              badgeLabel: ev.category,
              rating: ev.rating,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.mdRadius,
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: ev.gradient,
                        ),
                      ),
                      child: CustomPaint(painter: _CardPatternPainter(seed: ev.title.length)),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xBB000520)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: ev.statusColor,
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ev.status == 'LIVE') ...[
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              ev.status,
                              style: AppTypography.labelBold.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          ev.category,
                          style: AppTypography.labelBold.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ev.title,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.goldAccent),
                            const SizedBox(width: 3),
                            Text(
                              '${ev.rating}',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ev.description,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _infoChip(Icons.calendar_today_outlined, ev.date, AppColors.primaryContainer),
                        const SizedBox(width: 8),
                        _infoChip(Icons.access_time_outlined, ev.time.split('–').first.trim(), AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ev.location,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.08),
                            borderRadius: AppRadius.fullRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_outline, size: 12, color: AppColors.primaryContainer),
                              const SizedBox(width: 4),
                              Text(
                                '${ev.registered}/${ev.maxParticipants}',
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.primaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelBold.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_busy_outlined, size: 30, color: AppColors.primaryContainer),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No events found',
                    style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try a different filter or search term',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── PAINTER ──────────────────────────────────────────────────────────────────

class _CardPatternPainter extends CustomPainter {
  final int seed;
  const _CardPatternPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final x = ((i * (seed + 37)).toDouble()) % size.width;
      final y = ((i * 23.0) + seed) % size.height;
      canvas.drawCircle(Offset(x, y), 4 + (i % 4).toDouble() * 3, paint);
    }
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
