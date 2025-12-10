import 'package:flutter/material.dart';

class IntraopTab extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const IntraopTab({
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
            Icons.science,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'Intraoperative Details',
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