import 'package:flutter/material.dart';
import '../models/appointment.dart';

class PatientDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const PatientDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _patientData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _patientData = _loadPatientData();
  }

  Future<Map<String, dynamic>> _loadPatientData() async {
    // Simulate API call for patient data
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock data for all tabs
    return {
      'info': {
        'patientId': widget.appointment.id,
        'name': widget.appointment.patientName,
        'age': 45,
        'gender': 'Male',
        'bloodGroup': 'O+',
        'allergies': 'Penicillin',
        'contact': '555-0123',
        'address': '123 Main St, City',
      },
      'preop': {
        'assessmentDate': '2024-01-10',
        'bloodPressure': '120/80',
        'heartRate': '72 bpm',
        'ecg': 'Normal',
        'bloodTests': 'Within normal limits',
        'anesthesiaRisk': 'Low',
        'notes': 'Cleared for surgery',
      },
      'intraop': {
        'surgeryStart': '09:30',
        'surgeryEnd': '11:45',
        'anesthesiaType': 'General',
        'vitalSigns': 'Stable throughout',
        'bloodLoss': '200ml',
        'fluids': '1500ml crystalloid',
        'complications': 'None',
      },
      'recovery': {
        'recoveryStart': '11:50',
        'dischargeTime': '16:30',
        'painScore': '3/10',
        'medications': 'Paracetamol 1g Q6H',
        'vitals': 'Stable',
        'diet': 'Clear fluids',
        'instructions': 'Follow up in 1 week',
      },
      'investigations': {
        'bloodWork': 'CBC, LFT, RFT normal',
        'urineAnalysis': 'Normal',
        'culture': 'No growth',
        'pathology': 'Pending',
        'microbiology': 'Pending',
      },
      'radio': {
        'xray': 'Chest X-ray: Clear',
        'ctScan': 'Abdomen CT: Appendicitis confirmed',
        'ultrasound': 'Not performed',
        'mri': 'Not required',
        'reports': 'Available in system',
      },
      'procedures': {
        'procedureName': 'Appendectomy',
        'procedureCode': '44970',
        'surgeon': 'Dr. Smith',
        'assistant': 'Dr. Johnson',
        'anesthetist': 'Dr. Williams',
        'notes': 'Laparoscopic procedure',
        'consent': 'Signed',
      },
    };
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _patientData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(data['info']),
              _buildPreopTab(data['preop']),
              _buildIntraopTab(data['intraop']),
              _buildRecoveryTab(data['recovery']),
              _buildInvestigationsTab(data['investigations']),
              _buildRadioTab(data['radio']),
              _buildProceduresTab(data['procedures']),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(Map<String, dynamic> info) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Patient Information', [
            _buildInfoRow('Patient ID', widget.appointment.id),
            _buildInfoRow('Name', widget.appointment.patientName),
            _buildInfoRow('Age', info['age'].toString()),
            _buildInfoRow('Gender', info['gender']),
            _buildInfoRow('Blood Group', info['bloodGroup']),
          ]),
          
          const SizedBox(height: 16),
          
          _buildSectionCard('Contact Information', [
            _buildInfoRow('Contact', info['contact']),
            _buildInfoRow('Address', info['address']),
          ]),
          
          const SizedBox(height: 16),
          
          _buildSectionCard('Medical Information', [
            _buildInfoRow('Allergies', info['allergies']),
            if (widget.appointment.diagnosis != null)
              _buildInfoRow('Diagnosis', widget.appointment.diagnosis!),
          ]),
          
          const SizedBox(height: 16),
          
          _buildSectionCard('Appointment Details', [
            _buildInfoRow('Doctor', widget.appointment.doctorName),
            _buildInfoRow('Status', widget.appointment.status),
            _buildInfoRow('Date', widget.appointment.start.toLocal().toString().split(' ')[0]),
            _buildInfoRow('Time', 
              '${widget.appointment.start.toLocal().toString().split(' ')[1].substring(0, 5)} - '
              '${widget.appointment.end.toLocal().toString().split(' ')[1].substring(0, 5)}'
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPreopTab(Map<String, dynamic> preop) {
    return _buildGenericTab(
      title: 'Preoperative Assessment',
      icon: Icons.medical_services,
      data: preop,
    );
  }

  Widget _buildIntraopTab(Map<String, dynamic> intraop) {
    return _buildGenericTab(
      title: 'Intraoperative Details',
      icon: Icons.science,
      data: intraop,
    );
  }

  Widget _buildRecoveryTab(Map<String, dynamic> recovery) {
    return _buildGenericTab(
      title: 'Recovery & Post-op',
      icon: Icons.healing,
      data: recovery,
    );
  }

  Widget _buildInvestigationsTab(Map<String, dynamic> investigations) {
    return _buildGenericTab(
      title: 'Investigations',
      icon: Icons.biotech,
      data: investigations,
    );
  }

  Widget _buildRadioTab(Map<String, dynamic> radio) {
    return _buildGenericTab(
      title: 'Radiology',
      icon: Icons.scanner,
      data: radio,
    );
  }

  Widget _buildProceduresTab(Map<String, dynamic> procedures) {
    return _buildGenericTab(
      title: 'Procedures',
      icon: Icons.medical_information,
      data: procedures,
    );
  }

  Widget _buildGenericTab({
    required String title,
    required IconData icon,
    required Map<String, dynamic> data,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(icon, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For ${widget.appointment.patientName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildInfoRow(
                      _capitalize(entry.key),
                      entry.value.toString(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Note: This is sample data. Connect to your API to load real patient information.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            width: 120,
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

  String _capitalize(String text) {
    return text.replaceAllMapped(
      RegExp(r'\b(\w)'),
      (match) => match.group(0)!.toUpperCase(),
    ).replaceAll('_', ' ');
  }
}