import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import '../models/appointment.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    // Keep your existing API call logic here
    // Simulate loading for now
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _appointments = [
        Appointment(
          id: '1',
          resourceType: 'Appointment',
          status: 'booked',
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(hours: 1)),
          patientName: 'John Doe',
          doctorName: 'Dr. Smith',
          diagnosis: 'Appendicitis',
          participants: [],
          raw: {},
          createdAt: '2024-01-15',
        ),
        Appointment(
          id: '2',
          resourceType: 'Appointment',
          status: 'pending',
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          patientName: 'Jane Smith',
          doctorName: 'Dr. Johnson',
          participants: [],
          raw: {},
          createdAt: '2024-01-15',
        ),
      ];
      _loading = false;
    });
  }

  void _navigateToPatientDetail(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(appointment: appointment),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'booked':
        color = Colors.blue;
        text = 'Booked';
        break;
      case 'arrived':
        color = Colors.green;
        text = 'Arrived';
        break;
      case 'fulfilled':
        color = Colors.purple;
        text = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      case 'noshow':
        color = Colors.red;
        text = 'No Show';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
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
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () => _navigateToPatientDetail(appointment),
        ),
        onTap: () => _navigateToPatientDetail(appointment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(child: Text('No appointments found'))
              : ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(_appointments[index]);
                  },
                ),
    );
  }
}