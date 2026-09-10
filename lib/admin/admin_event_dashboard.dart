// lib/admin/admin_event_dashboard.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import 'admin_event_detail.dart';
import 'admin_event_form.dart';

class AdminEventDashboardScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const AdminEventDashboardScreen({super.key, required this.user});

  @override
  ConsumerState<AdminEventDashboardScreen> createState() =>
      _AdminEventDashboardScreenState();
}

class _AdminEventDashboardScreenState
    extends ConsumerState<AdminEventDashboardScreen> {
  EventCategory _selectedCategory = EventCategory.all;
  EventStatus? _selectedStatus;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchTimer;
  bool _searchNotEmpty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Admin sees ALL events, so clear any coordinatorId filter
      final cur = ref.read(eventsFilterProvider);
      if (cur.coordinatorId.isNotEmpty || cur.search.isNotEmpty || cur.categoryId.isNotEmpty || cur.status.isNotEmpty) {
        ref.read(eventsFilterProvider.notifier).state = const EventsFilter();
        _selectedCategory = EventCategory.all;
        _selectedStatus = null;
        _searchCtrl.clear();
        _searchNotEmpty = false;
      }
    });
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (mounted && v.isEmpty != !_searchNotEmpty) {
        setState(() => _searchNotEmpty = v.isNotEmpty);
      }
    });
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
    if (cat != EventCategory.all) cid = cat.name;
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

  // Applies local EventCategory enum fallback + status fallback
  List<EventModel> _localFilter(List<EventModel> events) {
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
    ref.invalidate(allEventsProvider);
    await Future.wait([
      ref.read(eventsProvider.future).catchError((_) => <EventModel>[]),
      ref.read(allEventsProvider.future).catchError((_) => <EventModel>[]),
    ]);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Events refreshed'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(eventsProvider);
    final allAsync = ref.watch(allEventsProvider);
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            filteredAsync.maybeWhen(
              data: (data) => _buildHeader(_localFilter(data).length, allAsync),
              orElse: () => allAsync.maybeWhen(
                data: (_) => _buildHeader(0, allAsync),
                orElse: () => _buildHeader(0, allAsync),
              ),
            ),
            _buildSearchBar(),
            allAsync.when(
              data: (all) => _buildOverallStats(all),
              loading: () => _buildOverallStatsSkeleton(),
              error: (e, st) => _buildOverallStats([]),
            ),
            _buildCategoryFilter(),
            _buildStatusFilter(),
            Expanded(
              child: filteredAsync.when(
                loading: () => _buildLoading(),
                error: (e, st) => _buildError(e, () {
                  ref.invalidate(eventsProvider);
                  ref.invalidate(allEventsProvider);
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryContainer,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminEventFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(int filteredCount, AsyncValue<List<EventModel>> allAsync) {
    final total = allAsync.valueOrNull?.length ?? (allAsync.isLoading ? -1 : 0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
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
              Text('Events',
                  style: AppTypography.headlineLgMobile
                      .copyWith(color: AppColors.onSurface)),
              Text(
                total < 0
                    ? 'Loading events...'
                    : '$filteredCount of $total events',
                style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() => Container(
        color: AppColors.cardBackground,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                borderRadius: AppRadius.mdRadius,
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdRadius,
                borderSide: BorderSide.none),
          ),
        ),
      );

  // ─── Stats Strip ──────────────────────────────────────────────────────────
  Widget _buildOverallStats(List<EventModel> allEvents) {
    final total = allEvents.length;
    final upcoming = allEvents.where((e) => e.status == EventStatus.upcoming).length;
    final ongoing = allEvents.where((e) => e.status == EventStatus.ongoing).length;
    final completed = allEvents.where((e) => e.status == EventStatus.completed).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _statCard('$total', 'Total', AppColors.primaryContainer,
              Icons.event_rounded),
          const SizedBox(width: 8),
          _statCard('$upcoming', 'Upcoming', AppColors.primary,
              Icons.upcoming_rounded),
          const SizedBox(width: 8),
          _statCard('$ongoing', 'Ongoing', const Color(0xFF2E7D32),
              Icons.play_circle_outline_rounded),
          const SizedBox(width: 8),
          _statCard('$completed', 'Done', AppColors.outline,
              Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildOverallStatsSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == 3 ? 0 : 4),
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: AppRadius.mdRadius,
                ),
                child: const Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(val,
                  style: AppTypography.dataPoint
                      .copyWith(color: AppColors.onSurface, fontSize: 18)),
              Text(label,
                  style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 9)),
            ],
          ),
        ),
      );

  // ─── Category Filter ──────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return Container(
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: EventCategory.values.map((cat) {
            final sel = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => _onCategoryChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryContainer
                      : AppColors.canvasBackground,
                  border: Border.all(
                      color: sel
                          ? AppColors.primaryContainer
                          : AppColors.cardBorder),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon,
                        size: 14,
                        color: sel
                            ? Colors.white
                            : AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: AppTypography.labelBold.copyWith(
                          color: sel
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

  // ─── Status Filter ────────────────────────────────────────────────────────
  Widget _buildStatusFilter() {
    final statuses = [
      null,
      EventStatus.upcoming,
      EventStatus.ongoing,
      EventStatus.completed
    ];
    final labels = ['All', 'Upcoming', 'Ongoing', 'Completed'];
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.only(bottom: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          children: List.generate(statuses.length, (i) {
            final sel = _selectedStatus == statuses[i];
            final color = statuses[i]?.color ?? AppColors.onSurface;
            return GestureDetector(
              onTap: () => _onStatusChanged(statuses[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? color.withValues(alpha: 0.15) : Colors.transparent,
                  border: Border.all(
                      color: sel ? color : AppColors.cardBorder),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(labels[i],
                    style: AppTypography.labelBold.copyWith(
                      color: sel ? color : AppColors.onSurfaceVariant,
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
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth),
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
    });
  }

  // ─── Event List ───────────────────────────────────────────────────────────
  Widget _buildBody(List<EventModel> events) {
    if (events.isEmpty) {
      return LayoutBuilder(builder: (context, constraints) {
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
                        style: AppTypography.headlineMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text('Try adjusting your filters or pull down to refresh',
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, i) => _AdminEventCard(
          event: events[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminEventDetailScreen(event: events[i]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Event Card  (rich card like student view)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _AdminEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fillPct = event.maxParticipants > 0
        ? (event.currentParticipants / event.maxParticipants)
            .clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            // ── Gradient Header ──────────────────────────────────────────
            Container(
              height: 108,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.accentColor,
                    event.accentColor.withValues(alpha: 0.55),
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
                      _chip(event.category.label,
                          Colors.white.withValues(alpha: 0.25), Colors.white),
                      const Spacer(),
                      if (event.status == EventStatus.ongoing)
                        Container(
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
                                      color: Colors.white,
                                      shape: BoxShape.circle)),
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
                      if (event.ranksDeclared) ...[
                        const SizedBox(width: 6),
                        _chip('Results Out', AppColors.goldAccent,
                            AppColors.primaryContainer),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Text(event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                      )),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date / Venue row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Text(_fmt(event.dateTime),
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Fill progress bar
                  ClipRRect(
                    borderRadius: AppRadius.fullRadius,
                    child: LinearProgressIndicator(
                      value: fillPct,
                      minHeight: 5,
                      backgroundColor: AppColors.canvasBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          event.accentColor),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bottom row: fee · count · faculty
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
                                size: 12,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(event.coordinatorName!,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                )),
                          ],
                        )
                      else
                        Text('Unassigned',
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            )),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.onSurfaceVariant, size: 18),
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
        child: Text(label,
            style:
                AppTypography.labelBold.copyWith(color: fg, fontSize: 10)),
      );

  Widget _tagPill(String label, Color bg, Color fg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: AppRadius.fullRadius),
        child: Text(label,
            style:
                AppTypography.labelBold.copyWith(color: fg, fontSize: 11)),
      );

  String _fmt(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }
}
