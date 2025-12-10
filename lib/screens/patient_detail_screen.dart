import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../widgets/patient_detail_tabs/index.dart';

class PatientDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const PatientDetailScreen({super.key, required this.appointment});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _apiData;
  bool _loading = true;
  String? _error;
  ScrollController? _scrollController;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Initialize scroll controller for first tab
    _scrollController = ScrollController();
    _scrollController!.addListener(_handleScroll);

    // Check if we already have the raw data from the appointment
    if (widget.appointment.raw.isNotEmpty) {
      // Use the raw data we already have from the list API
      setState(() {
        _apiData = widget.appointment.raw;
        _loading = false;
      });
    } else {
      // If no raw data, try to fetch it
      _loadPatientData();
    }
  }

  void _handleScroll() {
    if (_scrollController!.offset > 100 && _showAppBar) {
      setState(() {
        _showAppBar = false;
      });
    } else if (_scrollController!.offset <= 100 && !_showAppBar) {
      setState(() {
        _showAppBar = true;
      });
    }
  }

  Future<void> _loadPatientData() async {
    // This method remains the same as before
    // ... (your existing _loadPatientData implementation)
    try {
      // Your existing implementation here
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ADD THIS MISSING METHOD
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Patient Data',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPatientData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_handleScroll);
    _scrollController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final useCompactView = isLandscape && screenHeight < 400;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.appointment.patientName)),
        body: _buildErrorView(),
      );
    }

    final data = _apiData ?? widget.appointment.raw;

    return Scaffold(
      appBar: _showAppBar || !useCompactView
          ? AppBar(
              title: Text(widget.appointment.patientName),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Info'),
                  Tab(text: 'Preop'),
                  Tab(text: 'Intraop'),
                  Tab(text: 'Recovery'),
                  Tab(text: 'Procedures'),
                ],
                isScrollable: true,
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScrollableTab(
            InfoTab(
              appointment: widget.appointment,
              patientData: data,
            ),
          ),
          _buildScrollableTab(
            PreopTab(
              patientId: widget.appointment.id,
              patientData: data,
            ),
          ),
          _buildScrollableTab(
            IntraopTab(
              patientId: widget.appointment.id,
              patientData: data,
            ),
          ),
          _buildScrollableTab(
            RecoveryTab(
              patientId: widget.appointment.id,
              patientData: data,
            ),
          ),
          _buildScrollableTab(
            ProceduresTab(
              patientId: widget.appointment.id,
              patientData: data,
            ),
          ),
        ],
      ),
      // Floating tab indicator when app bar is hidden
      floatingActionButton: !_showAppBar && useCompactView
          ? FloatingActionButton.extended(
              onPressed: () {
                // Show tab selector
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              widget.appointment.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Info'),
                              Tab(text: 'Preop'),
                              Tab(text: 'Intraop'),
                              Tab(text: 'Recovery'),
                              Tab(text: 'Procedures'),
                            ],
                            isScrollable: true,
                            onTap: (index) {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.menu),
              label: const Text('Tabs'),
            )
          : null,
    );
  }

  Widget _buildScrollableTab(Widget child) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Update scroll controller for hide/show logic
        if (notification is ScrollUpdateNotification) {
          _handleScroll();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}