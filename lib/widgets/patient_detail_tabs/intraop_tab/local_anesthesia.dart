import 'package:ams/widgets/patient_detail_tabs/intraop_tab.dart';
import 'package:flutter/material.dart';

class LocalAnesthesiaSection extends StatefulWidget {
  final String patientId;
  final List<AnesthesiaRecord> records;
  final Function(AnesthesiaRecord) onAddRecord;
  final Function(int) onDeleteRecord;
  final Function(int, AnesthesiaRecord) onUpdateRecord;
  final DateTime? anesthesiaStartTime;
  final DateTime? surgeryStartTime;
  final VoidCallback onStartSurgery;

  const LocalAnesthesiaSection({
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
  State<LocalAnesthesiaSection> createState() => _LocalAnesthesiaSectionState();
}

class _LocalAnesthesiaSectionState extends State<LocalAnesthesiaSection> {
  // Local anesthesia drugs
  final TextEditingController lignocaineController = TextEditingController();
  final TextEditingController bupivacaineController = TextEditingController();
  final TextEditingController adrenalineController = TextEditingController();
  final TextEditingController otherDrugsController = TextEditingController();
  
  // Current vital signs (with sliders)
  int hr = 80;
  int sbp = 120;
  int dbp = 80;
  int rr = 12;
  int spo2 = 98;
  double temp = 36.5;
  
  // Drug dropdown
  String? selectedDrugType;
  final List<String> drugTypes = [
    'Lignocaine',
    'Bupivacaine',
    'Ropivacaine',
    'Prilocaine',
    'Articaine',
    'Mepivacaine',
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
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
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
                Icon(Icons.timeline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Timeline Monitoring',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue[900],
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
                                      color: Colors.blue,
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
                                    icon: Icon(Icons.delete, size: 18, color: Colors.red[300]),
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
                            ],
                          ),
                          
                          // Drug info
                          if (record.drugName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
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
        // Local Anesthesia Details
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Local Anesthesia Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Local anesthesia drugs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Local Anesthetic Drugs', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lignocaineController,
                            decoration: const InputDecoration(
                              labelText: 'Lignocaine (%)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 1%',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: bupivacaineController,
                            decoration: const InputDecoration(
                              labelText: 'Bupivacaine (%)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 0.5%',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: adrenalineController,
                            decoration: const InputDecoration(
                              labelText: 'Adrenaline Added',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 1:200,000',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: otherDrugsController,
                      decoration: const InputDecoration(
                        labelText: 'Other Drugs',
                        border: OutlineInputBorder(),
                        hintText: 'Enter other medications used',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Vital signs monitoring with sliders
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vital Signs Monitoring', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
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
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Drug administration with dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Drug Administration', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedDrugType,
                            decoration: const InputDecoration(
                              labelText: 'Drug Type',
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: drugDoseController,
                            decoration: const InputDecoration(
                              labelText: 'Dose',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 50mg',
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
                  ],
                ),
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _addRecord,
                    icon: const Icon(Icons.add_chart),
                    label: const Text('Record Vital Signs'),
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
    lignocaineController.dispose();
    bupivacaineController.dispose();
    adrenalineController.dispose();
    otherDrugsController.dispose();
    drugDoseController.dispose();
    drugRouteController.dispose();
    super.dispose();
  }
}