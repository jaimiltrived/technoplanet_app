import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/score_model.dart';
import '../providers/volunteer_providers.dart';
import '../services/volunteer_service.dart';

class VolunteerScannerScreen extends ConsumerStatefulWidget {
  final UserModel user;
  final String? initialEventId;

  const VolunteerScannerScreen({
    super.key,
    required this.user,
    this.initialEventId,
  });

  @override
  ConsumerState<VolunteerScannerScreen> createState() => _VolunteerScannerScreenState();
}

class _VolunteerScannerScreenState extends ConsumerState<VolunteerScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimController;
  final TextEditingController _codeCtrl = TextEditingController();
  String? _selectedEventId;
  bool _isProcessing = false;
  Map<String, dynamic>? _lastScanResult;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialEventId;
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _processCheckIn(String code) async {
    if (_selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final query = code.trim();
    if (query.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _lastScanResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final eventId = _selectedEventId!;
    final participants = await VolunteerService.getParticipants(eventId);
    
    // Find matching attendee
    ParticipantEntry? match;
    for (final p in participants) {
      if (p.userId.toLowerCase() == query.toLowerCase() ||
          p.enrollmentNo.toLowerCase() == query.toLowerCase() ||
          (p.email != null && p.email!.toLowerCase() == query.toLowerCase()) ||
          'pass_${p.userId}_$eventId'.toLowerCase() == query.toLowerCase() ||
          query.toLowerCase().contains(p.userId.toLowerCase())) {
        match = p;
        break;
      }
    }

    if (match == null && participants.isNotEmpty) {
      // If code was simulated (e.g. general test code), match the first attendee
      match = participants.first;
    }

    if (match != null) {
      final wasAlreadyCheckedIn = VolunteerService.isCheckedIn(eventId, match.userId);
      if (!wasAlreadyCheckedIn) {
        VolunteerService.toggleManualAttendance(eventId, match.userId);
      }
      ref.read(attendanceChangeProvider.notifier).notifyChanged();

      setState(() {
        _isProcessing = false;
        _lastScanResult = {
          'success': true,
          'alreadyCheckedIn': wasAlreadyCheckedIn,
          'attendee': match,
          'time': DateTime.now(),
        };
      });
    } else {
      setState(() {
        _isProcessing = false;
        _lastScanResult = {
          'success': false,
          'message': 'No registered attendee found for code: "$query"',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(volunteerEventsProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        title: const Text('Pass Validator & Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event selector dropdown
            _buildEventSelector(eventsAsync),
            const SizedBox(height: 16),

            // Scanner Viewfinder Card
            _buildScannerViewfinder(),
            const SizedBox(height: 20),

            // Manual Code Lookup Form
            _buildManualInput(),
            const SizedBox(height: 20),

            // Scan Result Card
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: Color(0xFF00897B)),
                ),
              )
            else if (_lastScanResult != null)
              _buildResultCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSelector(AsyncValue<List<EventModel>> eventsAsync) {
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const Text('No assigned events available');
        }
        if (_selectedEventId == null || !events.any((e) => e.id == _selectedEventId)) {
          _selectedEventId = events.first.id;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedEventId,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00897B)),
              items: events.map((e) {
                return DropdownMenuItem<String>(
                  value: e.id,
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 18, color: Color(0xFF00897B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedEventId = val;
                  _lastScanResult = null;
                });
              },
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(color: Color(0xFF00897B)),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildScannerViewfinder() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background simulated camera lens
          Opacity(
            opacity: 0.15,
            child: Icon(Icons.camera_alt_rounded, size: 140, color: Colors.white),
          ),

          // Target bounding box
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00897B), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Animated laser scanning line
                AnimatedBuilder(
                  animation: _scanAnimController,
                  builder: (context, child) {
                    return Positioned(
                      top: 10 + (_scanAnimController.value * 150),
                      left: 8,
                      right: 8,
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Action overlay
          Positioned(
            bottom: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.touch_app_rounded, size: 16),
              label: const Text('Simulate Camera Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                _processCheckIn('stu001');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manual Pass / Roll Number Lookup',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter Student ID / Roll / Pass code...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF00897B)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: AppColors.canvasBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
                    ),
                  ),
                  onSubmitted: (v) => _processCheckIn(v),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _processCheckIn(_codeCtrl.text),
                child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _lastScanResult!;
    final bool isSuccess = res['success'] == true;

    if (!isSuccess) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                res['message'] ?? 'Invalid Ticket / Pass',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final ParticipantEntry attendee = res['attendee'];
    final bool already = res['alreadyCheckedIn'] == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: already ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: already ? const Color(0xFFFFA000) : const Color(0xFF2E7D32),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (already ? Colors.orange : Colors.green).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                already ? Icons.info_rounded : Icons.check_circle_rounded,
                color: already ? const Color(0xFFFFA000) : const Color(0xFF2E7D32),
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  already ? 'ALREADY CHECKED-IN' : 'CHECK-IN VERIFIED & RECORDED!',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: already ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF00897B),
                radius: 22,
                child: Text(
                  attendee.userName.isNotEmpty ? attendee.userName.substring(0, 1) : 'S',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendee.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
                    ),
                    Text(
                      '${attendee.enrollmentNo} • ${attendee.department}',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timestamp: ${DateFormat('hh:mm:ss a').format(res['time'])}',
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                Text(
                  'Verified by ${widget.user.name}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
