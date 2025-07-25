import 'package:flutter/material.dart';
import '../API/api.dart';
import '../API/base.dart';
import '../models/report_model.dart';
import '../shared/report_list_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final ApiService _api = ApiService();
  
  Map<String, dynamic>? _userData;
  Map<String, int> _reportCounts = {
    'new': 0,
    'pending': 0,
    'in_progress': 0,
    'completed': 0,
  };
  bool _isLoading = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      
      // Load user data and dashboard stats efficiently (NO HEAVY REPORT LOADING!)
      final results = await Future.wait([
        _api.myData(),
        _api.getDashboardStats(), // Lightweight stats instead of all reports
      ]);
      
      if (!mounted) return;
      
      final userData = results[0] as Map<String, dynamic>;
      final counts = results[1] as Map<String, int>;
      
      if (mounted) {
        setState(() {
          _userData = userData['data'];
          _reportCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
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

  void _navigateToReports({String? status}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportListScreen(
          isWorker: true,
          fromHome: true,
          statusFilter: status,
        ),
      ),
    );
    
    // Only reload if data changed
    if (result == true && mounted) {
      _loadData();
    }
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
                  const SizedBox(height: 80), // Reduced bottom padding
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
                        Icons.badge,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Municipal Worker',
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
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.person,
        color: theme.colorScheme.onPrimaryContainer,
        size: 32,
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
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status Cards Grid - Optimized
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final cardData = [
                {
                  'title': 'New Reports',
                  'count': _reportCounts['new'] ?? 0,
                  'color': Colors.blue,
                  'icon': Icons.inbox,
                  'onTap': () => _navigateToReports(status: 'received'),
                },
                {
                  'title': 'Pending',
                  'count': _reportCounts['pending'] ?? 0,
                  'color': Colors.orange,
                  'icon': Icons.pending_actions,
                  'onTap': () => _navigateToReports(status: 'pending'),
                },
                {
                  'title': 'In Progress',
                  'count': _reportCounts['in_progress'] ?? 0,
                  'color': Colors.yellow[700]!,
                  'icon': Icons.construction,
                  'onTap': () => _navigateToReports(status: 'in_progress'),
                },
                {
                  'title': 'Completed',
                  'count': _reportCounts['completed'] ?? 0,
                  'color': Colors.green,
                  'icon': Icons.check_circle,
                  'onTap': () => _navigateToReports(status: 'completed'),
                },
              ];
              
              final card = cardData[index];
              return _buildStatusCard(
                card['title'] as String,
                card['count'] as int,
                card['color'] as Color,
                card['icon'] as IconData,
                card['onTap'] as VoidCallback,
              );
            },
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
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),

                const SizedBox(height: 8),

                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
          
          _buildActionButton(
            'Priority Tasks',
            Icons.priority_high,
            () => _navigateToReports(status: 'pending'),
          ),
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
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            
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