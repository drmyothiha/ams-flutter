import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../screens/medical_history_screen.dart';

class InfoTab extends StatefulWidget {
  final Appointment appointment;
  final Map<String, dynamic> patientData;

  const InfoTab({
    super.key,
    required this.appointment,
    required this.patientData,
  });

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  void _navigateToMedicalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalHistoryScreen(appointment: widget.appointment),
      ),
    );
  }

  String _extractPatientId(Map<String, dynamic> data) {
    try {
      final rawData = data['raw'] as Map<String, dynamic>? ?? data;
      final participants = rawData['participant'] as List? ?? widget.appointment.participants;
      
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
      final participants = rawData['participant'] as List? ?? widget.appointment.participants;
      
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
      final participants = rawData['participant'] as List? ?? widget.appointment.participants;
      
      if (participants != null) {
        for (var participant in participants) {
          if (participant is Map<String, dynamic>) {
            final actor = participant['actor'] as Map<String, dynamic>?;
            final display = actor?['display'] as String?;
            if (display != null && actor?['reference']?.contains('Location/') == true) {
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
      final participants = rawData['participant'] as List? ?? widget.appointment.participants;
      
      if (participants != null) {
        for (var participant in participants) {
          if (participant is Map<String, dynamic>) {
            final actor = participant['actor'] as Map<String, dynamic>?;
            final reference = actor?['reference'] as String?;
            if (reference?.contains('Location/') == true) {
              return reference!.substring(9);
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting room number: $e');
    }
    return 'Unknown';
  }

  String? _extractProcedure(Map<String, dynamic> data) {
    try {
      final rawData = data['raw'] as Map<String, dynamic>? ?? data;
      final serviceType = rawData['serviceType'] as List?;
      
      if (serviceType != null && serviceType.isNotEmpty) {
        final firstService = serviceType.first;
        if (firstService is Map<String, dynamic>) {
          final text = firstService['text'] as String?;
          if (text != null && text.isNotEmpty) {
            return text;
          }
          
          final coding = firstService['coding'] as List?;
          if (coding != null && coding.isNotEmpty) {
            final firstCode = coding.first;
            if (firstCode is Map<String, dynamic>) {
              final display = firstCode['display'] as String?;
              if (display != null && display.isNotEmpty) {
                return display;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting procedure: $e');
    }
    return null;
  }

  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.day}/${localTime.month}/${localTime.year} ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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

  Widget _buildMedicalDetailsCard(Map<String, dynamic> data) {
    final rawData = data['raw'] as Map<String, dynamic>? ?? data;
    final serviceType = rawData['serviceType'] as List?;
    final reasonCode = rawData['reasonCode'] as List?;
    final comment = rawData['comment'] as String?;
    final priority = rawData['priority'] as int?;
    final minutesDuration = rawData['minutesDuration'] as int?;

    return _buildSectionCard(
      title: 'Medical Details',
      icon: Icons.health_and_safety,
      color: Colors.red,
      children: [
        if (minutesDuration != null)
          _buildInfoRow('Duration', '$minutesDuration minutes'),
        if (serviceType != null && serviceType.isNotEmpty)
          _buildMedicalDetailSection('Procedure', serviceType),
        if (reasonCode != null && reasonCode.isNotEmpty)
          _buildMedicalDetailSection('Diagnosis', reasonCode),
        if (comment != null && comment.isNotEmpty)
          _buildInfoRow('Comment', comment),
        if (priority != null)
          _buildInfoRow('Priority', 'Level $priority'),
      ],
    );
  }

  Widget _buildMedicalDetailSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ...items.map((item) {
          if (item is Map<String, dynamic>) {
            final text = item['text'] as String?;
            final coding = item['coding'] as List?;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $text',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (coding != null && coding.isNotEmpty)
                  ...coding.map((code) {
                    if (code is Map<String, dynamic>) {
                      final display = code['display'] as String?;
                      final codeValue = code['code'] as String?;
                      
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 2),
                        child: Text(
                          '  - $display ($codeValue)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }).toList(),
              ],
            );
          }
          return const SizedBox();
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  List<Widget> _buildParticipantsList(List<dynamic> participants) {
    return participants.map((participant) {
      if (participant is Map<String, dynamic>) {
        final actor = participant['actor'] as Map<String, dynamic>?;
        final status = participant['status'] as String?;
        
        final display = actor?['display'] as String?;
        final reference = actor?['reference'] as String?;
        
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clickable Patient Information Box
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.blue,
                                size: 28,
                              ),
                            ),
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
                              _extractPatientId(widget.patientData),
                            ),
                            _buildPatientInfoItem(
                              Icons.medical_services,
                              'Diagnosis',
                              widget.appointment.diagnosis ?? 'Not specified',
                            ),
                            if (widget.appointment.procedureCode != null)
                              _buildPatientInfoItem(
                                Icons.code,
                                'Procedure Code',
                                widget.appointment.procedureCode!,
                              ),
                            if (_extractProcedure(widget.patientData) != null)
                              _buildPatientInfoItem(
                                Icons.medical_information,
                                'Procedure',
                                _extractProcedure(widget.patientData)!,
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
          _buildSectionCard(
            title: 'Appointment Information',
            icon: Icons.calendar_today,
            color: Colors.purple,
            children: [
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

          const SizedBox(height: 16),

          // Doctor Information
          _buildSectionCard(
            title: 'Doctor Information',
            icon: Icons.medical_services,
            color: Colors.green,
            children: [
              _buildInfoRow('Doctor Name', widget.appointment.doctorName),
              _buildInfoRow('Doctor ID', _extractDoctorId(widget.patientData)),
            ],
          ),

          const SizedBox(height: 16),

          // Location Information
          _buildSectionCard(
            title: 'Location Information',
            icon: Icons.location_on,
            color: Colors.orange,
            children: [
              _buildInfoRow('Location', _extractLocation(widget.patientData)),
              _buildInfoRow('Room', _extractRoomNumber(widget.patientData)),
            ],
          ),

          const SizedBox(height: 16),

          // Medical Details
          if (widget.patientData.isNotEmpty) ...[
            _buildMedicalDetailsCard(widget.patientData),
            const SizedBox(height: 16),
          ],

          // Participants Section
          if (widget.appointment.participants.isNotEmpty)
            _buildSectionCard(
              title: 'Participants',
              icon: Icons.group,
              color: Colors.teal,
              children: _buildParticipantsList(widget.appointment.participants),
            ),
        ],
      ),
    );
  }
}