import 'package:flutter/material.dart';
import '../models/appointment.dart';

class EditAppointmentDialog extends StatefulWidget {
  final Appointment appointment;
  final Function(Appointment, String, String)? onStatusUpdate;

  const EditAppointmentDialog({
    super.key,
    required this.appointment,
    this.onStatusUpdate,
  });

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  late String _selectedAction;
  String _notes = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Set initial action based on current status
    _selectedAction = _getInitialAction();
  }

  String _getInitialAction() {
    final status = widget.appointment.status.toLowerCase();
    if (status == 'pending' || status == 'proposed') {
      return 'confirm';
    } else if (status == 'booked') {
      return 'postpone';
    } else {
      return 'cancel';
    }
  }

  Future<void> _submitAction() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Map action to status
      final Map<String, String> statusMap = {
        'confirm': 'booked',
        'postpone': 'pending',
        'cancel': 'cancelled',
      };

      final newStatus = statusMap[_selectedAction] ?? widget.appointment.status;

      // Create updated appointment
      final updatedAppointment = Appointment(
        id: widget.appointment.id,
        resourceType: widget.appointment.resourceType,
        status: newStatus,
        start: widget.appointment.start,
        end: widget.appointment.end,
        patientName: widget.appointment.patientName,
        doctorName: widget.appointment.doctorName,
        diagnosis: widget.appointment.diagnosis,
        procedureCode: widget.appointment.procedureCode,
        participants: widget.appointment.participants,
        raw: {
          ...widget.appointment.raw,
          'status': newStatus,
          if (_notes.isNotEmpty) 'notes': _notes,
        },
        createdAt: widget.appointment.createdAt,
      );

      // Callback with updated appointment
      if (widget.onStatusUpdate != null) {
        widget.onStatusUpdate!(updatedAppointment, _selectedAction, _notes);
      }

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getActionDescription(String action) {
    switch (action) {
      case 'confirm':
        return 'Confirm this appointment. The patient will be notified.';
      case 'postpone':
        return 'Postpone this appointment to a later date.';
      case 'cancel':
        return 'Cancel this appointment. This action cannot be undone.';
      default:
        return '';
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'confirm':
        return Colors.green;
      case 'postpone':
        return Colors.orange;
      case 'cancel':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'confirm':
        return Icons.check_circle;
      case 'postpone':
        return Icons.calendar_today;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_calendar,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Appointment',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.appointment.patientName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Current Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(widget.appointment.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(widget.appointment.status)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              widget.appointment.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(widget.appointment.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Selection
              const Text(
                'Select Action',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Action Cards
              Column(
                children: ['confirm', 'postpone', 'cancel'].map((action) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAction = action;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedAction == action
                            ? _getActionColor(action).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAction == action
                              ? _getActionColor(action)
                              : Colors.grey.shade300,
                          width: _selectedAction == action ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getActionColor(action).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getActionIcon(action),
                              color: _getActionColor(action),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getActionColor(action),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getActionDescription(action),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedAction == action)
                            Icon(
                              Icons.check_circle,
                              color: _getActionColor(action),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Notes Section (Optional)
              const Text(
                'Add Notes (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes about this status change...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.shade400),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _notes = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.of(context).pop(false);
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionColor(_selectedAction),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedAction.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final Map<String, Color> statusColors = {
      'pending': Colors.orange,
      'proposed': Colors.orange,
      'booked': Colors.blue,
      'confirmed': Colors.green,
      'arrived': Colors.green,
      'fulfilled': Colors.purple,
      'cancelled': Colors.red,
      'noshow': Colors.red,
    };

    return statusColors[status.toLowerCase()] ?? Colors.grey;
  }
}