// lib/student/student_events_list.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../providers/event_providers.dart';
import 'student_event_detail.dart';

class StudentEventsListScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const StudentEventsListScreen({super.key, required this.user});

  @override
  ConsumerState<StudentEventsListScreen> createState() =>
      _StudentEventsListScreenState();
}

class _StudentEventsListScreenState extends ConsumerState<StudentEventsListScreen> {
  EventCategory _selectedCategory = EventCategory.all;
  EventStatus? _selectedStatus;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchTimer;
  bool _searchNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (_searchNotEmpty != _searchCtrl.text.isNotEmpty) {
        setState(() => _searchNotEmpty = _searchCtrl.text.isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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

  List<EventModel> _getFilteredEvents(List<EventModel> allEvents) {
    return allEvents.where((e) {
      final matchCategory = _selectedCategory == EventCategory.all ||
          e.category == _selectedCategory;
      final matchStatus =
          _selectedStatus == null || e.status == _selectedStatus;
      return matchCategory && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: eventsAsync.when(
          data: (events) {
            final filtered = _getFilteredEvents(events);
            return Column(
              children: [
                _buildHeader(filtered),
                _buildSearchBar(),
                _buildCategoryFilter(),
                _buildStatusFilter(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primaryContainer,
                    child: _buildEventList(filtered),
                  ),
                ),
              ],
            );
          },
          loading: () => Column(
            children: [
              _buildHeader([]),
              _buildSearchBar(),
              _buildCategoryFilter(),
              _buildStatusFilter(),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (err, stack) => Column(
            children: [
              _buildHeader([]),
              _buildSearchBar(),
              _buildCategoryFilter(),
              _buildStatusFilter(),
              Expanded(child: _buildErrorState(err)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
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
                      err.toString().length > 100
                          ? 'Please check your internet connection or try again later.'
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
                        onPressed: () => ref.invalidate(eventsProvider),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(List<EventModel> filtered) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          Text('Events',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
              )),
          const Spacer(),
          Text('${filtered.length} events',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Search events, venues...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.onSurfaceVariant, size: 20),
          suffixIcon: _searchNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.onSurfaceVariant, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _searchTimer?.cancel();
                    ref.read(eventsFilterProvider.notifier).state =
                        ref.read(eventsFilterProvider).copyWith(search: '');
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          filled: true,
          fillColor: AppColors.canvasBackground,
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final cats = EventCategory.values;
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: cats.map((cat) {
            final selected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryContainer
                      : AppColors.canvasBackground,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryContainer
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon,
                        size: 14,
                        color: selected ? Colors.white : AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: AppTypography.labelBold.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [null, EventStatus.upcoming, EventStatus.ongoing, EventStatus.completed];
    final labels = ['All', 'Upcoming', 'Ongoing', 'Completed'];
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.only(bottom: 1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: List.generate(statuses.length, (i) {
            final selected = _selectedStatus == statuses[i];
            final color = statuses[i]?.color ?? AppColors.onSurface;
            return GestureDetector(
              onTap: () => setState(() => _selectedStatus = statuses[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: selected ? color : AppColors.cardBorder,
                  ),
                ),
                child: Text(labels[i],
                    style: AppTypography.labelBold.copyWith(
                      color: selected ? color : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    )),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
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
                    Icon(Icons.event_busy_rounded,
                        size: 64,
                        color: AppColors.outline.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text('No events found',
                        style: AppTypography.headlineMd.copyWith(
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                  
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: events.length,
      itemBuilder: (context, i) => _EventCard(
        event: events[i],
        isRegistered: widget.user.participatedEventIds.contains(events[i].id),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentEventDetailScreen(event: events[i]),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final bool isRegistered;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.isRegistered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: AppRadius.lgRadius,
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
            // Header with gradient
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.accentColor,
                    event.accentColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _chip(event.category.label, Colors.white.withValues(alpha: 0.25), Colors.white),
                      const Spacer(),
                      _chip(event.status.label,
                          Colors.white.withValues(alpha: 0.25), Colors.white),
                      if (isRegistered) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent,
                            borderRadius: AppRadius.fullRadius,
                          ),
                          child: Text('Registered',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.primaryContainer,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Text(event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      )),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.location_on_outlined, event.location),
                  const SizedBox(height: 4),
                  _infoRow(Icons.schedule_rounded,
                      '${_fmt(event.dateTime)} · ${event.location}'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _tagPill(
                        event.registrationFee == 0
                            ? 'Free'
                            : '₹${event.registrationFee.toInt()}',
                        AppColors.goldAccent,
                        AppColors.primaryContainer,
                      ),
                      const SizedBox(width: 8),
                      _tagPill(
                        '${event.currentParticipants}/${event.maxParticipants}',
                        AppColors.canvasBackground,
                        AppColors.onSurfaceVariant,
                      ),
                      const Spacer(),
                      if (event.coordinatorName != null)
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 13,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(event.coordinatorName!,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                )),
                          ],
                        ),
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

  Widget _chip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.fullRadius,
        ),
        child:
            Text(label, style: AppTypography.labelBold.copyWith(color: fg, fontSize: 10)),
      );

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      );

  Widget _tagPill(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: AppRadius.fullRadius),
        child: Text(label,
            style: AppTypography.labelBold.copyWith(color: fg, fontSize: 11)),
      );

  String _fmt(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }
}
