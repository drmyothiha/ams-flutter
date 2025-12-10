import 'package:ams/widgets/patient_detail_tabs/intraop_tab.dart';
import 'package:flutter/material.dart';

class SpinalAnesthesiaSection extends StatefulWidget {
  final String patientId;
  final List<AnesthesiaRecord> records;
  final Function(AnesthesiaRecord) onAddRecord;
  final Function(int) onDeleteRecord;
  final Function(int, AnesthesiaRecord) onUpdateRecord;
  final DateTime? anesthesiaStartTime;
  final DateTime? surgeryStartTime;
  final VoidCallback onStartSurgery;
  final Map<String, dynamic> spinalDrugs;
  final Map<String, dynamic> spinalProcedure;
  final Function(String, dynamic) onUpdateSpinalDrugs;
  final Function(String, dynamic) onUpdateSpinalProcedure;

  const SpinalAnesthesiaSection({
    super.key,
    required this.patientId,
    required this.records,
    required this.onAddRecord,
    required this.onDeleteRecord,
    required this.onUpdateRecord,
    required this.anesthesiaStartTime,
    required this.surgeryStartTime,
    required this.onStartSurgery,
    required this.spinalDrugs,
    required this.spinalProcedure,
    required this.onUpdateSpinalDrugs,
    required this.onUpdateSpinalProcedure,
  });

  @override
  State<SpinalAnesthesiaSection> createState() => _SpinalAnesthesiaSectionState();
}

class _SpinalAnesthesiaSectionState extends State<SpinalAnesthesiaSection> {
  // Current vital signs (with sliders)
  int hr = 80;
  int sbp = 120;
  int dbp = 80;
  int rr = 12;
  int spo2 = 98;
  double temp = 36.5;
  int painScore = 0;
  
  // Infusion
  String? infusionType;
  final List<String> infusionTypes = ['None', 'NS', 'RL', 'HES', 'Blood', 'Other'];
  
  // THREE DRUG INPUTS
  final List<DrugInput> drugInputs = [
    DrugInput(
      defaultName: 'Ondansetron',
      defaultDosage: '4',
      defaultRoute: 'IV',
    ),
    DrugInput(
      defaultName: 'Midazolam',
      defaultDosage: '2',
      defaultRoute: 'IV',
    ),
    DrugInput(
      defaultName: 'Ephedrine',
      defaultDosage: '6',
      defaultRoute: 'IV',
    ),
  ];
  
  // Additional drug options
  final List<String> drugOptions = [
    'Ondansetron',
    'Midazolam',
    'Ephedrine',
    'Fentanyl',
    'Morphine',
    'Diamorphine',
    'Ketamine',
    'Propofol',
    'Atropine',
    'Glycopyrrolate',
    'Dexamethasone',
    'Metoclopramide',
    'Phenylephrine',
    'Others'
  ];
  
  @override
  void initState() {
    super.initState();
    // Load any previously saved drug inputs
    _loadDrugInputsFromStorage();
  }
  
  void _loadDrugInputsFromStorage() {
    // Load drug inputs from shared preferences or use defaults
    // This could be enhanced to load from previous records
  }
  
  void _addRecord() {
  // Collect all drugs that have a name
  final administeredDrugs = <DrugAdministered>[];
  
  for (final drugInput in drugInputs) {
    if (drugInput.name.isNotEmpty && drugInput.dosage.isNotEmpty) {
      administeredDrugs.add(DrugAdministered(
        drugName: drugInput.name,
        dosage: drugInput.dosage,
        route: drugInput.route,
      ));
    }
  }
  
  // Check if there's a fourth "other" drug
  if (widget.spinalDrugs['otherDrug'] != null && 
      widget.spinalDrugs['otherDrug'].toString().isNotEmpty &&
      widget.spinalDrugs['otherDrugDose'] != null &&
      widget.spinalDrugs['otherDrugDose'].toString().isNotEmpty) {
    administeredDrugs.add(DrugAdministered(
      drugName: widget.spinalDrugs['otherDrug'].toString(),
      dosage: widget.spinalDrugs['otherDrugDose'].toString(),
      route: widget.spinalDrugs['otherDrugRoute']?.toString() ?? 'IV',
    ));
  }
  
  final record = AnesthesiaRecord(
    time: DateTime.now(),
    hr: hr,
    sbp: sbp,
    dbp: dbp,
    rr: rr,
    spo2: spo2,
    temp: temp,
    painScore: painScore,
    infusionType: infusionType != 'None' ? infusionType : null,
    drugsAdministered: administeredDrugs, // Add this required parameter
  );
  
  widget.onAddRecord(record);
  
  // Clear drug inputs after recording
  _clearDrugInputs();
}
  
