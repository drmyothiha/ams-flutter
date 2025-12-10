import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'patient_detail_screen.dart';
import '../models/appointment.dart';
import 'medical_history_screen.dart';
import '../widgets/edit_appointment_dialog.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Appointment> _appointments = [];
  bool _loading = true;
  String _filter = 'all';
  String? _error;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<http.Client> _getHttpClient() async {
    final HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return http.Client();
  }

  Future<void> _loadAppointments() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final client = await _getHttpClient();

      final response = await client.get(
        Uri.parse('http://192.168.100.8/api/appointments').replace(
          queryParameters: {
            'page': _currentPage.toString(),
            'limit': _itemsPerPage.toString(),
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final appointmentsData = data['data'] as List?;
          List<Appointment> loadedAppointments = [];

          if (appointmentsData != null) {
            loadedAppointments = appointmentsData
                .where((item) => item is Map<String, dynamic>)
                .map<Appointment>((item) => Appointment.fromJson(item))
                .toList();
          }

          final pagination = data['pagination'] as Map<String, dynamic>?;

          if (mounted) {
            setState(() {
              _appointments = loadedAppointments;
              _loading = false;

              if (pagination != null) {
                _currentPage = pagination['currentPage'] as int? ?? 1;
                _totalPages = pagination['totalPages'] as int? ?? 1;
                _totalItems = pagination['totalItems'] as int? ?? 0;
                _hasNextPage = pagination['hasNextPage'] as bool? ?? false;
                _hasPreviousPage =
                    pagination['hasPreviousPage'] as bool? ?? false;
              }
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error = data['message'] ?? 'Failed to load appointments';
              _loading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server error: ${response.statusCode}';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load appointments: $e';
          _loading = false;
        });
      }
      print('Error: $e');
    }
  }

  void _navigateToMedicalHistory(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalHistoryScreen(appointment: appointment),
      ),
    );
  }

  void _navigateToPatientDetail(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(appointment: appointment),
      ),
    );
  }

  void _handleEditAppointment(Appointment appointment) async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(
        appointment: appointment,
        onStatusUpdate: _updateAppointmentStatus,
      ),
    );

    if (result == true) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment ${appointment.id} updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateAppointmentStatus(
    Appointment updatedAppointment,
    String action,
    String notes,
  ) {
    // Update local state
    setState(() {
      final index = _appointments.indexWhere(
        (appt) => appt.id == updatedAppointment.id,
      );
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
    });

    // TODO: Call your API here
    print('Updating appointment ${updatedAppointment.id}:');
    print('  Action: $action');
    print('  New Status: ${updatedAppointment.status}');
    print('  Notes: $notes');

    // Example API call structure:
    // _callUpdateApi(updatedAppointment.id, action, notes);
  }

  Future<void> _callUpdateApi(
    String appointmentId,
    String action,
    String notes,
  ) async {
    try {
      final client = await _getHttpClient();
      final response = await client.post(
        Uri.parse(
          'http://192.168.100.8/api/appointments/$appointmentId/update',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'action': action,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('API update successful');
      }
    } catch (e) {
      print('API update error: $e');
    }
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Map<String, dynamic>> statusMap = {
      'pending': {'color': Colors.orange, 'text': 'Pending'},
      'booked': {'color': Colors.blue, 'text': 'Booked'},
      'arrived': {'color': Colors.green, 'text': 'Arrived'},
      'fulfilled': {'color': Colors.purple, 'text': 'Completed'},
      'cancelled': {'color': Colors.red, 'text': 'Cancelled'},
      'noshow': {'color': Colors.red, 'text': 'No Show'},
    };

    final badgeInfo =
        statusMap[status.toLowerCase()] ??
        {'color': Colors.grey, 'text': status};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (badgeInfo['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (badgeInfo['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Text(
        badgeInfo['text'] as String,
        style: TextStyle(
          color: badgeInfo['color'] as Color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    if (_filter == 'all') return _appointments;

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _appointments.where((appointment) {
      final appointmentDate = appointment.start;
      final startOfAppointmentDate = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );

      switch (_filter) {
        case 'today':
          return startOfAppointmentDate.isAtSameMomentAs(startOfToday);
        case 'upcoming':
          return startOfAppointmentDate.isAfter(startOfToday);
        case 'past':
          return startOfAppointmentDate.isBefore(startOfToday);
        default:
          return true;
      }
    }).toList();
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Appointment ID', appointment.id),
              _buildDetailRow('Patient', appointment.patientName),
              _buildDetailRow('Doctor', appointment.doctorName),
              _buildDetailRow(
                'Date',
                '${appointment.start.toLocal().toString().split(' ')[0]}',
              ),
              _buildDetailRow(
                'Time',
                '${appointment.start.toLocal().toString().split(' ')[1].substring(0, 5)} - '
                    '${appointment.end.toLocal().toString().split(' ')[1].substring(0, 5)}',
              ),
              _buildDetailRow('Status', appointment.status),
              if (appointment.diagnosis != null)
                _buildDetailRow('Diagnosis', appointment.diagnosis!),
              if (appointment.procedureCode != null)
                _buildDetailRow('Procedure Code', appointment.procedureCode!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _filterAppointments(String filterType) {
    setState(() {
      _filter = filterType;
      _currentPage = 1;
    });
    _loadAppointments();
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final startDate = appointment.start.toLocal();
    final endDate = appointment.end.toLocal();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToPatientDetail(appointment),
                    child: Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.doctorName,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildStatusBadge(appointment.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${startDate.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${startDate.toString().split(' ')[1].substring(0, 5)} - '
                  '${endDate.toString().split(' ')[1].substring(0, 5)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (appointment.diagnosis != null) ...[
              const SizedBox(height: 8),
              Text(
                appointment.diagnosis!,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showAppointmentDetails(appointment);
                break;
              case 'medical_history':
                _navigateToMedicalHistory(appointment);
                break;
              case 'patient_detail':
                _navigateToPatientDetail(appointment);
                break;
              case 'edit':
                _handleEditAppointment(appointment);
                break;
              case 'cancel':
                _showCancelConfirmation(appointment);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'medical_history',
              child: Row(
                children: [
                  Icon(Icons.medical_services, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Medical History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'patient_detail',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Patient Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 20),
                  SizedBox(width: 8),
                  Text('Cancel'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToPatientDetail(appointment),
      ),
    );
  }

  void _showCancelConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancellation API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cancelling appointment ${appointment.id}'),
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => _filterAppointments(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();
    final startItem = ((_currentPage - 1) * _itemsPerPage) + 1;
    final endItem = (_currentPage * _itemsPerPage).clamp(0, _totalItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Today', 'today'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Upcoming', 'upcoming'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Past', 'past'),
                ],
              ),
            ),
          ),

          // Appointments List
          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading appointments...'),
                      ],
                    ),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAppointments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _appointments.isEmpty
                              ? 'No appointments found.'
                              : 'No ${_filter} appointments found.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your filter or create a new appointment.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(filteredAppointments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
