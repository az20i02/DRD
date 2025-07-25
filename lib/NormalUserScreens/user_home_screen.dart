import 'package:flutter/material.dart';
import '../API/api.dart';
import '../API/base.dart';
import '../models/report_model.dart';
import '../shared/report_list_screen.dart';
import 'create_report_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with WidgetsBindingObserver {
  final ApiService _api = ApiService();
  
  Map<String, dynamic>? _userData;
  Map<String, int> _reportCounts = {
    'received': 0,
    'pending': 0,
    'in_progress': 0,
    'completed': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load user data and user's own reports
      final userDataResult = await _api.myData();
      
      final reports = await _api.getUserReports();
      
      if (mounted) {
        // Calculate report counts by status
        final counts = <String, int>{
          'received': reports.where((r) {
            return r.status.toUpperCase() == 'RECEIVED';
          }).length,
          'pending': reports.where((r) => r.status.toUpperCase() == 'PENDING').length,
          'in_progress': reports.where((r) => r.status.toUpperCase() == 'IN_PROGRESS').length,
          'completed': reports.where((r) => r.status.toUpperCase() == 'COMPLETED').length,
        };
        
        setState(() {
          _userData = userDataResult['data'];
          _reportCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl; // Already a full URL
    }
    // Remove leading slash if present and prepend base URL
    final cleanUrl = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return '${Config.baseUrl}/$cleanUrl';
  }

  void _navigateToReports({String? status}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportListScreen(
          isWorker: false, // User can only see their own reports
          fromHome: true,
          statusFilter: status,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  _buildDashboardSection(),
                  _buildQuickActions(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _userData?['profile_image'] != null
                          ? Image.network(
                        _getFullImageUrl(_userData!['profile_image']),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      )
                          : _buildDefaultAvatar(),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData?['username'] ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _userData?['phone_number'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Municipal Worker Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_pin_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Citizen',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildDashboardSection() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Reports Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status Cards Grid - Updated to match worker style
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatusCard(
                'New Reports',
                _reportCounts['received'] ?? 0,
                Colors.blue,
                Icons.inbox,
                () => _navigateToReports(status: 'RECEIVED'),
              ),
              _buildStatusCard(
                'Pending',
                _reportCounts['pending'] ?? 0,
                Colors.orange,
                Icons.pending_actions,
                () => _navigateToReports(status: 'PENDING'),
              ),
              _buildStatusCard(
                'In Progress',
                _reportCounts['in_progress'] ?? 0,
                Colors.yellow[700]!,
                Icons.construction,
                () => _navigateToReports(status: 'IN_PROGRESS'),
              ),
              _buildStatusCard(
                'Completed',
                _reportCounts['completed'] ?? 0,
                Colors.green,
                Icons.check_circle,
                () => _navigateToReports(status: 'COMPLETED'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    int count,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildActionButton(
            'View All Reports',
            Icons.assignment,
            () => _navigateToReports(),
          ),
          
          const SizedBox(height: 12),
          
          // _buildActionButton(
          //   'Send New Report',
          //   Icons.add_circle_outline,
          //   () {
          //     // Navigate directly to create report screen
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const CreateReportScreen(),
          //       ),
          //     ).then((_) => _loadData()); // Refresh data when returning
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}