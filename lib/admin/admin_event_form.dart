// lib/admin/admin_event_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../models/event_model.dart';
import '../providers/admin_providers.dart';
import '../providers/event_providers.dart';
import '../services/admin_service.dart';

class AdminEventFormScreen extends ConsumerStatefulWidget {
  final EventModel? event;
  const AdminEventFormScreen({super.key, this.event});

  @override
  ConsumerState<AdminEventFormScreen> createState() => _AdminEventFormScreenState();
}

class _AdminEventFormScreenState extends ConsumerState<AdminEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _venueCtrl;
  late final TextEditingController _maxParticipantsCtrl;
  late final TextEditingController _feeCtrl;
  late final TextEditingController _minTeamSizeCtrl;
  late final TextEditingController _maxTeamSizeCtrl;
  
  String? _selectedCategoryId;
  String? _selectedCoordinatorId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDeadline;
  
  bool _isSaving = false;
  bool _isEdit = false;
  bool _isTeamEvent = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.event != null;
    
    _titleCtrl = TextEditingController(text: widget.event?.title ?? '');
    _descCtrl = TextEditingController(text: widget.event?.description ?? '');
    _venueCtrl = TextEditingController(text: widget.event?.location ?? '');
    _maxParticipantsCtrl = TextEditingController(
      text: widget.event != null ? widget.event!.maxParticipants.toString() : '100',
    );
    _feeCtrl = TextEditingController(
      text: widget.event != null ? widget.event!.registrationFee.toInt().toString() : '0',
    );
    _isTeamEvent = widget.event?.isTeamEvent ?? false;
    _minTeamSizeCtrl = TextEditingController(
      text: widget.event != null ? widget.event!.minTeamSize.toString() : '2',
    );
    _maxTeamSizeCtrl = TextEditingController(
      text: widget.event != null ? widget.event!.maxTeamSize.toString() : '4',
    );

    if (_isEdit) {
      _selectedDate = widget.event!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.dateTime);
      _selectedDeadline = widget.event!.registrationDeadline;
      _selectedCoordinatorId = widget.event!.coordinatorId;
      // categoryId will be matched after category list is fetched
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _feeCtrl.dispose();
    _minTeamSizeCtrl.dispose();
    _maxTeamSizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 305)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 305)),
      lastDate: _selectedDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_selectedCoordinatorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a faculty coordinator'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event date and time'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select registration deadline'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    // Format date & time
    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    
    final payload = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'categoryId': _selectedCategoryId,
      'coordinatorId': _selectedCoordinatorId,
      'date': eventDateTime.toIso8601String(),
      'time': timeStr,
      'venue': _venueCtrl.text.trim(),
      'maxParticipants': int.parse(_maxParticipantsCtrl.text.trim()),
      'registrationFee': double.parse(_feeCtrl.text.trim()),
      'registrationDeadline': _selectedDeadline!.toIso8601String(),
      'isTeamEvent': _isTeamEvent,
      'minTeamSize': _isTeamEvent ? int.parse(_minTeamSizeCtrl.text.trim()) : 1,
      'maxTeamSize': _isTeamEvent ? int.parse(_maxTeamSizeCtrl.text.trim()) : 1,
    };

    try {
      bool success;
      if (_isEdit) {
        success = await AdminService.updateEvent(widget.event!.id, payload);
      } else {
        success = await AdminService.createEvent(payload);
      }

      if (success) {
        // Invalidate providers to force refresh
        ref.invalidate(eventsProvider);
        ref.invalidate(allEventsProvider);
        ref.invalidate(adminEventsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEdit ? 'Event updated successfully' : 'Event created successfully'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Server returned failure status');
      }
    } catch (e, stack) {
      debugPrint('[AdminEventForm] Error saving event: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving event: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final facultyAsync = ref.watch(adminFacultyProvider);
    
    // Check if category is loaded and matches the widget's event category
    categoriesAsync.whenData((cats) {
      if (_selectedCategoryId == null && _isEdit && widget.event != null) {
        final categoryName = widget.event!.category.label.toLowerCase();
        final match = cats.firstWhere(
          (c) => c['name'].toString().toLowerCase() == categoryName || 
                 (categoryName.contains('tech') && c['name'].toString().toLowerCase().contains('tech')) ||
                 (categoryName.contains('sport') && c['name'].toString().toLowerCase().contains('sport')),
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          setState(() => _selectedCategoryId = match['id'].toString());
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: Text(_isEdit ? 'Edit Event' : 'Create Event',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading dependencies: $e')),
        data: (categories) => facultyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading faculty list: $e')),
          data: (facultyList) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
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
                            Text(
                              'Event Details',
                              style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            
                            // Title
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: _inputDecoration('Event Title', Icons.title_rounded),
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Title is required';
                                if (val.trim().length < 3) return 'Title must be at least 3 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Description
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 4,
                              decoration: _inputDecoration('Description', Icons.description_rounded),
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Description is required';
                                if (val.trim().length < 10) return 'Description must be at least 10 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategoryId,
                              decoration: _inputDecoration('Category', Icons.category_rounded),
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                              items: categories.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c['id'].toString(),
                                  child: Text(c['name'].toString()),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategoryId = val),
                              validator: (val) => val == null ? 'Category is required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Faculty Coordinator Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCoordinatorId,
                              decoration: _inputDecoration('Faculty Coordinator', Icons.person_rounded),
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                              items: facultyList.map((f) {
                                return DropdownMenuItem<String>(
                                  value: f.id,
                                  child: Text(f.name),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCoordinatorId = val),
                              validator: (val) => val == null ? 'Coordinator is required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date / Time / Location Container
                      Container(
                        padding: const EdgeInsets.all(16),
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
                            Text(
                              'Schedule & Location',
                              style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            
                            // Venue / Location
                            TextFormField(
                              controller: _venueCtrl,
                              decoration: _inputDecoration('Venue / Location', Icons.location_on_rounded),
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                              validator: (val) => (val == null || val.trim().isEmpty) ? 'Venue is required' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // Date picker row
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickDate,
                                    borderRadius: AppRadius.mdRadius,
                                    child: InputDecorator(
                                      decoration: _inputDecoration('Date', Icons.calendar_today_rounded),
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Select Date'
                                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                        style: AppTypography.bodySm.copyWith(
                                          color: _selectedDate == null ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickTime,
                                    borderRadius: AppRadius.mdRadius,
                                    child: InputDecorator(
                                      decoration: _inputDecoration('Time', Icons.access_time_rounded),
                                      child: Text(
                                        _selectedTime == null
                                            ? 'Select Time'
                                            : _selectedTime!.format(context),
                                        style: AppTypography.bodySm.copyWith(
                                          color: _selectedTime == null ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Event Format Container
                      Container(
                        padding: const EdgeInsets.all(16),
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
                            Text(
                              'Event Format',
                              style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            
                            // Switch for Solo / Team
                            Row(
                              children: [
                                const Icon(Icons.group_work_rounded, color: AppColors.onSurfaceVariant, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Team / Group Event',
                                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _isTeamEvent,
                                  activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                                  activeThumbColor: AppColors.primaryContainer,
                                  onChanged: (val) {
                                    setState(() {
                                      _isTeamEvent = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            if (_isTeamEvent) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _minTeamSizeCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration('Min Team Size', Icons.person_outline_rounded),
                                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                                      validator: (val) {
                                        if (!_isTeamEvent) return null;
                                        if (val == null || val.trim().isEmpty) return 'Required';
                                        final parsed = int.tryParse(val.trim());
                                        if (parsed == null || parsed < 2) return 'Min 2';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _maxTeamSizeCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration('Max Team Size', Icons.groups_rounded),
                                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                                      validator: (val) {
                                        if (!_isTeamEvent) return null;
                                        if (val == null || val.trim().isEmpty) return 'Required';
                                        final parsed = int.tryParse(val.trim());
                                        if (parsed == null || parsed > 4) return 'Max 4';
                                        
                                        final minVal = int.tryParse(_minTeamSizeCtrl.text.trim());
                                        if (minVal != null && parsed < minVal) {
                                          return 'Must be >= Min';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '* Maximum team size is limited to 4 members per group.',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Capacity & Pricing Container
                      Container(
                        padding: const EdgeInsets.all(16),
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
                            Text(
                              'Capacity & Fee',
                              style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _maxParticipantsCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration('Max Seats', Icons.groups_rounded),
                                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Required';
                                      final parsed = int.tryParse(val.trim());
                                      if (parsed == null || parsed < 1) return 'Min 1';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _feeCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration('Entry Fee (₹)', Icons.payments_rounded),
                                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Required';
                                      final parsed = double.tryParse(val.trim());
                                      if (parsed == null || parsed < 0) return 'Min 0';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Registration Deadline Picker
                            InkWell(
                              onTap: _pickDeadline,
                              borderRadius: AppRadius.mdRadius,
                              child: InputDecorator(
                                decoration: _inputDecoration('Registration Deadline', Icons.hourglass_bottom_rounded),
                                child: Text(
                                  _selectedDeadline == null
                                      ? 'Select Deadline Date'
                                      : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
                                  style: AppTypography.bodySm.copyWith(
                                    color: _selectedDeadline == null ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.outlineVariant,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isEdit ? 'Update Event' : 'Create Event',
                                  style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 14),
                                ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
      prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      filled: true,
      fillColor: AppColors.canvasBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
