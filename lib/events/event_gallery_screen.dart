// lib/events/event_gallery_screen.dart
import 'package:flutter/material.dart';

// ─── GALLERY ITEM MODEL ──────────────────────────────────────────────────────

class GalleryMemoryItem {
  final String id;
  final String title;
  final String year;
  final String category;
  final String imageUrl;
  final IconData bottomIcon;
  final bool isVideo;
  final String? badgeText;
  final String videoPlayStyle; // 'goldCircle' or 'translucentCircle'
  final double imageHeight;
  final List<Color> fallbackGradient;

  const GalleryMemoryItem({
    required this.id,
    required this.title,
    required this.year,
    required this.category,
    required this.imageUrl,
    required this.bottomIcon,
    this.isVideo = false,
    this.badgeText,
    this.videoPlayStyle = 'goldCircle',
    required this.imageHeight,
    required this.fallbackGradient,
  });
}

// ─── INITIAL MEMORY ITEMS DATA ──────────────────────────────────────────────

const List<GalleryMemoryItem> _initialLeftMemories = [
  GalleryMemoryItem(
    id: 'm1',
    title: 'Robotics Finals',
    year: '2023',
    category: 'Technical',
    badgeText: 'TECHNICAL',
    imageUrl:
        'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.collections_outlined,
    isVideo: false,
    imageHeight: 215,
    fallbackGradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
  ),
  GalleryMemoryItem(
    id: 'm3',
    title: 'Cultural Night Aftermovie',
    year: '2022',
    category: 'Cultural',
    badgeText: null,
    imageUrl:
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.local_movies_outlined,
    isVideo: true,
    videoPlayStyle: 'goldCircle',
    imageHeight: 145,
    fallbackGradient: [Color(0xFF3B0764), Color(0xFF6B21A8)],
  ),
  GalleryMemoryItem(
    id: 'm5',
    title: 'Annual Sports Gala',
    year: '2023',
    category: 'Sports',
    badgeText: null,
    imageUrl:
        'https://images.unsplash.com/photo-1531545514256-b1400bc00f31?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.emoji_events_outlined,
    isVideo: false,
    imageHeight: 220,
    fallbackGradient: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
  ),
];

const List<GalleryMemoryItem> _initialRightMemories = [
  GalleryMemoryItem(
    id: 'm2',
    title: 'AI Workshop Series',
    year: '2023',
    category: 'Technical',
    badgeText: null,
    imageUrl:
        'https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.lightbulb_outline,
    isVideo: false,
    imageHeight: 220,
    fallbackGradient: [Color(0xFF0F2B48), Color(0xFF1D4ED8)],
  ),
  GalleryMemoryItem(
    id: 'm4',
    title: 'Campus Spring Fest',
    year: '2022',
    category: 'Cultural',
    badgeText: null,
    imageUrl:
        'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.celebration_outlined,
    isVideo: false,
    imageHeight: 200,
    fallbackGradient: [Color(0xFF065F46), Color(0xFF047857)],
  ),
  GalleryMemoryItem(
    id: 'm6',
    title: 'Inter-Uni Basketball',
    year: '2023',
    category: 'Sports',
    badgeText: null,
    imageUrl:
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.videocam_outlined,
    isVideo: true,
    videoPlayStyle: 'translucentCircle',
    imageHeight: 140,
    fallbackGradient: [Color(0xFF7C2D12), Color(0xFFC2410C)],
  ),
];

const List<GalleryMemoryItem> _additionalMemories = [
  GalleryMemoryItem(
    id: 'm7',
    title: 'Hackathon Grand Finale',
    year: '2023',
    category: 'Technical',
    badgeText: 'HIGHLIGHT',
    imageUrl:
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.code_outlined,
    isVideo: false,
    imageHeight: 190,
    fallbackGradient: [Color(0xFF030712), Color(0xFF1F2937)],
  ),
  GalleryMemoryItem(
    id: 'm8',
    title: 'EDM Concert Night',
    year: '2023',
    category: 'Cultural',
    badgeText: null,
    imageUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=800&auto=format&fit=crop',
    bottomIcon: Icons.music_note_outlined,
    isVideo: true,
    videoPlayStyle: 'goldCircle',
    imageHeight: 210,
    fallbackGradient: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
  ),
];

// ─── EVENT GALLERY SCREEN ────────────────────────────────────────────────────

