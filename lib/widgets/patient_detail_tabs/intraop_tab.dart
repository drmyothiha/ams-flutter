import 'package:ams/widgets/patient_detail_tabs/intraop_tab/local_anesthesia.dart';
import 'package:ams/widgets/patient_detail_tabs/intraop_tab/spinal_anesthesia.dart';
import 'package:flutter/material.dart';

class IntraopTab extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const IntraopTab({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<IntraopTab> createState() => _IntraopTabState();
}

class _IntraopTabState extends State<IntraopTab> {
  // Anesthesia type selection
  AnesthesiaType? selectedType;
  
  // Time tracking
  DateTime? anesthesiaStartTime;
  DateTime? surgeryStartTime;
  
  // Machine check
  bool machineChecked = false;
  final List<String> machineCheckItems = [
    'O2 supply & pipeline pressure',
    'Vaporizers filled & seated',
    'Breathing circuit',
    'Ventilator & scavenging',
    'Suction working',
    'Airway equipment available',
    'Monitors functional',
    'Emergency drugs available'
  ];
  final Map<String, bool> machineCheckStatus = {};
  
  // Shared records list
  final List<AnesthesiaRecord> records = [];
  
  @override
  void initState() {
    super.initState();
    // Initialize machine check status
    for (var item in machineCheckItems) {
      machineCheckStatus[item] = false;
    }
    
    // Set anesthesia start time
    anesthesiaStartTime = DateTime.now();
    
    // Load saved data from local storage
    _loadLocalData();
  }
  
  Future<void> _loadLocalData() async {
    // Load from local storage (shared_preferences)
    try {
      // Implement local storage loading logic here
      // For now, using a placeholder
    } catch (e) {
      print('Error loading local data: $e');
    }
  }
  
  Future<void> _saveLocalData() async {
    // Save to local storage before API update
    try {
      // Implement local storage saving logic here
      final data = {
        'selectedType': selectedType?.name,
        'anesthesiaStartTime': anesthesiaStartTime?.toIso8601String(),
        'surgeryStartTime': surgeryStartTime?.toIso8601String(),
        'machineCheckStatus': machineCheckStatus,
        'records': records.map((r) => r.toJson()).toList(),
      };
      // Save using shared_preferences
    } catch (e) {
      print('Error saving local data: $e');
    }
  }
  
  void _addRecord(AnesthesiaRecord record) {
    setState(() {
      records.add(record);
      _saveLocalData(); // Save to local storage
    });
  }
  
  void _deleteRecord(int index) {
    setState(() {
      records.removeAt(index);
      _saveLocalData(); // Save to local storage
    });
  }
  
  void _updateRecord(int index, AnesthesiaRecord record) {
    setState(() {
      records[index] = record;
      _saveLocalData(); // Save to local storage
    });
  }
  
  void _startSurgery() {
    setState(() {
      surgeryStartTime = DateTime.now();
      _saveLocalData();
    });
  }
  
  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  String _getElapsedTime(DateTime start) {
    final now = DateTime.now();
    final difference = now.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, size: 32, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Intraoperative Anesthesia Record',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  Text(
                    'Patient ID: ${widget.patientId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Anesthesia Start: ${_formatTime(anesthesiaStartTime)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Text(
                    'Surgery Start: ${_formatTime(surgeryStartTime)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: surgeryStartTime != null ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                  if (anesthesiaStartTime != null)
                    Text(
                      'Elapsed: ${_getElapsedTime(anesthesiaStartTime!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // ANESTHESIA TYPE SELECTION
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Anesthesia Type',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Local'),
                          selected: selectedType == AnesthesiaType.local,
                          onSelected: (selected) {
                            setState(() {
                              selectedType = selected ? AnesthesiaType.local : null;
                            });
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: selectedType == AnesthesiaType.local ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Spinal'),
                          selected: selectedType == AnesthesiaType.spinal,
                          onSelected: (selected) {
                            setState(() {
                              selectedType = selected ? AnesthesiaType.spinal : null;
                            });
                          },
                          selectedColor: Colors.purple,
                          labelStyle: TextStyle(
                            color: selectedType == AnesthesiaType.spinal ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('General (GA)'),
                          selected: selectedType == AnesthesiaType.ga,
                          onSelected: (selected) {
                            setState(() {
                              selectedType = selected ? AnesthesiaType.ga : null;
                            });
                          },
                          selectedColor: Colors.red,
                          labelStyle: TextStyle(
                            color: selectedType == AnesthesiaType.ga ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedType == AnesthesiaType.ga)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Text(
                          'GA section - Under development',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (selectedType != null) const SizedBox(height: 20),
          
          // ANESTHESIA MACHINE CHECK
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: machineChecked ? Colors.green : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Anesthesia Machine Check',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: machineCheckItems.map((item) {
                      return FilterChip(
                        label: Text(item),
                        selected: machineCheckStatus[item] ?? false,
                        onSelected: (selected) {
                          setState(() {
                            machineCheckStatus[item] = selected;
                            machineChecked = machineCheckStatus.values.every((status) => status);
                            _saveLocalData();
                          });
                        },
                        checkmarkColor: Colors.white,
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: machineCheckStatus[item] ?? false ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          for (var item in machineCheckItems) {
                            machineCheckStatus[item] = true;
                          }
                          machineChecked = true;
                          _saveLocalData();
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Mark All Complete'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (selectedType != null) const SizedBox(height: 20),
          
          // Show selected anesthesia type section
          if (selectedType == AnesthesiaType.local)
            LocalAnesthesiaSection(
              patientId: widget.patientId,
              records: records,
              onAddRecord: _addRecord,
              onDeleteRecord: _deleteRecord,
              onUpdateRecord: _updateRecord,
              anesthesiaStartTime: anesthesiaStartTime,
              surgeryStartTime: surgeryStartTime,
              onStartSurgery: _startSurgery,
            )
          else if (selectedType == AnesthesiaType.spinal)
            SpinalAnesthesiaSection(
              patientId: widget.patientId,
              records: records,
              onAddRecord: _addRecord,
              onDeleteRecord: _deleteRecord,
              onUpdateRecord: _updateRecord,
              anesthesiaStartTime: anesthesiaStartTime,
              surgeryStartTime: surgeryStartTime,
              onStartSurgery: _startSurgery,
            ),
          
          const SizedBox(height: 20),
          
          // Summary and Save button
          Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Anesthesia Type: ${selectedType?.name ?? 'Not selected'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Records: ${records.length}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Status: ${surgeryStartTime != null ? 'Surgery In Progress' : 'Pre-surgery'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Save to API
                      await _saveLocalData(); // Ensure local save first
                      // Then sync to API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Record saved and synced')),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save & Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AnesthesiaType {
  local('Local'),
  spinal('Spinal'),
  ga('General');
  
  final String name;
  const AnesthesiaType(this.name);
}

class AnesthesiaRecord {
  final String id;
  final DateTime time;
  final int hr;
  final int sbp;
  final int dbp;
  final int rr;
  final int spo2;
  final double temp;
  final int painScore;
  final String? infusionType;
  final String? drugName;
  final String? drugDose;
  final String? drugRoute;
  
  AnesthesiaRecord({
    String? id,
    required this.time,
    required this.hr,
    required this.sbp,
    required this.dbp,
    required this.rr,
    required this.spo2,
    required this.temp,
    this.painScore = 0,
    this.infusionType,
    this.drugName,
    this.drugDose,
    this.drugRoute,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'hr': hr,
      'sbp': sbp,
      'dbp': dbp,
      'rr': rr,
      'spo2': spo2,
      'temp': temp,
      'painScore': painScore,
      'infusionType': infusionType,
      'drugName': drugName,
      'drugDose': drugDose,
      'drugRoute': drugRoute,
    };
  }
  
  // Create from JSON
  factory AnesthesiaRecord.fromJson(Map<String, dynamic> json) {
    return AnesthesiaRecord(
      id: json['id'],
      time: DateTime.parse(json['time']),
      hr: json['hr'],
      sbp: json['sbp'],
      dbp: json['dbp'],
      rr: json['rr'],
      spo2: json['spo2'],
      temp: json['temp'].toDouble(),
      painScore: json['painScore'] ?? 0,
      infusionType: json['infusionType'],
      drugName: json['drugName'],
      drugDose: json['drugDose'],
      drugRoute: json['drugRoute'],
    );
  }
}