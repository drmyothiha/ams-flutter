import 'package:ams/screens/medical_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/appointment.dart';

class PatientDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const PatientDetailScreen({super.key, required this.appointment});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _apiData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);

    // Check if we already have the raw data from the appointment
    if (widget.appointment.raw.isNotEmpty) {
      // Use the raw data we already have from the list API
      setState(() {
        _apiData = widget.appointment.raw;
        _loading = false;
      });
    } else {
      // If no raw data, try to fetch it
      _loadPatientData();
    }
  }
  // when user want to see the medical history
  void _navigateToMedicalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalHistoryScreen(appointment: widget.appointment),
      ),
    );
  }
  Future<void> _loadPatientData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = await _getHttpClient();

      // Try different possible API endpoints
      final response = await client.get(
        Uri.parse(
          'http://192.168.100.8/api/appointments/${widget.appointment.id}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check different response formats
        if (data.containsKey('id')) {
          // Direct appointment object
          setState(() {
            _apiData = data;
            _loading = false;
          });
        } else if (data['success'] == true) {
          // Success wrapper format
          final responseData = data['data'] as Map<String, dynamic>?;
          if (responseData != null) {
            setState(() {
              _apiData = responseData;
              _loading = false;
            });
          } else {
            setState(() {
              _error = 'No data found in response';
              _loading = false;
            });
          }
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load patient data';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load patient data: $e';
        _loading = false;
      });
      print('Error loading patient data: $e');
    }
  }

  Future<http.Client> _getHttpClient() async {
    final HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return http.Client();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment.patientName),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Preop'),
            Tab(text: 'Intraop'),
            Tab(text: 'Recovery'),
            Tab(text: 'Investigations'),
            Tab(text: 'Radio'),
            Tab(text: 'Procedures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildPreopTab(),
          _buildIntraopTab(),
          _buildRecoveryTab(),
          _buildInvestigationsTab(),
          _buildRadioTab(),
          _buildProceduresTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatientData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

     // Use either the API data or the appointment data we already have
    final data = _apiData ?? widget.appointment.raw;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clickable Patient Information Box - NOW NAVIGATES TO MEDICAL HISTORY
          GestureDetector(
            onTap: _navigateToMedicalHistory,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PATIENT INFORMATION',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.appointment.patientName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    'View Medical History',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildPatientInfoItem(
                              Icons.badge,
                              'Patient ID',
                              _extractPatientId(data),
                            ),
                            _buildPatientInfoItem(
                              Icons.medical_services,
                              'Diagnosis',
                              widget.appointment.diagnosis ?? 'Not specified',
                            ),
                            _buildPatientInfoItem(
                              Icons.code,
                              'Procedure',
                              widget.appointment.procedureCode ?? 'N/A',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Colors.blueGrey),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Click here to view complete medical history, examination reports, lab results, and imaging studies.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Appointment Information
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Appointment Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Appointment ID', widget.appointment.id),
                  _buildInfoRow('Resource Type', widget.appointment.resourceType),
                  _buildStatusRow('Status', widget.appointment.status),
                  _buildInfoRow('Start', _formatDateTime(widget.appointment.start)),
                  _buildInfoRow('End', _formatDateTime(widget.appointment.end)),
                  _buildInfoRow('Duration', '${_calculateDuration(widget.appointment.start, widget.appointment.end)} minutes'),
                  if (widget.appointment.createdAt.isNotEmpty)
                    _buildInfoRow('Created', widget.appointment.createdAt),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Doctor Information
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Doctor Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Doctor Name', widget.appointment.doctorName),
                  _buildInfoRow('Doctor ID', _extractDoctorId(data)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location Information
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Location Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Location', _extractLocation(data)),
                  _buildInfoRow('Room', _extractRoomNumber(data)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Medical Details from Raw Data
          if (data.isNotEmpty) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Medical Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMedicalDetailsCardContent(data),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Participants Section
          if (widget.appointment.participants.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.group,
                            color: Colors.teal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ..._buildParticipantsList(widget.appointment.participants),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // New helper method for patient info items
  Widget _buildPatientInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Updated medical details to be a simpler card content
  Widget _buildMedicalDetailsCardContent(Map<String, dynamic> data) {
    final rawData = data['raw'] as Map<String, dynamic>? ?? data;
    final serviceType = rawData['serviceType'] as List?;
    final reasonCode = rawData['reasonCode'] as List?;
    final comment = rawData['comment'] as String?;
    final priority = rawData['priority'] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (serviceType != null && serviceType.isNotEmpty)
          _buildMedicalDetailItem('Service Type', serviceType.first['text']),
        
        if (reasonCode != null && reasonCode.isNotEmpty)
          _buildMedicalDetailItem('Reason', reasonCode.first['text']),
        
        if (comment != null && comment.isNotEmpty)
          _buildMedicalDetailItem('Comment', comment),
        
        if (priority != null)
          _buildMedicalDetailItem('Priority', 'Level $priority'),
      ],
    );
  }

  Widget _buildMedicalDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticipantsList(List<dynamic> participants) {
    return participants.map((participant) {
      if (participant is Map<String, dynamic>) {
        final actor = participant['actor'] as Map<String, dynamic>?;
        final status = participant['status'] as String?;
        
        final display = actor?['display'] as String?;
        final reference = actor?['reference'] as String?;
        
        // Determine participant type
        String type = 'Unknown';
        Color typeColor = Colors.grey;
        if (reference?.contains('Patient') == true) {
          type = 'Patient';
          typeColor = Colors.blue;
        }
        if (reference?.contains('Practitioner') == true) {
          type = 'Doctor';
          typeColor = Colors.green;
        }
        if (reference?.contains('Location') == true) {
          type = 'Location';
          typeColor = Colors.orange;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (reference != null)
                      Text(
                        reference,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'accepted'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'accepted' ? Colors.green : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
      return const SizedBox();
    }).toList();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    final Map<String, Color> statusColors = {
      'booked': Colors.green,
      'pending': Colors.orange,
      'arrived': Colors.blue,
      'fulfilled': Colors.purple,
      'cancelled': Colors.red,
      'noshow': Colors.red,
    };

    final color = statusColors[value.toLowerCase()] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Helper methods
  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.day}/${localTime.month}/${localTime.year} ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  String _extractPatientId(Map<String, dynamic> data) {
    try {
      final rawData = data['raw'] as Map<String, dynamic>? ?? data;
      final participants =
          rawData['participant'] as List? ?? widget.appointment.participants;

      if (participants != null) {
        for (var participant in participants) {
          if (participant is Map<String, dynamic>) {
            final actor = participant['actor'] as Map<String, dynamic>?;
            final reference = actor?['reference'] as String?;
            if (reference?.contains('Patient/') == true) {
              return reference!;
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting patient ID: $e');
    }
    return 'Unknown';
  }

  String _extractDoctorId(Map<String, dynamic> data) {
    try {
      final rawData = data['raw'] as Map<String, dynamic>? ?? data;
      final participants =
          rawData['participant'] as List? ?? widget.appointment.participants;

      if (participants != null) {
        for (var participant in participants) {
          if (participant is Map<String, dynamic>) {
            final actor = participant['actor'] as Map<String, dynamic>?;
            final reference = actor?['reference'] as String?;
            if (reference?.contains('Practitioner/') == true) {
              return reference!;
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting doctor ID: $e');
    }
    return 'Unknown';
  }

  String _extractLocation(Map<String, dynamic> data) {
    try {
      final rawData = data['raw'] as Map<String, dynamic>? ?? data;
      final participants =
          rawData['participant'] as List? ?? widget.appointment.participants;

      if (participants != null) {
        for (var participant in participants) {
          if (participant is Map<String, dynamic>) {
            final actor = participant['actor'] as Map<String, dynamic>?;
            final display = actor?['display'] as String?;
            if (display != null &&
                actor?['reference']?.contains('Location/') == true) {
              return display;
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting location: $e');
    }
    return 'Unknown';
  }

  String _extractRoomNumber(Map<String, dynamic> data) {
    try {
      final rawData = data['raw'] as Map<String, dynamic>? ?? data;
      final participants =
          rawData['participant'] as List? ?? widget.appointment.participants;

      if (participants != null) {
        for (var participant in participants) {
          if (participant is Map<String, dynamic>) {
            final actor = participant['actor'] as Map<String, dynamic>?;
            final reference = actor?['reference'] as String?;
            if (reference?.contains('Location/') == true) {
              return reference!.substring(9); // Remove 'Location/' prefix
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting room number: $e');
    }
    return 'Unknown';
  }

  String _shortenUrl(String url) {
    final uri = Uri.parse(url);
    return '${uri.host}${uri.path}';
  }

  Color _getParticipantColor(String type) {
    switch (type.toLowerCase()) {
      case 'patient':
        return Colors.blue;
      case 'doctor':
        return Colors.green;
      case 'location':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'tentative':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      case 'needs-action':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Other tabs (simplified for now)
  Widget _buildPreopTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Preoperative Assessment'),
          SizedBox(height: 8),
          Text(
            'This tab will show preoperative data',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIntraopTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('Intraoperative Details'),
          SizedBox(height: 8),
          Text(
            'This tab will show intraoperative data',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.healing, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text('Recovery & Post-op'),
          SizedBox(height: 8),
          Text(
            'This tab will show recovery data',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.biotech, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text('Investigations'),
          SizedBox(height: 8),
          Text(
            'This tab will show lab results and investigations',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scanner, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Radiology'),
          SizedBox(height: 8),
          Text(
            'This tab will show imaging reports',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProceduresTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information, size: 64, color: Colors.teal),
          SizedBox(height: 16),
          Text('Procedures'),
          SizedBox(height: 8),
          Text(
            'This tab will show procedure details',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
