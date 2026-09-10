import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/user_model.dart';
import '../providers/faculty_providers.dart';
import '../providers/admin_providers.dart';

class FacultyAddCoordinatorScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const FacultyAddCoordinatorScreen({super.key, required this.user});

  @override
  ConsumerState<FacultyAddCoordinatorScreen> createState() =>
      _FacultyAddCoordinatorScreenState();
}

class _FacultyAddCoordinatorScreenState
    extends ConsumerState<FacultyAddCoordinatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserRole _selectedRole = UserRole.volunteer;
  String? _selectedEventId;
  final List<UserModel> _localVolunteers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('Manage Coordinators',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Current Volunteers'),
            Tab(text: 'Add Volunteer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentList(),
          _buildAddForm(context),
        ],
      ),
    );
  }

  Widget _buildCurrentList() {
    final volunteersAsync = ref.watch(adminVolunteersProvider);

    return volunteersAsync.when(
      data: (volunteers) {
        final all = [...volunteers, ..._localVolunteers];
        return ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            _sectionHeader('Volunteers (${all.length})'),
            ...all.map((v) => _PersonCard(person: v, readOnly: true)),
            const SizedBox(height: 80),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Volunteers (${_localVolunteers.length})'),
          ..._localVolunteers.map((v) => _PersonCard(person: v, readOnly: true)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _buildAddForm(BuildContext context) {
    final eventsAsync = ref.watch(facultyEventsProvider(widget.user.id));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: AppRadius.mdRadius,
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF2E7D32), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Volunteers will have read-only access to participant lists and schedules for the assigned event.',
                      style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF2E7D32), fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _label('Full Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDeco('Enter full name', Icons.person_outline_rounded),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _label('Institutional Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDeco('example@rku.ac.in', Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.trim().endsWith('@rku.ac.in')) return 'Must be @rku.ac.in email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _label('Assign to Event'),
            const SizedBox(height: 8),
            eventsAsync.when(
              data: (events) {
                if (_selectedEventId == null && events.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedEventId = events.first.id);
                  });
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedEventId,
                  decoration: _inputDeco('', Icons.event_rounded),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
                  items: events.map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.title, overflow: TextOverflow.ellipsis, style: AppTypography.bodySm))).toList(),
                  onChanged: (v) => setState(() => _selectedEventId = v),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading events: $e'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  elevation: 4,
                  shadowColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                ),
                icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                label: Text('Add ${_selectedRole.label}',
                    style: AppTypography.bodyLg.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedEventId != null) {
                    final newVolunteer = UserModel(
                      id: 'vol_${DateTime.now().millisecondsSinceEpoch}',
                      name: _nameCtrl.text.trim(),
                      email: _emailCtrl.text.trim(),
                      role: UserRole.volunteer,
                      department: 'General',
                      assignedEventIds: [_selectedEventId!],
                    );
                    
                    setState(() {
                      _localVolunteers.add(newVolunteer);
                    });

                    _nameCtrl.clear();
                    _emailCtrl.clear();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_selectedRole.label} added successfully!'),
                        backgroundColor: const Color(0xFF2E7D32),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _tabController.animateTo(0);
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: AppTypography.bodySm.copyWith(
          color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold));
          
  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
            borderRadius: AppRadius.smRadius,
            borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.smRadius,
            borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadius.smRadius,
            borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5)),
      );
}

class _PersonCard extends StatelessWidget {
  final UserModel person;
  final bool readOnly;
  const _PersonCard({required this.person, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: AppRadius.mdRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: person.role.accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(person.name.substring(0, 1),
                  style: AppTypography.headlineMd.copyWith(
                      color: person.role.accentColor, fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(person.email,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: person.role.badgeColor,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(person.role.label,
                    style: AppTypography.labelBold.copyWith(
                        color: person.role.accentColor, fontSize: 11)),
              ),
              if (readOnly) ...[
                const SizedBox(height: 6),
                Text('Read-only',
                    style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
