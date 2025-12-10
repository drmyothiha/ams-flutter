import 'dart:convert';
import 'package:ams/widgets/patient_detail_tabs/intraop_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnesthesiaStorage {
  static const String _keyPrefix = 'anesthesia_record_';
  static const String _recordsKey = 'records';
  static const String _machineCheckKey = 'machine_check';
  static const String _anesthesiaTypeKey = 'anesthesia_type';
  static const String _anesthesiaStartKey = 'anesthesia_start';
  static const String _surgeryStartKey = 'surgery_start';
  static const String _localDrugsKey = 'local_drugs';
  static const String _spinalDrugsKey = 'spinal_drugs';
  static const String _spinalProcedureKey = 'spinal_procedure';

  // Get storage key for specific patient
  static String _getPatientKey(String patientId, String key) {
    return '${_keyPrefix}${patientId}_$key';
  }

  // Save records for a patient
  static Future<void> saveRecords(String patientId, List<AnesthesiaRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _recordsKey);
    final recordsJson = records.map((r) => r.toJson()).toList();
    await prefs.setString(key, json.encode(recordsJson));
  }

  // Load records for a patient
  static Future<List<AnesthesiaRecord>> loadRecords(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _recordsKey);
    final recordsJson = prefs.getString(key);
    
    if (recordsJson == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(recordsJson);
      return decoded.map((json) => AnesthesiaRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error loading records: $e');
      return [];
    }
  }

  // Save machine check status
  static Future<void> saveMachineCheck(String patientId, Map<String, bool> status) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _machineCheckKey);
    await prefs.setString(key, json.encode(status));
  }

  // Load machine check status
  static Future<Map<String, bool>> loadMachineCheck(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _machineCheckKey);
    final statusJson = prefs.getString(key);
    
    if (statusJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = json.decode(statusJson);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      print('Error loading machine check: $e');
      return {};
    }
  }

  // Save anesthesia type
  static Future<void> saveAnesthesiaType(String patientId, String? type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _anesthesiaTypeKey);
    if (type != null) {
      await prefs.setString(key, type);
    } else {
      await prefs.remove(key);
    }
  }

  // Load anesthesia type
  static Future<String?> loadAnesthesiaType(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _anesthesiaTypeKey);
    return prefs.getString(key);
  }

  // Save anesthesia start time
  static Future<void> saveAnesthesiaStart(String patientId, DateTime? time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _anesthesiaStartKey);
    if (time != null) {
      await prefs.setString(key, time.toIso8601String());
    } else {
      await prefs.remove(key);
    }
  }

  // Load anesthesia start time
  static Future<DateTime?> loadAnesthesiaStart(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _anesthesiaStartKey);
    final timeString = prefs.getString(key);
    return timeString != null ? DateTime.parse(timeString) : null;
  }

  // Save surgery start time
  static Future<void> saveSurgeryStart(String patientId, DateTime? time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _surgeryStartKey);
    if (time != null) {
      await prefs.setString(key, time.toIso8601String());
    } else {
      await prefs.remove(key);
    }
  }

  // Load surgery start time
  static Future<DateTime?> loadSurgeryStart(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _surgeryStartKey);
    final timeString = prefs.getString(key);
    return timeString != null ? DateTime.parse(timeString) : null;
  }

  // Save local anesthesia drugs
  static Future<void> saveLocalDrugs(String patientId, Map<String, dynamic> drugs) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _localDrugsKey);
    await prefs.setString(key, json.encode(drugs));
  }

  // Load local anesthesia drugs
  static Future<Map<String, dynamic>> loadLocalDrugs(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _localDrugsKey);
    final drugsJson = prefs.getString(key);
    
    if (drugsJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = json.decode(drugsJson);
      return decoded;
    } catch (e) {
      print('Error loading local drugs: $e');
      return {};
    }
  }

  // Save spinal anesthesia drugs
  static Future<void> saveSpinalDrugs(String patientId, Map<String, dynamic> drugs) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _spinalDrugsKey);
    await prefs.setString(key, json.encode(drugs));
  }

  // Load spinal anesthesia drugs
  static Future<Map<String, dynamic>> loadSpinalDrugs(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _spinalDrugsKey);
    final drugsJson = prefs.getString(key);
    
    if (drugsJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = json.decode(drugsJson);
      return decoded;
    } catch (e) {
      print('Error loading spinal drugs: $e');
      return {};
    }
  }

  // Save spinal procedure details
  static Future<void> saveSpinalProcedure(String patientId, Map<String, dynamic> procedure) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _spinalProcedureKey);
    await prefs.setString(key, json.encode(procedure));
  }

  // Load spinal procedure details
  static Future<Map<String, dynamic>> loadSpinalProcedure(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientKey(patientId, _spinalProcedureKey);
    final procedureJson = prefs.getString(key);
    
    if (procedureJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = json.decode(procedureJson);
      return decoded;
    } catch (e) {
      print('Error loading spinal procedure: $e');
      return {};
    }
  }

  // Clear all data for a patient
  static Future<void> clearPatientData(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = [
      _getPatientKey(patientId, _recordsKey),
      _getPatientKey(patientId, _machineCheckKey),
      _getPatientKey(patientId, _anesthesiaTypeKey),
      _getPatientKey(patientId, _anesthesiaStartKey),
      _getPatientKey(patientId, _surgeryStartKey),
      _getPatientKey(patientId, _localDrugsKey),
      _getPatientKey(patientId, _spinalDrugsKey),
      _getPatientKey(patientId, _spinalProcedureKey),
    ];
    
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  // Get all patient IDs with stored data
  static Future<List<String>> getStoredPatientIds() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final patientIds = <String>{};
    
    for (final key in allKeys) {
      if (key.startsWith(_keyPrefix)) {
        final parts = key.replaceFirst(_keyPrefix, '').split('_');
        if (parts.length >= 2) {
          patientIds.add(parts[0]);
        }
      }
    }
    
    return patientIds.toList();
  }
}