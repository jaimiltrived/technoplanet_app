import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import 'volunteer_dashboard.dart';
import 'volunteer_events_list.dart';
import 'volunteer_scanner_screen.dart';
import 'volunteer_participants_screen.dart';
import 'volunteer_profile.dart';

class VolunteerHomeScreen extends StatefulWidget {
  final UserModel user;
  const VolunteerHomeScreen({super.key, required this.user});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  int _navIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      VolunteerDashboardScreen(
        user: widget.user,
        onNavigateTab: (index) => setState(() => _navIndex = index),
      ),
      VolunteerEventsListScreen(user: widget.user),
      VolunteerScannerScreen(user: widget.user),
      VolunteerParticipantsScreen(user: widget.user),
      VolunteerProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: AppColors.outline,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cardBackground,
      elevation: 12,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (i) => setState(() => _navIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event_rounded),
          label: 'My Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_outlined),
          activeIcon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Scan Pass',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline_rounded),
          activeIcon: Icon(Icons.people_rounded),
          label: 'Attendees',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.badge_outlined),
          activeIcon: Icon(Icons.badge_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
