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
          // Appointment Information
          _buildSectionCard('Appointment Information', [
            _buildInfoRow('Appointment ID', widget.appointment.id),
            _buildInfoRow('Resource Type', widget.appointment.resourceType),
            _buildStatusRow('Status', widget.appointment.status),
            _buildInfoRow('Start', _formatDateTime(widget.appointment.start)),
            _buildInfoRow('End', _formatDateTime(widget.appointment.end)),
            _buildInfoRow(
              'Duration',
              '${_calculateDuration(widget.appointment.start, widget.appointment.end)} minutes',
            ),
            if (widget.appointment.createdAt.isNotEmpty)
              _buildInfoRow('Created', widget.appointment.createdAt),
          ]),

          const SizedBox(height: 16),

          // Patient Information
          _buildSectionCard('Patient Information', [
            _buildInfoRow('Patient Name', widget.appointment.patientName),
            _buildInfoRow('Patient ID', _extractPatientId(data)),
            if (widget.appointment.diagnosis != null)
              _buildInfoRow('Diagnosis', widget.appointment.diagnosis!),
            if (widget.appointment.procedureCode != null)
              _buildInfoRow(
                'Procedure Code',
                widget.appointment.procedureCode!,
              ),
          ]),

          const SizedBox(height: 16),

          // Doctor Information
          _buildSectionCard('Doctor Information', [
            _buildInfoRow('Doctor Name', widget.appointment.doctorName),
            _buildInfoRow('Doctor ID', _extractDoctorId(data)),
          ]),

          const SizedBox(height: 16),

          // Location Information
          _buildSectionCard('Location Information', [
            _buildInfoRow('Location', _extractLocation(data)),
            _buildInfoRow('Room', _extractRoomNumber(data)),
          ]),

          const SizedBox(height: 16),

          // Medical Details from Raw Data
          if (data.isNotEmpty) ...[
            _buildMedicalDetailsCard(data),
            const SizedBox(height: 16),
          ],

          // Participants Section
          if (widget.appointment.participants.isNotEmpty)
            _buildParticipantsCard(widget.appointment.participants),
        ],
      ),
    );
  }

  Widget _buildMedicalDetailsCard(Map<String, dynamic> data) {
    // Try to get raw data first, then fall back to direct properties
    final rawData = data['raw'] as Map<String, dynamic>? ?? data;

    final serviceType = rawData['serviceType'] as List?;
    final reasonCode = rawData['reasonCode'] as List?;
    final comment = rawData['comment'] as String?;
    final priority = rawData['priority'] as int?;
    final minutesDuration = rawData['minutesDuration'] as int?;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (minutesDuration != null)
              _buildInfoRow('Duration (minutes)', minutesDuration.toString()),

            if (serviceType != null && serviceType.isNotEmpty)
              _buildMedicalDetailSection('Service Type', serviceType),

            if (reasonCode != null && reasonCode.isNotEmpty)
              _buildMedicalDetailSection('Reason Code', reasonCode),

            if (comment != null && comment.isNotEmpty)
              _buildInfoRow('Comment', comment),

            if (priority != null)
              _buildInfoRow('Priority', priority.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDetailSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) {
          if (item is Map<String, dynamic>) {
            final text = item['text'] as String?;
            final coding = item['coding'] as List?;

            if (text != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• $text', style: const TextStyle(fontSize: 14)),
                    if (coding != null && coding.isNotEmpty)
                      ...coding.map((code) {
                        if (code is Map<String, dynamic>) {
                          final system = code['system'] as String?;
                          final codeValue = code['code'] as String?;
                          final display = code['display'] as String?;

                          return Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (display != null)
                                  Text(
                                    '  - $display',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (codeValue != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      '    Code: $codeValue',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                if (system != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      '    System: ${_shortenUrl(system)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      }).toList(),
                  ],
                ),
              );
            }
          }
          return const SizedBox();
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildParticipantsCard(List<dynamic> participants) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...participants.map((participant) {
              if (participant is Map<String, dynamic>) {
                final actor = participant['actor'] as Map<String, dynamic>?;
                final status = participant['status'] as String?;
                final required = participant['required'] as String?;

                final display = actor?['display'] as String?;
                final reference = actor?['reference'] as String?;

                // Determine participant type
                String type = 'Unknown';
                if (reference?.contains('Patient') == true) type = 'Patient';
                if (reference?.contains('Practitioner') == true)
                  type = 'Doctor';
                if (reference?.contains('Location') == true) type = 'Location';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getParticipantColor(type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              display ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (reference != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 2),
                          child: Text(
                            'ID: $reference',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      if (status != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 2),
                          child: Text(
                            'Status: $status',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
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