  void _clearDrugInputs() {
    setState(() {
      for (final drugInput in drugInputs) {
        drugInput.dosageController.clear();
        drugInput.name = drugInput.defaultName;
        drugInput.dosage = drugInput.defaultDosage;
        drugInput.route = drugInput.defaultRoute;
      }
      widget.spinalDrugs['otherDrug'] = '';
      widget.spinalDrugs['otherDrugDose'] = '';
      widget.spinalDrugs['otherDrugRoute'] = 'IV';
      widget.onUpdateSpinalDrugs('otherDrug', '');
      widget.onUpdateSpinalDrugs('otherDrugDose', '');
      widget.onUpdateSpinalDrugs('otherDrugRoute', 'IV');
    });
  }
  
  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  Widget _buildVitalSlider(String label, dynamic value, dynamic min, dynamic max, dynamic divisions, Function(dynamic) onChanged) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  if (value is int && value > min) onChanged(value - 1);
                },
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: divisions,
                  onChanged: (newValue) {
                    if (value is int) {
                      onChanged(newValue.round());
                    } else if (value is double) {
                      onChanged(double.parse(newValue.toStringAsFixed(1)));
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  if (value is int && value < max) onChanged(value + 1);
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPainScoreSlider() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          const Text(
            'Pain Score (0-10)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Slider(
            value: painScore.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$painScore',
            onChanged: (value) {
              setState(() {
                painScore = value.toInt();
              });
            },
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepOrange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepOrange),
            ),
            child: Center(
              child: Text(
                '$painScore',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Timeline Monitoring',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.purple[900],
                  ),
                ),
                const Spacer(),
                if (widget.surgeryStartTime == null)
                  ElevatedButton.icon(
                    onPressed: widget.onStartSurgery,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Surgery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (widget.records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.timeline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No monitoring records yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        'Add vital signs to start monitoring',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: widget.records.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  final isEven = index % 2 == 0;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.grey[50] : Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time header with delete button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(record.time),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (index == widget.records.length - 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.circle, size: 8, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text('LATEST', style: TextStyle(fontSize: 10, color: Colors.green)),
                                        ],
                                      ),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteDialog(index);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Vital signs badges
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildVitalBadge('HR', '${record.hr} bpm', Colors.pink),
                              _buildVitalBadge('BP', '${record.sbp}/${record.dbp}', Colors.red),
                              _buildVitalBadge('RR', '${record.rr} /min', Colors.orange),
                              _buildVitalBadge('SpO₂', '${record.spo2}%', Colors.blue),
                              _buildVitalBadge('Temp', '${record.temp}°C', Colors.purple),
                              _buildVitalBadge('Pain', '${record.painScore}/10', Colors.deepOrange),
                            ],
                          ),
                          
                          // Infusion
                          if (record.infusionType != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(
                                  'Infusion: ${record.infusionType}',
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ),
                            ),
                          
                          // Drugs administered
                          if (record.drugsAdministered.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Drugs Administered:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: record.drugsAdministered.map((drug) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.green),
                                        ),
                                        child: Text(
                                          '${drug.drugName} ${drug.dosage} ${drug.route}',
                                          style: const TextStyle(fontSize: 12, color: Colors.green),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVitalBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteRecord(index);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrugInput(int index, DrugInput drugInput) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drug ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: drugInput.name,
                  decoration: const InputDecoration(
                    labelText: 'Drug Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  items: drugOptions.map((drug) {
                    return DropdownMenuItem(
                      value: drug,
                      child: Text(drug, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      drugInput.name = value ?? drugInput.defaultName;
                      // Update default dosage based on drug
                      if (value == 'Ondansetron') drugInput.dosage = '4';
                      if (value == 'Midazolam') drugInput.dosage = '2';
                      if (value == 'Ephedrine') drugInput.dosage = '6';
                      drugInput.dosageController.text = drugInput.dosage;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: drugInput.dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dose',
                    border: const OutlineInputBorder(),
                    suffixText: _getDoseUnit(drugInput.name),
                  ),
                  onChanged: (value) {
                    drugInput.dosage = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: TextEditingController(text: drugInput.route),
                  decoration: const InputDecoration(
                    labelText: 'Route',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    drugInput.route = value;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getDoseUnit(String drugName) {
    switch (drugName) {
      case 'Ondansetron':
      case 'Midazolam':
      case 'Dexamethasone':
        return 'mg';
      case 'Ephedrine':
      case 'Phenylephrine':
        return 'mg';
      case 'Fentanyl':
      case 'Morphine':
      case 'Diamorphine':
        return 'mcg';
      case 'Ketamine':
        return 'mg';
      case 'Propofol':
        return 'mg';
      case 'Atropine':
      case 'Glycopyrrolate':
        return 'mg';
      default:
        return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Spinal Anesthesia Details
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Spinal Anesthesia Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.purple[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Spinal drugs section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drugs Administered', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text: widget.spinalDrugs['heavyBupivacaine']?.toString() ?? ''
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Heavy Bupivacaine (mg)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 12.5',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              widget.onUpdateSpinalDrugs('heavyBupivacaine', value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text: widget.spinalDrugs['spinalAdditive']?.toString() ?? 'Fentanyl'
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Spinal Additive',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              widget.onUpdateSpinalDrugs('spinalAdditive', value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: TextEditingController(
                              text: widget.spinalDrugs['spinalAdditiveDose']?.toString() ?? '20'
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Dose (mcg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              widget.onUpdateSpinalDrugs('spinalAdditiveDose', value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Procedure section
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Procedure Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    // Needle size
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spinal Needle Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['23', '24', '25', '26'].map((size) {
                            return ChoiceChip(
                              label: Text('${size}G'),
                              selected: widget.spinalProcedure['needleSize'] == size,
                              onSelected: (selected) {
                                widget.onUpdateSpinalProcedure('needleSize', selected ? size : null);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    // Epidural needle size
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Epidural Needle Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['18', '19'].map((size) {
                            return ChoiceChip(
                              label: Text('${size}G'),
                              selected: widget.spinalProcedure['epiduralNeedleSize'] == size,
                              onSelected: (selected) {
                                widget.onUpdateSpinalProcedure('epiduralNeedleSize', selected ? size : null);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    // Epidural catheter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: widget.spinalProcedure['epiduralCatheter'] == true,
                              onChanged: (value) {
                                widget.onUpdateSpinalProcedure('epiduralCatheter', value ?? false);
                              },
                            ),
                            const Text('Epidural Catheter Placed'),
                          ],
                        ),
                      ],
                    ),
                    
                    // Spinal space
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spinal Space:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['L2-3', 'L3-4', 'L4-5'].map((space) {
                            return ChoiceChip(
                              label: Text(space),
                              selected: widget.spinalProcedure['spinalSpace'] == space,
                              onSelected: (selected) {
                                widget.onUpdateSpinalProcedure('spinalSpace', selected ? space : null);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    // Epidural space
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Epidural Space:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['Thoracic', 'Lumbar', 'Caudal'].map((space) {
                            return ChoiceChip(
                              label: Text(space),
                              selected: widget.spinalProcedure['epiduralSpace'] == space,
                              onSelected: (selected) {
                                widget.onUpdateSpinalProcedure('epiduralSpace', selected ? space : null);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    // Position
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Patient Position:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Sitting'),
                              selected: widget.spinalProcedure['position'] == 'Sitting',
                              onSelected: (selected) {
                                widget.onUpdateSpinalProcedure('position', 'Sitting');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Lying'),
                              selected: widget.spinalProcedure['position'] == 'Lying',
                              onSelected: (selected) {
                                widget.onUpdateSpinalProcedure('position', 'Lying');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Monitoring input section with 3 drug inputs
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Monitoring Record', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                
                // Pain score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPainScoreSlider(),
                    const SizedBox(height: 16),
                  ],
                ),
                
                // Vital signs sliders
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildVitalSlider('HR', hr, 40, 200, 16, (value) {
                      setState(() => hr = value);
                    }),
                    _buildVitalSlider('SBP', sbp, 60, 250, 19, (value) {
                      setState(() => sbp = value);
                    }),
                    _buildVitalSlider('DBP', dbp, 40, 150, 11, (value) {
                      setState(() => dbp = value);
                    }),
                    _buildVitalSlider('RR', rr, 8, 40, 32, (value) {
                      setState(() => rr = value);
                    }),
                    _buildVitalSlider('SpO₂', spo2, 70, 100, 30, (value) {
                      setState(() => spo2 = value);
                    }),
                    _buildVitalSlider('Temp', temp, 35.0, 40.0, 50, (value) {
                      setState(() => temp = value);
                    }),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // THREE DRUG INPUTS
                Text('Drugs Administration (Simultaneous)', 
                  style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                
                Column(
                  children: drugInputs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final drugInput = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildDrugInput(index, drugInput),
                    );
                  }).toList(),
                ),
                
                // Additional "Other Drug" input
                Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Drug (if needed)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  text: widget.spinalDrugs['otherDrug']?.toString() ?? ''
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Other Drug Name',
                                  border: OutlineInputBorder(),
                                  hintText: 'e.g., Dexamethasone',
                                ),
                                onChanged: (value) {
                                  widget.onUpdateSpinalDrugs('otherDrug', value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  text: widget.spinalDrugs['otherDrugDose']?.toString() ?? ''
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Dose',
                                  border: OutlineInputBorder(),
                                  hintText: 'e.g., 8mg',
                                ),
                                onChanged: (value) {
                                  widget.onUpdateSpinalDrugs('otherDrugDose', value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: TextEditingController(
                                  text: widget.spinalDrugs['otherDrugRoute']?.toString() ?? 'IV'
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Route',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  widget.onUpdateSpinalDrugs('otherDrugRoute', value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Infusion dropdown
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: infusionType,
                        decoration: const InputDecoration(
                          labelText: 'Infusion Type',
                          border: OutlineInputBorder(),
                        ),
                        items: infusionTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            infusionType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _addRecord,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Monitoring Record'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Timeline table
        _buildTimelineTable(),
      ],
    );
  }
}

class DrugInput {
  String name;
  String dosage;
  String route;
  final String defaultName;
  final String defaultDosage;
  final String defaultRoute;
  final TextEditingController dosageController = TextEditingController();
  
  DrugInput({
    required this.defaultName,
    required this.defaultDosage,
    required this.defaultRoute,
  }) : name = defaultName,
       dosage = defaultDosage,
       route = defaultRoute {
    dosageController.text = defaultDosage;
  }
}