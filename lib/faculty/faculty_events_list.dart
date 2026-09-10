// lib/faculty/faculty_events_list.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import 'faculty_participants_list.dart';

class FacultyEventsListScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const FacultyEventsListScreen({super.key, required this.user});

  @override
  ConsumerState<FacultyEventsListScreen> createState() =>
      _FacultyEventsListScreenState();
}

class _FacultyEventsListScreenState
    extends ConsumerState<FacultyEventsListScreen> {
  EventCategory _selectedCategory = EventCategory.all;
  EventStatus? _selectedStatus;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchTimer;
  bool _searchNotEmpty = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(eventsProvider, (prev, next) {});
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (mounted && v.isEmpty != !_searchNotEmpty) {
        setState(() => _searchNotEmpty = v.isNotEmpty);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setFacultyFilter();
    });
  }

  void _setFacultyFilter() {
    final cur = ref.read(eventsFilterProvider);
    if (cur.coordinatorId != widget.user.id) {
      ref.read(eventsFilterProvider.notifier).state =
          cur.copyWith(coordinatorId: widget.user.id);
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref.read(eventsFilterProvider.notifier).state =
          ref.read(eventsFilterProvider).copyWith(search: v.trim());
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(eventsFilterProvider.notifier).state =
        ref.read(eventsFilterProvider).copyWith(search: '');
  }

  void _onCategoryChanged(EventCategory cat) {
    setState(() => _selectedCategory = cat);
    String? cid;
    if (cat != EventCategory.all) {
      cid = cat.name;
    }
    ref.read(eventsFilterProvider.notifier).state =
        ref.read(eventsFilterProvider).copyWith(categoryId: cid ?? '');
  }

  void _onStatusChanged(EventStatus? status) {
    setState(() => _selectedStatus = status);
    String? s;
    switch (status) {
      case EventStatus.upcoming:
        s = 'upcoming';
      case EventStatus.ongoing:
        s = 'ongoing';
      case EventStatus.completed:
        s = 'completed';
      default:
        s = null;
    }
    ref.read(eventsFilterProvider.notifier).state =
        ref.read(eventsFilterProvider).copyWith(status: s ?? '');
  }

  List<EventModel> _localFilter(List<EventModel> events) {
    // Backend already filters by coordinatorId/search/categoryId/status via provider.
    // Local category/status fallback (re-checks EventCategory enum + status for safety).
    return events.where((e) {
      final matchCat = _selectedCategory == EventCategory.all ||
          e.category == _selectedCategory;
      final matchStatus =
          _selectedStatus == null || e.status == _selectedStatus;
      return matchCat && matchStatus;
    }).toList();
  }

  Future<void> _refresh() async {
    ref.invalidate(eventsProvider);
    await ref.read(eventsProvider.future).catchError((_) => <EventModel>[]);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Events refreshed'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(eventsAsync),
            _buildSearchBar(),
            _buildCategoryFilter(),
            _buildStatusFilter(),
            Expanded(
              child: eventsAsync.when(
                loading: () => _buildLoading(),
                error: (e, st) => _buildError(e, () {
                  ref.invalidate(eventsProvider);
                }),
                data: (data) {
                  final events = _localFilter(data);
                  return _buildBody(events);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<List<EventModel>> eventsAsync) {
    var total = 0;
    if (eventsAsync.hasValue) {
      total = _localFilter(eventsAsync.value!).length;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              borderRadius: AppRadius.smRadius,
            ),
            child: const Icon(Icons.event_rounded,
                color: AppColors.primaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Events',
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.onSurface,
                  )),
              Text(
                eventsAsync.isLoading
                    ? 'Loading events...'
                    : '$total events',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
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
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          filled: true,
          fillColor: AppColors.canvasBackground,
          border: OutlineInputBorder(
              borderRadius: AppRadius.mdRadius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdRadius, borderSide: BorderSide.none),
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
              onTap: () => _onCategoryChanged(cat),
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
              onTap: () => _onStatusChanged(statuses[i]),
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

  Widget _buildLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );

  Widget _buildError(Object e, VoidCallback onRetry) {
    final msg = e.toString().replaceAll('Exception: ', '');
    final display =
        msg.length > 100 ? '${msg.substring(0, 100)}…' : msg;
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 64, color: AppColors.error.withValues(alpha: 0.7)),
                  const SizedBox(height: 16),
                  Text('Failed to load events',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  Text(display,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                      'Please check your internet connection or try again later.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, fontSize: 11)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdRadius)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<EventModel> events) {
    if (events.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_rounded,
                          size: 64,
                          color: AppColors.outline.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('No events found',
                          style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Text(
                          'Try adjusting your filters or pull down to refresh',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, i) => _FacultyEventCard(
          event: events[i],
          user: widget.user,
        ),
      ),
    );
  }
}

class _FacultyEventCard extends StatelessWidget {
  final EventModel event;
  final UserModel user;
  const _FacultyEventCard({required this.event, required this.user});

  @override
  Widget build(BuildContext context) {
    final pct = event.maxParticipants > 0
        ? event.currentParticipants / event.maxParticipants
        : 0.0;

    return Container(
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
                    if (event.status == EventStatus.ongoing)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.25),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('LIVE',
                                style: AppTypography.labelBold.copyWith(
                                    color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      )
                    else
                      _chip(event.status.label,
                          Colors.white.withValues(alpha: 0.25), Colors.white),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Text(_fmtDate(event.dateTime),
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Participants',
                                  style: AppTypography.labelBold.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 11)),
                              Text(
                                  '${event.currentParticipants}/${event.maxParticipants}',
                                  style: AppTypography.labelBold.copyWith(
                                      color: AppColors.onSurface, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: AppRadius.fullRadius,
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: AppColors.canvasBackground,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  event.accentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FacultyParticipantsListScreen(
                              user: user,
                              initialEvent: event,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_rounded, size: 16),
                      label: const Text('Participants'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.fullRadius,
                        ),
                        textStyle: AppTypography.labelBold.copyWith(fontSize: 12),
                      ),
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

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }
}
