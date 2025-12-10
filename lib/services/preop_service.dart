import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PreopService {
  static const String _baseUrl = 'http://192.168.100.8/api';
  
  Future<http.Client> _getHttpClient() async {
    final HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return http.Client();
  }

  Future<Map<String, dynamic>> savePreopAssessment({
    required String appointmentId,
    required Map<String, dynamic> preopData,
  }) async {
    try {
      final client = await _getHttpClient();
      
      final response = await client.post(
        Uri.parse('$_baseUrl/preop/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'preop_data': preopData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Preoperative assessment saved successfully',
            'data': data['data'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to save preop assessment');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error saving preop assessment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPreopAssessment(String appointmentId) async {
    try {
      final client = await _getHttpClient();
      
      final response = await client.get(
        Uri.parse('$_baseUrl/preop/$appointmentId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load preop assessment');
        }
      } else if (response.statusCode == 404) {
        // No preop assessment found yet
        return {
          'success': true,
          'data': null,
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error loading preop assessment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    required String notes,
  }) async {
    try {
      final client = await _getHttpClient();
      
      final response = await client.put(
        Uri.parse('$_baseUrl/appointments/$appointmentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'status': status,
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Appointment status updated',
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to update status');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }
}