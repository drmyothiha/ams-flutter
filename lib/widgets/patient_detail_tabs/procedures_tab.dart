import 'package:flutter/material.dart';

class ProceduresTab extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const ProceduresTab({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_information,
            size: 64,
            color: Colors.teal,
          ),
          const SizedBox(height: 16),
          Text(
            'Procedures',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Patient ID: $patientId',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}