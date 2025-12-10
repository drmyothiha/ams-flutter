import 'package:flutter/material.dart';

class RecoveryTab extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const RecoveryTab({
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
            Icons.healing,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Recovery & Post-op',
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