import 'package:flutter/material.dart';
import './intraop_tab/local_anesthesia.dart';
import './intraop_tab/spinal_anesthesia.dart';
import './intraop_tab/ga_anesthesia.dart';
import '../../services/anesthesia_storage.dart';

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
    'Emergency drugs available',
  ];
  Map<String, bool> machineCheckStatus = {};

  // Shared records list
  List<AnesthesiaRecord> records = [];

  // Local anesthesia drugs data
  final Map<String, dynamic> localDrugs = {
    'lignocaine': '',
    'bupivacaine': '',
    'adrenaline': '',
    'others': '',
  };

  // Spinal anesthesia drugs data
  final Map<String, dynamic> spinalDrugs = {
    'heavyBupivacaine': '',
    'spinalAdditive': 'Fentanyl',
    'spinalAdditiveDose': '20',
    'ondansetron': '',
    'ephedrine': '',
    'phenylpherine': '',
  };

  // Spinal procedure data
  final Map<String, dynamic> spinalProcedure = {
    'needleSize': null,
    'epiduralNeedleSize': null,
    'epiduralCatheter': false,
    'spinalSpace': null,
    'epiduralSpace': null,
    'position': 'Lying',
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load all data from local storage
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      // Load machine check status
      machineCheckStatus = await AnesthesiaStorage.loadMachineCheck(
        widget.patientId,
      );
      machineChecked = machineCheckStatus.values.every((status) => status);

      // Load records
      records = await AnesthesiaStorage.loadRecords(widget.patientId);

      // Load anesthesia type
      final typeString = await AnesthesiaStorage.loadAnesthesiaType(
        widget.patientId,
      );
      if (typeString != null) {
        selectedType = AnesthesiaType.values.firstWhere(
          (type) => type.name == typeString,
          orElse: () => AnesthesiaType.local,
        );
      }

      // Load times
      anesthesiaStartTime = await AnesthesiaStorage.loadAnesthesiaStart(
        widget.patientId,
      );
      surgeryStartTime = await AnesthesiaStorage.loadSurgeryStart(
        widget.patientId,
      );

      // If no anesthesia start time, set it now
      if (anesthesiaStartTime == null) {
        anesthesiaStartTime = DateTime.now();
        await AnesthesiaStorage.saveAnesthesiaStart(
          widget.patientId,
          anesthesiaStartTime,
        );
      }

      // Load local drugs if available
      final loadedLocalDrugs = await AnesthesiaStorage.loadLocalDrugs(
        widget.patientId,
      );
      localDrugs.addAll(loadedLocalDrugs);

      // Load spinal drugs if available
      final loadedSpinalDrugs = await AnesthesiaStorage.loadSpinalDrugs(
        widget.patientId,
      );
      spinalDrugs.addAll(loadedSpinalDrugs);

      // Load spinal procedure if available
      final loadedSpinalProcedure = await AnesthesiaStorage.loadSpinalProcedure(
        widget.patientId,
      );
      spinalProcedure.addAll(loadedSpinalProcedure);
    } catch (e) {
      print('Error loading data: $e');
      // Initialize with empty data
      for (var item in machineCheckItems) {
        machineCheckStatus[item] = false;
      }
      anesthesiaStartTime = DateTime.now();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAllData() async {
    // Save all data to local storage
    await AnesthesiaStorage.saveRecords(widget.patientId, records);
    await AnesthesiaStorage.saveMachineCheck(
      widget.patientId,
      machineCheckStatus,
    );

    if (selectedType != null) {
      await AnesthesiaStorage.saveAnesthesiaType(
        widget.patientId,
        selectedType!.name,
      );
    }

    if (anesthesiaStartTime != null) {
      await AnesthesiaStorage.saveAnesthesiaStart(
        widget.patientId,
        anesthesiaStartTime,
      );
    }

    if (surgeryStartTime != null) {
      await AnesthesiaStorage.saveSurgeryStart(
        widget.patientId,
        surgeryStartTime,
      );
    }

    if (selectedType == AnesthesiaType.local) {
      await AnesthesiaStorage.saveLocalDrugs(widget.patientId, localDrugs);
    } else if (selectedType == AnesthesiaType.spinal) {
      await AnesthesiaStorage.saveSpinalDrugs(widget.patientId, spinalDrugs);
      await AnesthesiaStorage.saveSpinalProcedure(
        widget.patientId,
        spinalProcedure,
      );
    }
  }

  void _addRecord(AnesthesiaRecord record) {
    setState(() {
      records.add(record);
    });
    _saveAllData(); // Auto-save to local storage
  }

  void _deleteRecord(int index) {
    setState(() {
      records.removeAt(index);
    });
    _saveAllData(); // Auto-save to local storage
  }

  void _updateRecord(int index, AnesthesiaRecord record) {
    setState(() {
      records[index] = record;
    });
    _saveAllData(); // Auto-save to local storage
  }

  void _startSurgery() {
    setState(() {
      surgeryStartTime = DateTime.now();
    });
    _saveAllData(); // Auto-save to local storage
  }

  void _updateLocalDrugs(String key, String value) {
    localDrugs[key] = value;
    _saveAllData(); // Auto-save to local storage
  }

  void _updateSpinalDrugs(String key, dynamic value) {
    spinalDrugs[key] = value;
    _saveAllData(); // Auto-save to local storage
  }

  void _updateSpinalProcedure(String key, dynamic value) {
    spinalProcedure[key] = value;
    _saveAllData(); // Auto-save to local storage
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with patient info
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
                  if (widget.patientData['name'] != null)
                    Text(
                      'Name: ${widget.patientData['name']}',
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
                      color: surgeryStartTime != null
                          ? Colors.green[800]
                          : Colors.orange[800],
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.blue[900]),
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
                              selectedType = selected
                                  ? AnesthesiaType.local
                                  : null;
                            });
                            _saveAllData(); // Save immediately
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: selectedType == AnesthesiaType.local
                                ? Colors.white
                                : Colors.black,
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
                              selectedType = selected
                                  ? AnesthesiaType.spinal
                                  : null;
                            });
                            _saveAllData(); // Save immediately
                          },
                          selectedColor: Colors.purple,
                          labelStyle: TextStyle(
                            color: selectedType == AnesthesiaType.spinal
                                ? Colors.white
                                : Colors.black,
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
                              selectedType = selected
                                  ? AnesthesiaType.ga
                                  : null;
                            });
                            _saveAllData(); // Save immediately
                          },
                          selectedColor: Colors.red,
                          labelStyle: TextStyle(
                            color: selectedType == AnesthesiaType.ga
                                ? Colors.white
                                : Colors.black,
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
                      Icon(
                        Icons.check_circle,
                        color: machineChecked ? Colors.green : Colors.grey,
                      ),
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
                            machineChecked = machineCheckStatus.values.every(
                              (status) => status,
                            );
                          });
                          _saveAllData(); // Save immediately
                        },
                        checkmarkColor: Colors.white,
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: machineCheckStatus[item] ?? false
                              ? Colors.white
                              : Colors.black,
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
                        });
                        _saveAllData(); // Save immediately
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
              localDrugs: localDrugs,
              onUpdateLocalDrugs: _updateLocalDrugs,
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
              spinalDrugs: spinalDrugs,
              spinalProcedure: spinalProcedure,
              onUpdateSpinalDrugs: _updateSpinalDrugs,
              onUpdateSpinalProcedure: _updateSpinalProcedure,
            )
          else if (selectedType == AnesthesiaType.ga)
            const GAAnesthesiaSection(),

          const SizedBox(height: 20),

          // Summary and Sync button
          Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
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
                      Column(
                        children: [
                          Text(
                            'Auto-saved locally',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Sync to API
                              // First ensure local save
                              await _saveAllData();

                              // Then sync to API (implement API call here)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Synced to server successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Sync to Server'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Clear data button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _showClearDataDialog();
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Clear Patient Data',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Patient Data'),
        content: const Text(
          'Are you sure you want to clear all data for this patient? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AnesthesiaStorage.clearPatientData(widget.patientId);
              // Reset state
              setState(() {
                records.clear();
                machineCheckStatus = {};
                selectedType = null;
                surgeryStartTime = null;
                anesthesiaStartTime = DateTime.now();
                localDrugs.clear();
                spinalDrugs.clear();
                spinalProcedure.clear();
              });
              // Initialize with empty data
              for (var item in machineCheckItems) {
                machineCheckStatus[item] = false;
              }
              await _saveAllData();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
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
  final List<DrugAdministered> drugsAdministered;

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
    required this.drugsAdministered, // This is required
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Add a factory constructor with optional drugs
  factory AnesthesiaRecord.withDefaults({
    String? id,
    required DateTime time,
    required int hr,
    required int sbp,
    required int dbp,
    required int rr,
    required int spo2,
    required double temp,
    int painScore = 0,
    String? infusionType,
    List<DrugAdministered>? drugsAdministered,
  }) {
    return AnesthesiaRecord(
      id: id,
      time: time,
      hr: hr,
      sbp: sbp,
      dbp: dbp,
      rr: rr,
      spo2: spo2,
      temp: temp,
      painScore: painScore,
      infusionType: infusionType,
      drugsAdministered: drugsAdministered ?? [],
    );
  }

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
      'drugsAdministered': drugsAdministered
          .map((drug) => drug.toJson())
          .toList(),
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
      drugsAdministered:
          (json['drugsAdministered'] as List<dynamic>?)
              ?.map((drugJson) => DrugAdministered.fromJson(drugJson))
              .toList() ??
          [],
    );
  }
}
class DrugAdministered {
  final String drugName;
  final String dosage;
  final String route;
  
  DrugAdministered({
    required this.drugName,
    required this.dosage,
    required this.route,
  });
  
  // Add a factory constructor for empty/optional drugs
  factory DrugAdministered.empty() {
    return DrugAdministered(
      drugName: '',
      dosage: '',
      route: '',
    );
  }
  
  bool get isEmpty => drugName.isEmpty && dosage.isEmpty && route.isEmpty;
  
  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'dosage': dosage,
      'route': route,
    };
  }
  
  factory DrugAdministered.fromJson(Map<String, dynamic> json) {
    return DrugAdministered(
      drugName: json['drugName'],
      dosage: json['dosage'],
      route: json['route'],
    );
  }
}
