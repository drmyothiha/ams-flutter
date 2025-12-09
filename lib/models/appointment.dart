class Appointment {
  final String id;
  final String resourceType;
  final String status;
  final DateTime start;
  final DateTime end;
  final String patientName;
  final String doctorName;
  final String? diagnosis;
  final String? procedureCode;
  final List<dynamic> participants;
  final Map<String, dynamic> raw;
  final String createdAt;

  Appointment({
    required this.id,
    required this.resourceType,
    required this.status,
    required this.start,
    required this.end,
    required this.patientName,
    required this.doctorName,
    this.diagnosis,
    this.procedureCode,
    required this.participants,
    required this.raw,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      resourceType: json['resourceType'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      start: DateTime.parse(
        json['start'] as String? ?? DateTime.now().toString(),
      ),
      end: DateTime.parse(json['end'] as String? ?? DateTime.now().toString()),
      patientName: json['patientName'] as String? ?? 'N/A',
      doctorName: json['doctorName'] as String? ?? 'N/A',
      diagnosis: json['diagnosis'] as String?,
      procedureCode: json['procedureCode'] as String?,
      participants: json['participants'] as List<dynamic>? ?? [],
      raw: json['raw'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}