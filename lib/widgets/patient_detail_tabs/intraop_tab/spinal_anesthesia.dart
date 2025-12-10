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
  });

  @override
  State<SpinalAnesthesiaSection> createState() => _SpinalAnesthesiaSectionState();
}

class _SpinalAnesthesiaSectionState extends State<SpinalAnesthesiaSection> {
  // Spinal drugs
  final TextEditingController heavyBupivacaineController = TextEditingController();
  final TextEditingController spinalAdditiveController = TextEditingController(text: 'Fentanyl');
  final TextEditingController spinalAdditiveDoseController = TextEditingController(text: '20');
  final TextEditingController ondansetronController = TextEditingController();
  final TextEditingController ephedrineController = TextEditingController();
  final TextEditingController phenylpherineController = TextEditingController();
  
  // Procedure details
  String? selectedNeedleSize;
  String? selectedEpiduralNeedleSize;
  bool epiduralCatheter = false;
  String? selectedSpinalSpace;
  String? selectedEpiduralSpace;
  String position = 'Lying';
  
  // Current vital signs (with sliders)
  int hr = 80;
  int sbp = 120;
  int dbp = 80;
  int rr = 12;
  int spo2 = 98;
  double temp = 36.5;
  int painScore = 0;
  
  // Infusion and drug dropdowns
  String? infusionType;
  final List<String> infusionTypes = ['None', 'NS', 'RL', 'HES', 'Blood', 'Other'];
  
  String? selectedDrugType;
  final List<String> drugTypes = [
    'Fentanyl',
    'Morphine',
    'Diamorphine',
    'Midazolam',
    'Ketamine',
    'Propofol',
    'Others'
  ];
  
  final TextEditingController drugDoseController = TextEditingController();
  final TextEditingController drugRouteController = TextEditingController();
  
  void _addRecord() {
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
      drugName: selectedDrugType,
      drugDose: drugDoseController.text.isNotEmpty ? drugDoseController.text : null,
      drugRoute: drugRouteController.text.isNotEmpty ? drugRouteController.text : null,
    );
    
    widget.onAddRecord(record);
    
    // Clear drug inputs
    setState(() {
      selectedDrugType = null;
      drugDoseController.clear();
      drugRouteController.clear();
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
                  if (value is int) {
                    if (value > min) onChanged(value - 1);
                  } else if (value is double) {
                    if (value > min) onChanged(value - 0.1);
                  }
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
                  if (value is int) {
                    if (value < max) onChanged(value + 1);
                  } else if (value is double) {
                    if (value < max) onChanged(value + 0.1);
                  }
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
                          
                          // Infusion and drug info
                          if (record.infusionType != null || record.drugName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (record.infusionType != null)
                                    Container(
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
                                  if (record.drugName != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: Text(
                                        '${record.drugName} ${record.drugDose ?? ''} ${record.drugRoute ?? ''}',
                                        style: const TextStyle(fontSize: 12, color: Colors.green),
                                      ),
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
                            controller: heavyBupivacaineController,
                            decoration: const InputDecoration(
                              labelText: 'Heavy Bupivacaine (mg)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 12.5',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: spinalAdditiveController,
                            decoration: const InputDecoration(
                              labelText: 'Spinal Additive',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: spinalAdditiveDoseController,
                            decoration: const InputDecoration(
                              labelText: 'Dose (mcg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ondansetronController,
                            decoration: const InputDecoration(
                              labelText: 'Ondansetron (mg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: ephedrineController,
                            decoration: const InputDecoration(
                              labelText: 'Ephedrine (mg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: phenylpherineController,
                            decoration: const InputDecoration(
                              labelText: 'Phenylpherine (mcg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
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
                              selected: selectedNeedleSize == size,
                              onSelected: (selected) {
                                setState(() {
                                  selectedNeedleSize = selected ? size : null;
                                });
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
                              selected: selectedEpiduralNeedleSize == size,
                              onSelected: (selected) {
                                setState(() {
                                  selectedEpiduralNeedleSize = selected ? size : null;
                                });
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
                              value: epiduralCatheter,
                              onChanged: (value) {
                                setState(() {
                                  epiduralCatheter = value ?? false;
                                });
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
                              selected: selectedSpinalSpace == space,
                              onSelected: (selected) {
                                setState(() {
                                  selectedSpinalSpace = selected ? space : null;
                                });
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
                              selected: selectedEpiduralSpace == space,
                              onSelected: (selected) {
                                setState(() {
                                  selectedEpiduralSpace = selected ? space : null;
                                });
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
                              selected: position == 'Sitting',
                              onSelected: (selected) {
                                setState(() {
                                  position = 'Sitting';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Lying'),
                              selected: position == 'Lying',
                              onSelected: (selected) {
                                setState(() {
                                  position = 'Lying';
                                });
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
        
        // Monitoring input section
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
                
                const SizedBox(height: 16),
                
                // Infusion and drug dropdowns
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDrugType,
                        decoration: const InputDecoration(
                          labelText: 'Additional Drug',
                          border: OutlineInputBorder(),
                        ),
                        items: drugTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDrugType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Drug dose and route
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: drugDoseController,
                        decoration: const InputDecoration(
                          labelText: 'Drug Dose',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 50mcg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: drugRouteController,
                        decoration: const InputDecoration(
                          labelText: 'Route',
                          border: OutlineInputBorder(),
                          hintText: 'IV',
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _addRecord,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Monitoring Record'),
                  ),
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
  
  @override
  void dispose() {
    heavyBupivacaineController.dispose();
    spinalAdditiveController.dispose();
    spinalAdditiveDoseController.dispose();
    ondansetronController.dispose();
    ephedrineController.dispose();
    phenylpherineController.dispose();
    drugDoseController.dispose();
    drugRouteController.dispose();
    super.dispose();
  }
}