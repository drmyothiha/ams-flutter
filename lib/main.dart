import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For HttpClient for self-signed certs

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment System',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppointmentListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Appointment> _appointments = [];
  bool _loading = true;
  String _filter = 'all';
  String? _error;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // Create a custom HTTP client that accepts self-signed certificates
  Future<http.Client> _getHttpClient() async {
    final HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) =>
            true; // Accept all certificates
    return http.Client();
  }

  Future<void> _loadAppointments({int? page}) async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final client = await _getHttpClient();

      final response = await client.get(
        Uri.parse('http://192.168.100.8/api/appointments').replace(
          queryParameters: {
            'page': page?.toString() ?? _currentPage.toString(),
            'limit': _itemsPerPage.toString(),
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Check if 'data' field exists and is a List
          final appointmentsData = data['data'];
          List<Appointment> loadedAppointments = [];

          if (appointmentsData is List) {
            loadedAppointments = appointmentsData
                .where((item) => item is Map<String, dynamic>)
                .map<Appointment>((item) => Appointment.fromJson(item))
                .toList();
          }

          final pagination = data['pagination'] as Map<String, dynamic>?;

          if (mounted) {
            setState(() {
              _appointments = loadedAppointments;

              if (pagination != null) {
                _currentPage = pagination['currentPage'] as int? ?? (page ?? 1);
                _totalPages = pagination['totalPages'] as int? ?? 1;
                _totalItems = pagination['totalItems'] as int? ?? 0;
                _hasNextPage = pagination['hasNextPage'] as bool? ?? false;
                _hasPreviousPage =
                    pagination['hasPreviousPage'] as bool? ?? false;
              }
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error = data['message'] ?? 'Failed to load appointments';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load appointments: $e';
        });
      }
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Map<String, dynamic>> statusMap = {
      'pending': {'color': Colors.orange, 'text': 'Pending'},
      'booked': {'color': Colors.blue, 'text': 'Booked'},
      'arrived': {'color': Colors.green, 'text': 'Arrived'},
      'fulfilled': {'color': Colors.purple, 'text': 'Completed'},
      'cancelled': {'color': Colors.red, 'text': 'Cancelled'},
      'noshow': {'color': Colors.red, 'text': 'No Show'},
    };

    final badgeInfo =
        statusMap[status.toLowerCase()] ??
        {'color': Colors.grey, 'text': status};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (badgeInfo['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (badgeInfo['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Text(
        badgeInfo['text'] as String,
        style: TextStyle(
          color: badgeInfo['color'] as Color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    if (_filter == 'all') return _appointments;

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _appointments.where((appointment) {
      final appointmentDate = appointment.start;
      final startOfAppointmentDate = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );

      switch (_filter) {
        case 'today':
          return startOfAppointmentDate.isAtSameMomentAs(startOfToday);
        case 'upcoming':
          return startOfAppointmentDate.isAfter(startOfToday);
        case 'past':
          return startOfAppointmentDate.isBefore(startOfToday);
        default:
          return true;
      }
    }).toList();
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Appointment ID', appointment.id),
              _buildDetailRow('Patient', appointment.patientName),
              _buildDetailRow('Doctor', appointment.doctorName),
              _buildDetailRow(
                'Date',
                '${appointment.start.toLocal().toString().split(' ')[0]}',
              ),
              _buildDetailRow(
                'Time',
                '${appointment.start.toLocal().toString().split(' ')[1].substring(0, 5)} - '
                    '${appointment.end.toLocal().toString().split(' ')[1].substring(0, 5)}',
              ),
              _buildDetailRow('Status', appointment.status),
              if (appointment.diagnosis != null)
                _buildDetailRow('Diagnosis', appointment.diagnosis!),
              if (appointment.procedureCode != null)
                _buildDetailRow('Procedure Code', appointment.procedureCode!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showCancelConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancellation API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cancelling appointment ${appointment.id}'),
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _filterAppointments(String filterType) {
    setState(() {
      _filter = filterType;
      _currentPage = 1;
    });
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();
    final startItem = ((_currentPage - 1) * _itemsPerPage) + 1;
    final endItem = (_currentPage * _itemsPerPage).clamp(0, _totalItems);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 8),
            Text('Appointments'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadAppointments(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Today', 'today'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Upcoming', 'upcoming'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Past', 'past'),
                ],
              ),
            ),
          ),

          // Pagination Info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_totalItems appointments found',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${filteredAppointments.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _filter == 'all' ? 'total' : _filter,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing $startItem-$endItem',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    DropdownButton<int>(
                      value: _itemsPerPage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5 per page')),
                        DropdownMenuItem(value: 10, child: Text('10 per page')),
                        DropdownMenuItem(value: 20, child: Text('20 per page')),
                        DropdownMenuItem(value: 50, child: Text('50 per page')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _itemsPerPage = value;
                            _currentPage = 1;
                          });
                          _loadAppointments();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading appointments...'),
                      ],
                    ),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadAppointments(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _appointments.isEmpty
                              ? 'No appointments found.'
                              : 'No ${_filter} appointments found.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your filter or create a new appointment.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = filteredAppointments[index];
                      final startDate = appointment.start.toLocal();
                      final endDate = appointment.end.toLocal();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.patientName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      appointment.doctorName,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(appointment.status),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${startDate.toString().split(' ')[0]}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${startDate.toString().split(' ')[1].substring(0, 5)} - '
                                    '${endDate.toString().split(' ')[1].substring(0, 5)}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              if (appointment.diagnosis != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  appointment.diagnosis!,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  _showAppointmentDetails(appointment);
                                  break;
                                case 'edit':
                                  // TODO: Implement edit
                                  break;
                                case 'cancel':
                                  _showCancelConfirmation(appointment);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 20),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'cancel',
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel, size: 20),
                                    SizedBox(width: 8),
                                    Text('Cancel'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showAppointmentDetails(appointment),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Pagination
          if (_appointments.isNotEmpty && _totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                color: Colors.grey[50],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageNumbers(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page $_currentPage of $_totalPages',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page),
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() => _currentPage = 1);
                                    _loadAppointments();
                                  }
                                : null,
                            color: _currentPage > 1 ? Colors.blue : Colors.grey,
                          ),
                          IconButton(
                            icon: const Icon(Icons.navigate_before),
                            onPressed: _hasPreviousPage
                                ? () {
                                    setState(() => _currentPage--);
                                    _loadAppointments();
                                  }
                                : null,
                            color: _hasPreviousPage ? Colors.blue : Colors.grey,
                          ),
                          IconButton(
                            icon: const Icon(Icons.navigate_next),
                            onPressed: _hasNextPage
                                ? () {
                                    setState(() => _currentPage++);
                                    _loadAppointments();
                                  }
                                : null,
                            color: _hasNextPage ? Colors.blue : Colors.grey,
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page),
                            onPressed: _currentPage < _totalPages
                                ? () {
                                    setState(() => _currentPage = _totalPages);
                                    _loadAppointments();
                                  }
                                : null,
                            color: _currentPage < _totalPages
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => _filterAppointments(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> widgets = [];
    const int maxPagesToShow = 5;

    int startPage = (_currentPage - maxPagesToShow ~/ 2).clamp(1, _totalPages);
    int endPage = (startPage + maxPagesToShow - 1).clamp(1, _totalPages);

    if (endPage - startPage + 1 < maxPagesToShow) {
      startPage = (endPage - maxPagesToShow + 1).clamp(1, _totalPages);
    }

    // Show "..." at start if needed
    if (startPage > 1) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('...', style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    for (int i = startPage; i <= endPage; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkWell(
            onTap: () {
              setState(() => _currentPage = i);
              _loadAppointments();
            },
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _currentPage == i ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _currentPage == i ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Text(
                '$i',
                style: TextStyle(
                  color: _currentPage == i ? Colors.white : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show "..." at end if needed
    if (endPage < _totalPages) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('...', style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return widgets;
  }
}

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
 