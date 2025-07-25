import 'package:flutter/material.dart';
import '../API/api.dart';
import '../models/report_model.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  final bool isWorker;
  final bool fromHome;
  final String? statusFilter;

  const ReportListScreen({
    super.key,
    this.isWorker = false,
    this.fromHome = false,
    this.statusFilter,
  });

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Report> _reports = [];
  List<Report> _filteredReports = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.statusFilter != null) {
      _selectedFilter = widget.statusFilter!;
    }
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Report> reports = [];
      
      if (widget.isWorker) {
        // Load only first page of reports for workers (much faster!)
        reports = await _api.getReports(page: 1, pageSize: 50);
      } else {
        // For users, still use the existing method for their own reports
        reports = await _api.getReports(page: 1, pageSize: 50, userReportsOnly: true);
      }

      if (mounted) {
        setState(() {
          _reports = reports;
          _filterReports();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load reports: ${e.toString()}';
          _reports = [];
          _filteredReports = [];
        });
      }
    }
  }

  void _filterReports() {
    List<Report> filtered = _reports;
    
    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((report) => report.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }
    
    // Apply search filter (now includes username)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        final descriptionMatch = report.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final damageTypeMatch = report.damageType.toLowerCase().contains(_searchQuery.toLowerCase());
        final usernameMatch = report.userInfo != null &&
            (report.userInfo!['username']?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
        return descriptionMatch || damageTypeMatch || usernameMatch;
      }).toList();
    }
    
        setState(() {
      _filteredReports = filtered;
      });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterReports();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterReports();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.purple;
      case 'received':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.construction;
      case 'received':
        return Icons.inbox;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'received':
        return 'New';
      default:
        return status.substring(0, 1).toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildFilterChipsSliver(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final theme = Theme.of(context);
    return SliverAppBar(
      automaticallyImplyLeading: widget.fromHome? true : false,
      expandedHeight: 170,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 0,
      title: Text(
        widget.isWorker ? 'All Reports' : 'My Reports',
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        '${_reports.length} reports',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    // height: 48,
                    // decoration: BoxDecoration(
                    //   color: Colors.white.withOpacity(0.15),
                    //   borderRadius: BorderRadius.circular(24),
                    //   border: Border.all(
                    //     color: Colors.white.withOpacity(0.2),
                    //     width: 1,
                    //   ),
                    // ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: theme.colorScheme.primary),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search reports...',
                        hintStyle: TextStyle(color: theme.colorScheme.primary),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipsSliver() {
    // final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        // color: theme.colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 20, 0, 4),
        child: _buildFilterChips(),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All', 'color': Colors.grey[700]!},
      {'key': 'received', 'label': 'New', 'color': Colors.blue},
      {'key': 'pending', 'label': 'Pending', 'color': Colors.orange},
      {'key': 'in_progress', 'label': 'In Progress', 'color': Colors.purple},
      {'key': 'completed', 'label': 'Completed', 'color': Colors.green},
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          final color = filter['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onFilterChanged(filter['key'] as String),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? color : color.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return SliverToBoxAdapter(child: _buildErrorState());
    }

    if (_isLoading) {
      return SliverToBoxAdapter(child: _buildLoadingState());
    }

    if (_filteredReports.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildReportCard(_filteredReports[index]),
          childCount: _filteredReports.length,
        ),
          ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading reports...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Container(
      height: 300,
      child: Center(
                              child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  _searchQuery.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No matching reports' : 'No reports found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty 
                    ? 'Try adjusting your search or filters'
                    : _selectedFilter == 'all' 
                        ? 'No reports have been submitted yet'
                        : 'No ${_getStatusDisplayName(_selectedFilter).toLowerCase()} reports found',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_searchQuery.isEmpty && _selectedFilter == 'all')
                ElevatedButton.icon(
                  onPressed: _loadReports,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
                              ),
                            );
                          }

  Widget _buildReportCard(Report report) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(report.status);
    final statusIcon = _getStatusIcon(report.status);
    final statusDisplayName = _getStatusDisplayName(report.status);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.6),
          child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportDetailScreen(report: report),
              ),
            ).then((_) => _loadReports());
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusDisplayName,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Damage type and description with image indicators
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.damageType,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Image count indicator
                    if (report.imageCount > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${report.imageCount}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (report.damageResults.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${report.damageResults.length} detected',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  report.description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (widget.isWorker && report.userInfo != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Reported by ${report.userInfo!['username']}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Image preview section (if images exist)
                if (report.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.imageUrls.length > 4 ? 4 : report.imageUrls.length, // Show max 4 images
                      itemBuilder: (context, index) {
                        if (index == 3 && report.imageUrls.length > 4) {
                          // Show "more" indicator
                          return Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.more_horiz,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${report.imageUrls.length - 3}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              report.imageUrls[index],
                              fit: BoxFit.cover,
                              cacheWidth: 120, // Reduce memory usage
                              cacheHeight: 120,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: theme.colorScheme.surface,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                    size: 24,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: theme.colorScheme.surface,
                                  child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Action button
                Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailScreen(report: report),
                          ),
                        ).then((_) => _loadReports());
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
                      ),
                    ),
      ),
    );
  }
}