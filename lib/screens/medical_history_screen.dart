import 'package:flutter/material.dart';
import '../models/appointment.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final Appointment appointment;

  const MedicalHistoryScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _medicalData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMedicalData();
  }

  Future<void> _loadMedicalData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Fake comprehensive medical data
    final fakeMedicalData = {
      'patientId': widget.appointment.id,
      'patientName': widget.appointment.patientName,
      'age': 45,
      'gender': 'Male',
      'bloodGroup': 'O+',
      
      'medicalHistory': {
        'allergies': ['Penicillin', 'Sulfa drugs', 'Latex'],
        'chronicConditions': [
          {
            'condition': 'Hypertension',
            'diagnosed': '2018',
            'medication': 'Lisinopril 10mg daily',
            'controlled': true
          },
          {
            'condition': 'Type 2 Diabetes',
            'diagnosed': '2020',
            'medication': 'Metformin 500mg BID',
            'controlled': true
          }
        ],
        'surgeries': [
          {
            'procedure': 'Appendectomy',
            'date': '2015-06-15',
            'hospital': 'City General Hospital',
            'outcome': 'Successful'
          }
        ],
        'hospitalizations': [
          {
            'reason': 'Pneumonia',
            'date': '2021-11-10',
            'duration': '5 days',
            'outcome': 'Full recovery'
          }
        ],
        'vaccinations': [
          {'vaccine': 'COVID-19', 'date': '2021-03-15', 'dose': 'Booster'},
          {'vaccine': 'Influenza', 'date': '2023-10-20', 'dose': 'Annual'},
        ]
      },
      
      'physicalExamination': {
        'lastExam': '2023-12-01',
        'vitalSigns': {
          'bloodPressure': '128/82 mmHg',
          'heartRate': '72 bpm',
          'respiratoryRate': '16 breaths/min',
          'temperature': '36.8°C',
          'oxygenSaturation': '98%'
        },
        'height': '175 cm',
        'weight': '78 kg',
        'bmi': '25.5',
        'cardiovascular': 'Regular rhythm, no murmurs',
        'respiratory': 'Clear breath sounds bilaterally',
        'abdominal': 'Soft, non-tender, non-distended',
        'neurological': 'Normal gait, reflexes intact'
      },
      
      'labReports': [
        {
          'test': 'Complete Blood Count (CBC)',
          'date': '2023-12-01',
          'results': {
            'WBC': '7.2 x10^3/μL',
            'RBC': '4.8 x10^6/μL',
            'Hemoglobin': '14.2 g/dL',
            'Hematocrit': '42%',
            'Platelets': '220 x10^3/μL'
          },
          'status': 'Normal'
        },
        {
          'test': 'Basic Metabolic Panel',
          'date': '2023-12-01',
          'results': {
            'Glucose': '98 mg/dL',
            'BUN': '18 mg/dL',
            'Creatinine': '0.9 mg/dL',
            'Sodium': '140 mEq/L',
            'Potassium': '4.2 mEq/L'
          },
          'status': 'Normal'
        },
        {
          'test': 'Liver Function Tests',
          'date': '2023-12-01',
          'results': {
            'ALT': '25 U/L',
            'AST': '22 U/L',
            'ALP': '85 U/L',
            'Bilirubin': '0.8 mg/dL'
          },
          'status': 'Normal'
        },
      ],
      
      'imagingReports': [
        {
          'study': 'Chest X-Ray',
          'date': '2023-11-28',
          'type': 'X-Ray',
          'indication': 'Pre-operative screening',
          'findings': 'Normal cardiomediastinal silhouette. Clear lungs.',
          'impression': 'Normal chest X-ray',
          'radiologist': 'Dr. Sarah Chen'
        },
        {
          'study': 'Abdominal Ultrasound',
          'date': '2023-11-15',
          'type': 'Ultrasound',
          'indication': 'Abdominal pain',
          'findings': 'Normal liver, gallbladder, pancreas, spleen, and kidneys.',
          'impression': 'Normal abdominal ultrasound',
          'radiologist': 'Dr. Michael Rodriguez'
        },
        {
          'study': 'CT Scan of Abdomen',
          'date': '2023-12-08',
          'type': 'CT Scan',
          'indication': 'Suspected appendicitis',
          'findings': 'Inflamed appendix measuring 11mm with surrounding fat stranding.',
          'impression': 'Acute appendicitis',
          'radiologist': 'Dr. James Wilson'
        }
      ],
      
      'currentMedications': [
        {'name': 'Lisinopril', 'dose': '10mg', 'frequency': 'Once daily', 'purpose': 'Hypertension'},
        {'name': 'Metformin', 'dose': '500mg', 'frequency': 'Twice daily', 'purpose': 'Diabetes'},
        {'name': 'Aspirin', 'dose': '81mg', 'frequency': 'Once daily', 'purpose': 'Cardiovascular'},
      ]
    };

    setState(() {
      _medicalData = fakeMedicalData;
      _loading = false;
    });
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
        title: Text('${widget.appointment.patientName} - Medical History'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Examination'),
            Tab(text: 'Lab Results'),
            Tab(text: 'Imaging'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(),
                _buildExaminationTab(),
                _buildLabResultsTab(),
                _buildImagingTab(),
              ],
            ),
    );
  }

  Widget _buildHistoryTab() {
    final history = _medicalData!['medicalHistory'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Summary
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _medicalData!['patientName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_medicalData!['age']} years • ${_medicalData!['gender']} • ${_medicalData!['bloodGroup']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (history['allergies'].isNotEmpty) ...[
                    const Text(
                      'Allergies:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (history['allergies'] as List).map((allergy) {
                        return Chip(
                          label: Text(allergy),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.red),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Chronic Conditions
          _buildSectionCard(
            'Chronic Conditions',
            Icons.health_and_safety,
            Colors.blue,
            history['chronicConditions'].map<Widget>((condition) {
              return ListTile(
                leading: const Icon(Icons.circle, size: 8, color: Colors.blue),
                title: Text(condition['condition']),
                subtitle: Text('Diagnosed: ${condition['diagnosed']} • ${condition['medication']}'),
                trailing: condition['controlled']
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : const Icon(Icons.warning, color: Colors.orange, size: 20),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Past Surgeries
          _buildSectionCard(
            'Past Surgeries',
            Icons.medical_services,
            Colors.green,
            history['surgeries'].map<Widget>((surgery) {
              return ListTile(
                leading: const Icon(Icons.medical_services, size: 20, color: Colors.green),
                title: Text(surgery['procedure']),
                subtitle: Text('${surgery['date']} • ${surgery['hospital']}'),
                trailing: Text(surgery['outcome'], style: const TextStyle(color: Colors.green)),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Hospitalizations
          _buildSectionCard(
            'Hospitalizations',
            Icons.local_hospital,
            Colors.orange,
            history['hospitalizations'].map<Widget>((hosp) {
              return ListTile(
                leading: const Icon(Icons.local_hospital, size: 20, color: Colors.orange),
                title: Text(hosp['reason']),
                subtitle: Text('${hosp['date']} • ${hosp['duration']}'),
                trailing: Text(hosp['outcome'], style: const TextStyle(color: Colors.green)),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Vaccinations
          _buildSectionCard(
            'Vaccinations',
            Icons.vaccines,
            Colors.purple,
            history['vaccinations'].map<Widget>((vax) {
              return ListTile(
                leading: const Icon(Icons.vaccines, size: 20, color: Colors.purple),
                title: Text(vax['vaccine']),
                subtitle: Text(vax['date']),
                trailing: Text(vax['dose']),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Current Medications
          _buildSectionCard(
            'Current Medications',
            Icons.medication,
            Colors.red,
            (_medicalData!['currentMedications'] as List).map<Widget>((med) {
              return ListTile(
                leading: const Icon(Icons.medication, size: 20, color: Colors.red),
                title: Text('${med['name']} ${med['dose']}'),
                subtitle: Text('${med['frequency']} • ${med['purpose']}'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExaminationTab() {
    final exam = _medicalData!['physicalExamination'];
    final vitals = exam['vitalSigns'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Examination Date
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'Last Examination: ${exam['lastExam']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Vital Signs
          _buildSectionCard(
            'Vital Signs',
            Icons.monitor_heart,
            Colors.red,
            [
              _buildVitalSignRow('Blood Pressure', vitals['bloodPressure']),
              _buildVitalSignRow('Heart Rate', vitals['heartRate']),
              _buildVitalSignRow('Respiratory Rate', vitals['respiratoryRate']),
              _buildVitalSignRow('Temperature', vitals['temperature']),
              _buildVitalSignRow('Oxygen Saturation', vitals['oxygenSaturation']),
            ],
          ),

          const SizedBox(height: 16),

          // Physical Measurements
          _buildSectionCard(
            'Physical Measurements',
            Icons.straighten,
            Colors.green,
            [
              _buildSimpleRow('Height', exam['height']),
              _buildSimpleRow('Weight', exam['weight']),
              _buildSimpleRow('BMI', exam['bmi']),
            ],
          ),

          const SizedBox(height: 16),

          // System Examinations
          _buildSectionCard(
            'System Examination',
            Icons.medical_information,
            Colors.purple,
            [
              _buildSimpleRow('Cardiovascular', exam['cardiovascular']),
              _buildSimpleRow('Respiratory', exam['respiratory']),
              _buildSimpleRow('Abdominal', exam['abdominal']),
              _buildSimpleRow('Neurological', exam['neurological']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultsTab() {
    final labReports = _medicalData!['labReports'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.biotech, color: Colors.blue, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Laboratory Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${labReports.length} tests available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Lab Reports List
          ...labReports.map((report) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            report['test'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: report['status'] == 'Normal'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: report['status'] == 'Normal'
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            report['status'],
                            style: TextStyle(
                              color: report['status'] == 'Normal' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${report['date']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ...(report['results'] as Map<String, dynamic>).entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildImagingTab() {
    final imagingReports = _medicalData!['imagingReports'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.scanner, color: Colors.blue, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imaging Studies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${imagingReports.length} studies available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Imaging Reports List
          ...imagingReports.map((report) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getImagingColor(report['type']),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report['type'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          report['date'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report['study'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Indication: ${report['indication']}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Findings:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(report['findings']),
                    const SizedBox(height: 12),
                    const Text(
                      'Impression:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['impression'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Radiologist: ${report['radiologist']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getImagingColor(String type) {
    switch (type) {
      case 'X-Ray':
        return Colors.blue;
      case 'CT Scan':
        return Colors.green;
      case 'MRI':
        return Colors.purple;
      case 'Ultrasound':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}