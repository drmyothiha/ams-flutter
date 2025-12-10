import 'package:ams/services/preop_service.dart';
import 'package:flutter/material.dart';

class PreopTab extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const PreopTab({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<PreopTab> createState() => _PreopTabState();
}

class _PreopTabState extends State<PreopTab> {
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final PreopService _preopService = PreopService();
  final FocusNode _historyFocusNode = FocusNode();
  final FocusNode _examFocusNode = FocusNode();
  final FocusNode _instructionsFocusNode = FocusNode();

  bool _isSubmitting = false;
  String? _selectedStatus;
  List<String> _selectedChecklist = [];

  // Preoperative checklist items
  final List<Map<String, dynamic>> _preopChecklist = [
    {'id': 'consent', 'label': 'Consent Form Signed', 'required': true},
    {'id': 'lab_reports', 'label': 'Lab Reports Reviewed', 'required': true},
    {'id': 'ecg', 'label': 'ECG Normal', 'required': true},
    {'id': 'xray', 'label': 'Chest X-Ray Reviewed', 'required': true},
    {'id': 'allergies', 'label': 'Allergies Documented', 'required': true},
    {'id': 'npo', 'label': 'NPO Status Confirmed', 'required': true},
    {'id': 'medications', 'label': 'Medications Reviewed', 'required': true},
    {'id': 'anesthesia', 'label': 'Anesthesia Clearance', 'required': true},
    {'id': 'blood', 'label': 'Blood Availability Confirmed', 'required': false},
    {'id': 'icu', 'label': 'ICU Bed Reserved', 'required': false},
  ];

  // Anaesthesia-specific state
  String? _airwayMallampati;
  String? _airwayAssessment;
  String? _spineAssessment;
  bool _aspirationRisk = false;
  bool _difficultAirway = false;
  String? _asaScore;
  List<String> _anaesthesiaChecklist = [];
  String _anaesthesiaNotes = '';

  // Anaesthesia checklist items
  final List<Map<String, dynamic>> _anaesthesiaChecklistItems = [
    {
      'id': 'airway_assessed',
      'label': 'Airway Assessment Completed',
      'required': true,
    },
    {
      'id': 'mallampati_recorded',
      'label': 'Mallampati Score Recorded',
      'required': true,
    },
    {
      'id': 'spine_assessed',
      'label': 'Spine Assessment Completed',
      'required': true,
    },
    {
      'id': 'aspiration_risk',
      'label': 'Aspiration Risk Assessed',
      'required': true,
    },
    {
      'id': 'teeth_assessed',
      'label': 'Dental Status Assessed',
      'required': true,
    },
    {
      'id': 'neck_mobility',
      'label': 'Neck Mobility Assessed',
      'required': true,
    },
    {
      'id': 'thyromental_distance',
      'label': 'Thyromental Distance >6cm',
      'required': true,
    },
    {
      'id': 'asa_scored',
      'label': 'ASA Physical Status Scored',
      'required': true,
    },
    {
      'id': 'allergies_confirmed',
      'label': 'Drug Allergies Confirmed',
      'required': true,
    },
    {'id': 'npo_confirmed', 'label': 'NPO Status Confirmed', 'required': true},
    {
      'id': 'consent_anaesthesia',
      'label': 'Anaesthesia Consent Signed',
      'required': true,
    },
    {
      'id': 'monitoring_plan',
      'label': 'Monitoring Plan Documented',
      'required': true,
    },
    {
      'id': 'difficult_airway_kit',
      'label': 'Difficult Airway Kit Available',
      'required': false,
    },
    {
      'id': 'blood_available',
      'label': 'Blood Products Available',
      'required': false,
    },
    {'id': 'icu_bed', 'label': 'ICU Bed Arranged if Needed', 'required': false},
  ];

  // Mallampati Classification
  final List<Map<String, dynamic>> _mallampatiOptions = [
    {
      'value': 'I',
      'label': 'Class I: Soft palate, uvula, fauces, pillars visible',
    },
    {'value': 'II', 'label': 'Class II: Soft palate, uvula, fauces visible'},
    {'value': 'III', 'label': 'Class III: Soft palate, base of uvula visible'},
    {'value': 'IV', 'label': 'Class IV: Hard palate only visible'},
  ];

  // ASA Physical Status
  final List<Map<String, dynamic>> _asaOptions = [
    {'value': 'I', 'label': 'ASA I: Healthy patient'},
    {'value': 'II', 'label': 'ASA II: Mild systemic disease'},
    {'value': 'III', 'label': 'ASA III: Severe systemic disease'},
    {
      'value': 'IV',
      'label':
          'ASA IV: Severe systemic disease that is constant threat to life',
    },
    {'value': 'V', 'label': 'ASA V: Moribund patient not expected to survive'},
    {'value': 'VI', 'label': 'ASA VI: Brain-dead patient for organ donation'},
  ];

  // Airway Assessment
  final List<Map<String, dynamic>> _airwayOptions = [
    {'value': 'easy', 'label': 'Easy: No anticipated difficulty'},
    {'value': 'moderate', 'label': 'Moderate: Potential difficulty'},
    {'value': 'difficult', 'label': 'Difficult: Anticipated difficult airway'},
    {'value': 'failed', 'label': 'Failed: Previous failed intubation'},
  ];

  // Spine Assessment
  final List<Map<String, dynamic>> _spineOptions = [
    {'value': 'normal', 'label': 'Normal: Full range of motion'},
    {'value': 'limited', 'label': 'Limited: Reduced mobility'},
    {'value': 'rigid', 'label': 'Rigid: Fixed/ankylosed'},
    {'value': 'unstable', 'label': 'Unstable: Trauma/infection/tumor'},
  ];

  // Cardiac Checklist State
  List<String> _cardiacChecklistSelected = [];

  // Respiratory Checklist State
  List<String> _respiratoryChecklistSelected = [];

  // Laboratory Checklist State
  List<String> _labChecklistSelected = [];

  // Cardiac Checklist
  final List<Map<String, dynamic>> _cardiacChecklist = [
    {'id': 'ecg_normal', 'label': 'ECG Normal', 'required': true},
    {'id': 'echo_done', 'label': 'Echocardiogram if >50yo', 'required': false},
    {
      'id': 'blood_pressure',
      'label': 'BP Controlled (<140/90)',
      'required': true,
    },
    {'id': 'heart_rate', 'label': 'HR 60-100 bpm', 'required': true},
    {
      'id': 'cardiac_meds',
      'label': 'Cardiac Medications Reviewed',
      'required': true,
    },
    {'id': 'chest_pain', 'label': 'No Active Chest Pain', 'required': true},
    {
      'id': 'heart_failure',
      'label': 'No Signs of Heart Failure',
      'required': true,
    },
    {'id': 'valvular', 'label': 'No Valvular Heart Disease', 'required': false},
    {
      'id': 'pacemaker',
      'label': 'Pacemaker/ICD Status Documented',
      'required': false,
    },
  ];

  // Respiratory Checklist
  final List<Map<String, dynamic>> _respiratoryChecklist = [
    {'id': 'chest_xray', 'label': 'Chest X-Ray Reviewed', 'required': true},
    {'id': 'spo2_normal', 'label': 'SpO2 >94% on Room Air', 'required': true},
    {'id': 'pft_done', 'label': 'PFT if COPD/Asthma', 'required': false},
    {
      'id': 'smoking_cessation',
      'label': 'Smoking Cessation >4 weeks',
      'required': false,
    },
    {'id': 'no_dyspnea', 'label': 'No Dyspnea at Rest', 'required': true},
    {'id': 'no_wheezing', 'label': 'No Active Wheezing', 'required': true},
    {
      'id': 'respiratory_rate',
      'label': 'RR 12-20 breaths/min',
      'required': true,
    },
    {
      'id': 'oxygen_required',
      'label': 'No Home Oxygen Requirement',
      'required': false,
    },
    {
      'id': 'copd_exacerbation',
      'label': 'No Recent COPD Exacerbation',
      'required': true,
    },
  ];

  // Infectious Disease Screening State
  Map<String, String> _infectiousDiseaseStatus = {
    'hiv': 'negative', // 'negative', 'positive', 'pending', 'not_done'
    'hbsag': 'negative',
    'hcv': 'negative',
    'syphilis': 'negative',
  };

  String? _infectiousDiseaseNotes;

  // Updated Laboratory Checklist with infectious diseases removed from main list
  final List<Map<String, dynamic>> _labChecklist = [
    {'id': 'cbc_normal', 'label': 'CBC within normal limits', 'required': true},
    {'id': 'coagulation', 'label': 'PT/INR/APTT Normal', 'required': true},
    {
      'id': 'renal_function',
      'label': 'Creatinine <1.5 mg/dL',
      'required': true,
    },
    {'id': 'liver_function', 'label': 'LFT Normal', 'required': true},
    {'id': 'blood_sugar', 'label': 'Blood Sugar Controlled', 'required': true},
    {'id': 'electrolytes', 'label': 'Electrolytes Normal', 'required': true},
    {'id': 'albumin', 'label': 'Albumin >3.0 g/dL', 'required': false},
    {
      'id': 'pregnancy_test',
      'label': 'Pregnancy Test Negative (if applicable)',
      'required': false,
    },
    {
      'id': 'blood_group',
      'label': 'Blood Group & Crossmatch Done',
      'required': true,
    },
  ];

  // Infectious disease options with descriptions
  final List<Map<String, dynamic>> _diseaseOptions = [
    {
      'value': 'negative',
      'label': 'Neg',
      'color': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'value': 'positive',
      'label': 'Pos',
      'color': Colors.red,
      'icon': Icons.error,
    },
    {
      'value': 'pending',
      'label': 'Pen',
      'color': Colors.orange,
      'icon': Icons.hourglass_empty,
    },
    {
      'value': 'not_done',
      'label': 'ND',
      'color': Colors.grey,
      'icon': Icons.remove_circle,
    },
  ];
  Widget _buildInfectiousDiseaseSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Infectious Disease Screening',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Required for universal precautions',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (_hasPositiveResults)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, size: 14, color: Colors.red),
                        SizedBox(width: 6),
                        Text(
                          'POSITIVE RESULT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Disease Screening Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildDiseaseCard(
                  title: 'HIV',
                  value: _infectiousDiseaseStatus['hiv']!,
                  onChanged: (value) {
                    setState(() {
                      _infectiousDiseaseStatus['hiv'] = value;
                    });
                  },
                  description: 'Human Immunodeficiency Virus',
                ),
                _buildDiseaseCard(
                  title: 'HBsAg',
                  value: _infectiousDiseaseStatus['hbsag']!,
                  onChanged: (value) {
                    setState(() {
                      _infectiousDiseaseStatus['hbsag'] = value;
                    });
                  },
                  description: 'Hepatitis B Surface Antigen',
                ),
                _buildDiseaseCard(
                  title: 'HCV',
                  value: _infectiousDiseaseStatus['hcv']!,
                  onChanged: (value) {
                    setState(() {
                      _infectiousDiseaseStatus['hcv'] = value;
                    });
                  },
                  description: 'Hepatitis C Virus',
                ),
                _buildDiseaseCard(
                  title: 'Syphilis',
                  value: _infectiousDiseaseStatus['syphilis']!,
                  onChanged: (value) {
                    setState(() {
                      _infectiousDiseaseStatus['syphilis'] = value;
                    });
                  },
                  description: 'VDRL/RPR',
                  required: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes Section
            TextField(
              controller: TextEditingController(text: _infectiousDiseaseNotes),
              onChanged: (value) {
                setState(() {
                  _infectiousDiseaseNotes = value;
                });
              },
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Infectious Disease Notes',
                hintText:
                    'Details about positive results, confirmatory tests, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
            ),

            // Warning for Positive Results
            if (_hasPositiveResults) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Universal Precautions Required',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPositiveDiseasesList(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Use double gloves\n• Eye protection mandatory\n• Sharps safety protocols\n• Post-exposure prophylaxis available',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],

            // Legend
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _diseaseOptions.map((option) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: option['color'],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option['label'],
                      style: TextStyle(fontSize: 11, color: option['color']),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard({
    required String title,
    required String value,
    required Function(String) onChanged,
    required String description,
    bool required = true,
  }) {
    final option = _diseaseOptions.firstWhere((opt) => opt['value'] == value);
    final isPositive = value == 'positive';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.red.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive ? Colors.red : Colors.grey.shade300,
          width: isPositive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: option['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(option['icon'], size: 16, color: option['color']),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: option['color'],
                ),
              ),
              if (required)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _diseaseOptions.map((opt) {
              return ChoiceChip(
                label: Text(opt['label']),
                selected: value == opt['value'],
                onSelected: (selected) {
                  if (selected) onChanged(opt['value']);
                },
                selectedColor: opt['color'],
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  fontSize: 10,
                  color: value == opt['value']
                      ? Colors.white
                      : Colors.grey[700],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: value == opt['value']
                        ? opt['color']
                        : Colors.grey.shade400,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool get _hasPositiveResults {
    return _infectiousDiseaseStatus['hiv'] == 'positive' ||
        _infectiousDiseaseStatus['hbsag'] == 'positive' ||
        _infectiousDiseaseStatus['hcv'] == 'positive' ||
        _infectiousDiseaseStatus['syphilis'] == 'positive';
  }

  String _getPositiveDiseasesList() {
    final positiveDiseases = <String>[];

    if (_infectiousDiseaseStatus['hiv'] == 'positive')
      positiveDiseases.add('HIV');
    if (_infectiousDiseaseStatus['hbsag'] == 'positive')
      positiveDiseases.add('Hepatitis B');
    if (_infectiousDiseaseStatus['hcv'] == 'positive')
      positiveDiseases.add('Hepatitis C');
    if (_infectiousDiseaseStatus['syphilis'] == 'positive')
      positiveDiseases.add('Syphilis');

    return positiveDiseases.join(', ');
  }

  Widget _buildLaboratorySection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Laboratory Requirements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'All routine laboratory tests must be completed',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Laboratory Checklist
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _labChecklist.map((item) {
                final isSelected = _labChecklistSelected.contains(item['id']);
                final isRequired = item['required'] == true;

                return FilterChip(
                  label: Text(item['label']),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _labChecklistSelected.add(item['id']);
                      } else {
                        _labChecklistSelected.remove(item['id']);
                      }
                    });
                  },
                  checkmarkColor: Colors.white,
                  selectedColor: isRequired ? Colors.orange : Colors.teal,
                  backgroundColor: isSelected
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isRequired
                        ? Colors.orange
                        : Colors.grey[700],
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isRequired ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Infectious Disease Section
            _buildInfectiousDiseaseSection(),

            // Legend
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Required', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Optional', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update validation to check infectious disease status

  @override
  void initState() {
    super.initState();
    // Load saved preop data if exists
    _loadPreopData();
  }

  Future<void> _loadPreopData() async {
    // TODO: Load from API
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate loaded anaesthesia data
    setState(() {
      _airwayMallampati =
          widget.patientData['anaesthesia']?['mallampati'] ?? 'I';
      _airwayAssessment =
          widget.patientData['anaesthesia']?['airway_assessment'] ?? 'easy';
      _spineAssessment =
          widget.patientData['anaesthesia']?['spine'] ?? 'normal';
      _aspirationRisk =
          widget.patientData['anaesthesia']?['aspiration_risk'] ?? false;
      _difficultAirway =
          widget.patientData['anaesthesia']?['difficult_airway'] ?? false;
      _asaScore = widget.patientData['anaesthesia']?['asa_score'] ?? 'II';
      _anaesthesiaChecklist =
          widget.patientData['anaesthesia']?['checklist'] ?? [];
      _anaesthesiaNotes = widget.patientData['anaesthesia']?['notes'] ?? '';
      _cardiacChecklistSelected = widget.patientData['cardiac_checklist'] ?? [];
      _respiratoryChecklistSelected =
          widget.patientData['respiratory_checklist'] ?? [];
      _labChecklistSelected = widget.patientData['lab_checklist'] ?? [];
    });
  }

  Widget _buildAnaesthesiaAssessmentSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.airline_seat_recline_normal,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Anaesthesia Assessment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Airway Assessment Grid
            const Text(
              'Airway Assessment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                // Mallampati Score
                _buildAssessmentCard(
                  title: 'Mallampati Classification',
                  value: _airwayMallampati,
                  options: _mallampatiOptions,
                  onChanged: (value) {
                    setState(() {
                      _airwayMallampati = value;
                    });
                  },
                  icon: Icons.airline_seat_recline_normal,
                  color: Colors.blue,
                ),

                // ASA Score
                _buildAssessmentCard(
                  title: 'ASA Physical Status',
                  value: _asaScore,
                  options: _asaOptions,
                  onChanged: (value) {
                    setState(() {
                      _asaScore = value;
                    });
                  },
                  icon: Icons.medical_information,
                  color: Colors.green,
                ),

                // Airway Assessment
                _buildAssessmentCard(
                  title: 'Airway Assessment',
                  value: _airwayAssessment,
                  options: _airwayOptions,
                  onChanged: (value) {
                    setState(() {
                      _airwayAssessment = value;
                    });
                  },
                  icon: Icons.air,
                  color: Colors.orange,
                ),

                // Spine Assessment
                _buildAssessmentCard(
                  title: 'Spine Assessment',
                  value: _spineAssessment,
                  options: _spineOptions,
                  onChanged: (value) {
                    setState(() {
                      _spineAssessment = value;
                    });
                  },
                  icon: Icons.accessibility,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Risk Factors
            const Text(
              'Risk Factors',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildRiskFactorChip(
                  label: 'Aspiration Risk',
                  value: _aspirationRisk,
                  onChanged: (value) {
                    setState(() {
                      _aspirationRisk = value;
                    });
                  },
                ),
                _buildRiskFactorChip(
                  label: 'Difficult Airway',
                  value: _difficultAirway,
                  onChanged: (value) {
                    setState(() {
                      _difficultAirway = value;
                    });
                  },
                ),
                _buildRiskFactorChip(
                  label: 'Obesity (BMI >30)',
                  value: false,
                  onChanged: (value) {},
                ),
                _buildRiskFactorChip(
                  label: 'Smoker',
                  value: false,
                  onChanged: (value) {},
                ),
                _buildRiskFactorChip(
                  label: 'OSA (Sleep Apnea)',
                  value: false,
                  onChanged: (value) {},
                ),
                _buildRiskFactorChip(
                  label: 'GERD/Reflux',
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Anaesthesia Checklist
            const Text(
              'Anaesthesia Checklist',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All required items must be completed before anaesthesia',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _anaesthesiaChecklistItems.map((item) {
                final isSelected = _anaesthesiaChecklist.contains(item['id']);
                final isRequired = item['required'] == true;

                return FilterChip(
                  label: Text(item['label']),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _anaesthesiaChecklist.add(item['id']);
                      } else {
                        _anaesthesiaChecklist.remove(item['id']);
                      }
                    });
                  },
                  checkmarkColor: Colors.white,
                  selectedColor: isRequired ? Colors.purple : Colors.teal,
                  backgroundColor: isRequired
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isRequired
                        ? Colors.purple
                        : Colors.grey[700],
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isRequired ? Colors.purple : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Anaesthesia Notes
            TextField(
              controller: TextEditingController(text: _anaesthesiaNotes),
              onChanged: (value) {
                setState(() {
                  _anaesthesiaNotes = value;
                });
              },
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Anaesthesia Notes',
                hintText: 'Special considerations, drug allergies, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note_add),
              ),
            ),

            // Risk Summary
            if (_aspirationRisk || _difficultAirway) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'High Risk Factors Identified',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _buildRiskSummary(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard({
    required String title,
    required String? value,
    required List<Map<String, dynamic>> options,
    required Function(String?) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(
                  option['value'],
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: color.withOpacity(0.3)),
              ),
            ),
            isExpanded: true,
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                options.firstWhere((opt) => opt['value'] == value)['label'],
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorChip({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.orange,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: value ? Colors.white : Colors.grey[700],
        fontWeight: value ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: value ? Colors.orange : Colors.grey.shade400),
      ),
    );
  }

  String _buildRiskSummary() {
    final risks = <String>[];
    if (_aspirationRisk) risks.add('Aspiration Risk');
    if (_difficultAirway) risks.add('Difficult Airway');
    if (_airwayMallampati == 'III' || _airwayMallampati == 'IV') {
      risks.add('Mallampati ${_airwayMallampati}');
    }
    if (_asaScore == 'III' || _asaScore == 'IV' || _asaScore == 'V') {
      risks.add('ASA ${_asaScore}');
    }
    return risks.join(', ');
  }

  Map<String, dynamic> _buildAnaesthesiaData() {
    return {
      'airway': {
        'mallampati': _airwayMallampati,
        'assessment': _airwayAssessment,
        'difficult_airway': _difficultAirway,
      },
      'spine': _spineAssessment,
      'aspiration_risk': _aspirationRisk,
      'asa_score': _asaScore,
      'checklist': _anaesthesiaChecklist,
      'notes': _anaesthesiaNotes,
      'risk_summary': _buildRiskSummary(),
      'assessed_by': 'Dr. Name', // TODO: Get from auth
      'assessed_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _savePreopAssessment() async {
    if (_isSubmitting) return;

    // Validate required fields
    final requiredItems = _preopChecklist
        .where((item) => item['required'] == true)
        .map((item) => item['id'] as String)
        .toList();

    final missingRequired = requiredItems
        .where((item) => !_selectedChecklist.contains(item))
        .toList();

    if (missingRequired.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete required checklist items: ${missingRequired.length} remaining',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save to API
      // final result = await _preopService.savePreopAssessment(
      //   appointmentId: widget.appointmentId, // You need to pass appointment from parent
      //   preopData: preopData,
      // );

      await Future.delayed(const Duration(seconds: 1));

      final preopData = {
        'patientId': widget.patientId,
        'history': _historyController.text,
        'exam': _examController.text,
        'instructions': _instructionsController.text,
        'status': _selectedStatus,
        'checklist': _selectedChecklist,
        // Add anaesthesia data
        'anaesthesia': _buildAnaesthesiaData(),
        'timestamp': DateTime.now().toIso8601String(),
        'assessedBy': 'Dr. Myo Thiha', // TODO: Get from auth
      };

      print('Saving preop data: $preopData');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preoperative assessment saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving assessment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateAppointmentStatus(String status) async {
    if (_isSubmitting) return;

    // Validate before status change
    if (status == 'confirm' || status == 'booked') {
      final requiredItems = _preopChecklist
          .where((item) => item['required'] == true)
          .map((item) => item['id'] as String)
          .toList();

      final missingRequired = requiredItems
          .where((item) => !_selectedChecklist.contains(item))
          .toList();

      if (missingRequired.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot confirm: ${missingRequired.length} required items incomplete',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _selectedStatus = status;
    });

    // Also save the assessment
    await _savePreopAssessment();
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    bool required = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (required)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> checklist,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
    String? description,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Indicator
            _buildProgressBar(selectedItems, checklist),

            const SizedBox(height: 16),

            // Checklist Items
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: checklist.map((item) {
                final isSelected = selectedItems.contains(item['id']);
                final isRequired = item['required'] == true;

                return FilterChip(
                  label: Text(item['label']),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newList = List<String>.from(selectedItems);
                    if (selected) {
                      newList.add(item['id']);
                    } else {
                      newList.remove(item['id']);
                    }
                    onSelectionChanged(newList);
                  },
                  checkmarkColor: Colors.white,
                  selectedColor: isRequired ? color : Colors.teal,
                  backgroundColor: isSelected
                      ? color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isRequired
                        ? color
                        : Colors.grey[700],
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isRequired ? color : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),

            // Legend
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Required', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Optional', style: TextStyle(fontSize: 12)),
                const Spacer(),
                Text(
                  '${selectedItems.length}/${checklist.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    List<String> selected,
    List<Map<String, dynamic>> checklist,
  ) {
    final totalRequired = checklist
        .where((item) => item['required'] == true)
        .length;
    final completedRequired = checklist
        .where(
          (item) => item['required'] == true && selected.contains(item['id']),
        )
        .length;

    final percentage = totalRequired > 0
        ? (completedRequired / totalRequired)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Required Items Progress',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage == 1.0 ? Colors.green : Colors.blue,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '$completedRequired/$totalRequired required items completed',
          style: TextStyle(
            fontSize: 11,
            color: percentage == 1.0 ? Colors.green : Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalRequired =
        _preopChecklist.where((item) => item['required'] == true).length +
        _anaesthesiaChecklistItems
            .where((item) => item['required'] == true)
            .length +
        _cardiacChecklist.where((item) => item['required'] == true).length +
        _respiratoryChecklist.where((item) => item['required'] == true).length +
        _labChecklist.where((item) => item['required'] == true).length;

    final completedRequired =
        _preopChecklist
            .where(
              (item) =>
                  item['required'] == true &&
                  _selectedChecklist.contains(item['id']),
            )
            .length +
        _anaesthesiaChecklistItems
            .where(
              (item) =>
                  item['required'] == true &&
                  _anaesthesiaChecklist.contains(item['id']),
            )
            .length +
        _cardiacChecklist
            .where(
              (item) =>
                  item['required'] == true &&
                  _cardiacChecklistSelected.contains(item['id']),
            )
            .length +
        _respiratoryChecklist
            .where(
              (item) =>
                  item['required'] == true &&
                  _respiratoryChecklistSelected.contains(item['id']),
            )
            .length +
        _labChecklist
            .where(
              (item) =>
                  item['required'] == true &&
                  _labChecklistSelected.contains(item['id']),
            )
            .length;

    final percentage = totalRequired > 0
        ? (completedRequired / totalRequired)
        : 0.0;
    final isComplete = percentage == 1.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preoperative Assessment Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Overall Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall Completion',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${(percentage * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isComplete ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? Colors.green : Colors.blue,
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isComplete ? Colors.green : Colors.blue,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$completedRequired',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? Colors.green : Colors.blue,
                        ),
                      ),
                      Text(
                        'of $totalRequired',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Checklist Breakdown
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildMiniProgressCard(
                  label: 'General',
                  completed: _preopChecklist
                      .where(
                        (item) =>
                            item['required'] == true &&
                            _selectedChecklist.contains(item['id']),
                      )
                      .length,
                  total: _preopChecklist
                      .where((item) => item['required'] == true)
                      .length,
                  color: Colors.blue,
                ),
                _buildMiniProgressCard(
                  label: 'Anaesthesia',
                  completed: _anaesthesiaChecklistItems
                      .where(
                        (item) =>
                            item['required'] == true &&
                            _anaesthesiaChecklist.contains(item['id']),
                      )
                      .length,
                  total: _anaesthesiaChecklistItems
                      .where((item) => item['required'] == true)
                      .length,
                  color: Colors.purple,
                ),
                _buildMiniProgressCard(
                  label: 'Cardiac',
                  completed: _cardiacChecklist
                      .where(
                        (item) =>
                            item['required'] == true &&
                            _cardiacChecklistSelected.contains(item['id']),
                      )
                      .length,
                  total: _cardiacChecklist
                      .where((item) => item['required'] == true)
                      .length,
                  color: Colors.red,
                ),
                _buildMiniProgressCard(
                  label: 'Respiratory',
                  completed: _respiratoryChecklist
                      .where(
                        (item) =>
                            item['required'] == true &&
                            _respiratoryChecklistSelected.contains(item['id']),
                      )
                      .length,
                  total: _respiratoryChecklist
                      .where((item) => item['required'] == true)
                      .length,
                  color: Colors.green,
                ),
                _buildMiniProgressCard(
                  label: 'Laboratory',
                  completed: _labChecklist
                      .where(
                        (item) =>
                            item['required'] == true &&
                            _labChecklistSelected.contains(item['id']),
                      )
                      .length,
                  total: _labChecklist
                      .where((item) => item['required'] == true)
                      .length,
                  color: Colors.orange,
                ),
              ],
            ),

            if (!isComplete) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete all required items to confirm surgery',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniProgressCard({
    required String label,
    required int completed,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? completed / total : 0.0;
    final isComplete = percentage == 1.0;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : color,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed/$total',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Icon(
                isComplete ? Icons.check_circle : Icons.circle,
                size: 10,
                color: isComplete ? Colors.green : color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Appointment Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'After completing preoperative assessment:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    label: 'CONFIRM',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    status: 'confirm',
                    description: 'Patient is cleared for surgery',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusButton(
                    label: 'POSTPONE',
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                    status: 'postpone',
                    description: 'Delay surgery for further evaluation',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusButton(
                    label: 'CANCEL',
                    icon: Icons.cancel,
                    color: Colors.red,
                    status: 'cancel',
                    description: 'Cancel this surgical procedure',
                  ),
                ),
              ],
            ),
            if (_selectedStatus != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_selectedStatus!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(_selectedStatus!).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(_selectedStatus!),
                      color: _getStatusColor(_selectedStatus!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current Status: ${_selectedStatus!.toUpperCase()}',
                        style: TextStyle(
                          color: _getStatusColor(_selectedStatus!),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required IconData icon,
    required Color color,
    required String status,
    required String description,
  }) {
    return InkWell(
      onTap: () => _updateAppointmentStatus(status),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedStatus == status ? color : Colors.transparent,
            width: _selectedStatus == status ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirm':
        return Icons.check_circle;
      case 'postpone':
        return Icons.calendar_today;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _savePreopAssessment,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, size: 20),
              label: Text(
                _isSubmitting ? 'SAVING...' : 'SAVE ASSESSMENT',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {
              // Clear form
              _historyController.clear();
              _examController.clear();
              _instructionsController.clear();
              setState(() {
                _selectedChecklist = [];
                _selectedStatus = null;
              });
            },
            icon: const Icon(Icons.clear_all, size: 20),
            label: const Text('CLEAR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichTextEditor(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 6,
            minLines: 4,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: 'Enter details here...',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFormatButton(Icons.format_bold, 'Bold', () {}),
            _buildFormatButton(Icons.format_italic, 'Italic', () {}),
            _buildFormatButton(Icons.format_list_bulleted, 'List', () {}),
            const Spacer(),
            Text(
              '${controller.text.length} characters',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onTap,
      tooltip: tooltip,
      color: Colors.grey,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 32,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preoperative Assessment',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Patient ID: ${widget.patientId}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'PREOP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 1. Overall Summary
          // _buildSummaryCard(),

          // 2. General Preoperative Checklist (existing)
          _buildChecklistSection(
            title: 'General Preoperative Checklist',
            icon: Icons.checklist,
            color: Colors.blue,
            checklist: _preopChecklist,
            selectedItems: _selectedChecklist,
            onSelectionChanged: (newList) {
              setState(() {
                _selectedChecklist = newList;
              });
            },
            description: 'General surgical preparation requirements',
          ),

          // 2. Anaesthesia Assessment (NEW)
          _buildAnaesthesiaAssessmentSection(),
          // 4. Cardiac Assessment
          // _buildChecklistSection(
          //   title: 'Cardiac Assessment',
          //   icon: Icons.favorite,
          //   color: Colors.red,
          //   checklist: _cardiacChecklist,
          //   selectedItems: _cardiacChecklistSelected,
          //   onSelectionChanged: (newList) {
          //     setState(() {
          //       _cardiacChecklistSelected = newList;
          //     });
          //   },
          //   description: 'Cardiovascular system evaluation',
          // ),

          // 5. Respiratory Assessment
          // _buildChecklistSection(
          //   title: 'Respiratory Assessment',
          //   icon: Icons.air,
          //   color: Colors.green,
          //   checklist: _respiratoryChecklist,
          //   selectedItems: _respiratoryChecklistSelected,
          //   onSelectionChanged: (newList) {
          //     setState(() {
          //       _respiratoryChecklistSelected = newList;
          //     });
          //   },
          //   description: 'Pulmonary system evaluation',
          // ),

          // 6. Laboratory Assessment
          // _buildLaboratorySection(),
          // 7. Medical History
          _buildSection(
            title: 'Medical History',
            icon: Icons.history,
            color: Colors.purple,
            required: true,
            child: _buildRichTextEditor(
              'Relevant medical history for surgery',
              _historyController,
              _historyFocusNode,
            ),
          ),

          // Physical Examination
          _buildSection(
            title: 'Physical Examination',
            icon: Icons.medical_information,
            color: Colors.green,
            required: true,
            child: _buildRichTextEditor(
              'Findings from physical examination',
              _examController,
              _examFocusNode,
            ),
          ),

          // Instructions to Wards
          _buildSection(
            title: 'Instructions to Wards',
            icon: Icons.note_add,
            color: Colors.orange,
            required: false,
            child: _buildRichTextEditor(
              'Special instructions for nursing staff',
              _instructionsController,
              _instructionsFocusNode,
            ),
          ),

          // Status Update Buttons
          _buildStatusButtons(),

          // Action Buttons
          _buildActionButtons(),

          // Footer Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: This preoperative assessment must be completed and signed by the on duty Anaethesiologist before proceeding with surgery.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _historyController.dispose();
    _examController.dispose();
    _instructionsController.dispose();
    _historyFocusNode.dispose();
    _examFocusNode.dispose();
    _instructionsFocusNode.dispose();
    super.dispose();
  }
}