class EventGalleryScreen extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final int activeTab;

  const EventGalleryScreen({
    super.key,
    this.onTabSelected,
    this.activeTab = 3,
  });

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Technical', 'Cultural', 'Sports'];

  late List<GalleryMemoryItem> _leftItems;
  late List<GalleryMemoryItem> _rightItems;
  bool _isLoadingMore = false;
  bool _hasLoadedMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _leftItems = List.from(_initialLeftMemories);
    _rightItems = List.from(_initialRightMemories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMoreMemories() {
    if (_hasLoadedMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _leftItems.add(_additionalMemories[0]);
        _rightItems.add(_additionalMemories[1]);
        _isLoadingMore = false;
        _hasLoadedMore = true;
      });
    });
  }

  List<GalleryMemoryItem> _filterItems(List<GalleryMemoryItem> items) {
    return items.where((item) {
      final categoryMatch = _selectedCategoryIndex == 0 ||
          item.category.toLowerCase() ==
              _categories[_selectedCategoryIndex].toLowerCase();
      final queryMatch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.year.contains(_searchQuery);
      return categoryMatch && queryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeft = _filterItems(_leftItems);
    final filteredRight = _filterItems(_rightItems);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                      _buildCategoryChips(),
                      const SizedBox(height: 20),
                      _buildGallerySectionTitle(),
                      const SizedBox(height: 16),
                      _buildStaggeredGrid(filteredLeft, filteredRight),
                      const SizedBox(height: 24),
                      _buildLoadMoreButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HEADER BAR ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        // University Crest circular icon badge
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFFED65B),
                  size: 24,
                ),
                Icon(
                  Icons.school,
                  color: Colors.amber.shade200,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'EduEvents',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        // Notification bell circular button
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF0F172A),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ─── SEARCH BAR ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search memories...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8C9099),
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ─── CATEGORY FILTER CHIPS ──────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedCategoryIndex = index);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFD54F) // Vibrant warm yellow/gold
                        : const Color(0xFFEBECEF), // Light grey pill
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFF5A606C),
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── SECTION TITLE ROW ──────────────────────────────────────────────────────
  Widget _buildGallerySectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Event Gallery',
          style: TextStyle(
            color: Color(0xFF0A192F),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        Row(
          children: const [
            Icon(
              Icons.restore_rounded,
              color: Color(0xFFC58B17),
              size: 18,
            ),
            SizedBox(width: 4),
            Text(
              '2022-2023',
              style: TextStyle(
                color: Color(0xFFC58B17),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── MASONRY STAGGERED GRID ─────────────────────────────────────────────────
  Widget _buildStaggeredGrid(
      List<GalleryMemoryItem> leftList, List<GalleryMemoryItem> rightList) {
    if (leftList.isEmpty && rightList.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No memories found for this filter',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: leftList
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildGalleryCard(item),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 14),
        // Right Column
        Expanded(
          child: Column(
            children: rightList
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildGalleryCard(item),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ─── INDIVIDUAL GALLERY CARD ────────────────────────────────────────────────
  Widget _buildGalleryCard(GalleryMemoryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with overlays
          SizedBox(
            height: item.imageHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with fallbacks
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.fallbackGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          item.bottomIcon,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 44,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.fallbackGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),

                // Subtle dark gradient bottom overlay for contrast
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Optional Top-Left Badge (e.g. TECHNICAL)
                if (item.badgeText != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        item.badgeText!,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                // Video Play Overlay Button
                if (item.isVideo)
                  Center(
                    child: item.videoPlayStyle == 'goldCircle'
                        ? Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFD54F),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF0F172A),
                              size: 26,
                            ),
                          )
                        : Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.45),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                  ),
              ],
            ),
          ),

          // Card Body Description
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.year,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      item.bottomIcon,
                      size: 16,
                      color: const Color(0xFFD97706),
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

  // ─── LOAD MORE MEMORIES BUTTON ──────────────────────────────────────────────
  Widget _buildLoadMoreButton() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _loadMoreMemories,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF070E20), // Dark Navy
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF070E20).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingMore)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Text(
                      'LOAD MORE MEMORIES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── BOTTOM NAVIGATION BAR ──────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {
        'icon': Icons.calendar_today_outlined,
        'activeIcon': Icons.calendar_today,
        'label': 'Events'
      },
      {
        'icon': Icons.leaderboard_outlined,
        'activeIcon': Icons.leaderboard,
        'label': 'Rankings'
      },
      {
        'icon': Icons.photo_library_outlined,
        'activeIcon': Icons.photo_library,
        'label': 'Gallery'
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile'
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -3),
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: List.generate(navItems.length, (i) {
              final isSelected = widget.activeTab == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.onTabSelected != null) {
                      widget.onTabSelected!(i);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 16 : 0,
                            vertical: isSelected ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFD54F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isSelected
                                ? navItems[i]['activeIcon'] as IconData
                                : navItems[i]['icon'] as IconData,
                            size: 20,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          navItems[i]['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFD97706)
                                : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
