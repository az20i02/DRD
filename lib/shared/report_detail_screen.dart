import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/api.dart';
import '../models/report_model.dart';
// import '../Notifications/notification_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ApiService _api = ApiService();
  // final NotificationService _notificationService = NotificationService();
  late Report _report;
  bool _isUpdating = false;
  Map<String, dynamic>? _userData;
  bool _isWorker = false;
  int _currentImageIndex = 0; // NEW: Track current image being displayed

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await _api.myData();
      if (result['success']) {
        setState(() {
          _userData = result['data'];
          _isWorker = _userData?['is_worker'] == true;
        });
      }
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _openInMaps() async {
    final location = _report.getLocationForImage(_currentImageIndex);
    final url = 'https://www.google.com/maps/search/?api=1&query=${location['latitude']},${location['longitude']}';
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showSnackBar('Could not open maps application', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening maps: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      final response = await _api.updateReportStatus(
        reportId: _report.id,
        status: newStatus,
      );

      if (response['success']) {
        setState(() {
          _report = _report.copyWith(status: newStatus);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return updated report
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error updating status: $e', Colors.red);
      }
    } finally {
      setState(() => _isUpdating = false);
    }
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

  void _showStatusUpdateDialog() {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> statuses = [
      {'key': 'received', 'label': 'New', 'color': Colors.blue, 'icon': Icons.inbox},
      {'key': 'pending', 'label': 'Pending', 'color': Colors.orange, 'icon': Icons.schedule},
      {'key': 'in_progress', 'label': 'In Progress', 'color': Colors.purple, 'icon': Icons.construction},
      {'key': 'completed', 'label': 'Completed', 'color': Colors.green, 'icon': Icons.check_circle},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Update Report Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Status options
                ...statuses.map((status) {
                  final isCurrentStatus = _report.status.toLowerCase() == status['key'];
                  final color = status['color'] as Color;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: isCurrentStatus ? color.withOpacity(0.1) : theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: isCurrentStatus 
                            ? null 
                            : () {
                                Navigator.pop(context);
                                _updateStatus(status['key']);
                              },
                        borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  status['icon'],
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                                      status['label'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: isCurrentStatus ? color : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (isCurrentStatus) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Current status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: color.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isCurrentStatus)
                                Icon(
                                  Icons.check_circle,
                                  color: color,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageGallery(int initialIndex) {
    if (_report.imageUrls.isEmpty) {
      _showSnackBar('No images available to display', Colors.orange);
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return ImageGalleryDialog(
          imageUrls: _report.imageUrls,
          initialIndex: initialIndex,
          reportId: _report.id,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    try {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(theme),
            _buildContent(theme),
          ],
        ),
      );
    } catch (e, stackTrace) {
      
      // Return a fallback UI in case of errors
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text('Report Details'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Report',
                style: TextStyle(
                    fontSize: 20,
                  fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'An error occurred while loading the report details. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isWorker)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showStatusUpdateDialog,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Report Details',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildImageSection(theme),
          const SizedBox(height: 16),
          _buildStatusCard(theme),
          const SizedBox(height: 16),
          // _buildDetailsCard(theme),
          const SizedBox(height: 16),
          _buildLocationCard(theme),
          if (_isWorker) ...[
            const SizedBox(height: 16),
            _buildAIAnalysisCard(theme),
          ],
          if (_report.userInfo != null) ...[
            const SizedBox(height: 16),
            _buildReporterCard(theme),
          ],
          const SizedBox(height: 16),
          _buildTimestampCard(theme),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    final statusColor = _getStatusColor(_report.status);
    final statusIcon = _getStatusIcon(_report.status);
    final statusDisplayName = _getStatusDisplayName(_report.status);

    // Handle multiple images
    if (_report.imageUrls.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[400]!,
                ],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 64, color: Colors.white),
                SizedBox(height: 8),
                Text('No images available', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main image display
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: 'report-image-${_report.id}-$_currentImageIndex', // Use current image for hero
                    child: Image.network(
                      _report.imageUrls[_currentImageIndex], // Use current image instead of first
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                                              errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[400]!,
                              ],
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 64, color: Colors.white),
                              SizedBox(height: 8),
                              Text('Image not available', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          statusDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Image counter (if multiple images)
                if (_report.hasMultipleImages)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.image, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${_currentImageIndex + 1}/${_report.imageCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => _showImageGallery(_currentImageIndex), // Show gallery starting from current image
                      icon: Icon(
                        _report.hasMultipleImages ? Icons.photo_library : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      tooltip: _report.hasMultipleImages ? 'View all images' : 'View full image',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Thumbnail strip for multiple images
        if (_report.hasMultipleImages) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _report.imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == _currentImageIndex 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.outline.withOpacity(0.3),
                        width: index == _currentImageIndex ? 2 : 1,
                      ),
                    ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            _report.imageUrls[index],
                            fit: BoxFit.cover,
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
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: index == _currentImageIndex 
                                      ? Colors.transparent 
                                      : Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (index == _currentImageIndex)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'MAIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final statusColor = _getStatusColor(_report.status);
    final statusIcon = _getStatusIcon(_report.status);
    final statusDisplayName = _getStatusDisplayName(_report.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Report Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Report ID', '#${_report.id}', Icons.tag),
          const SizedBox(height: 12),
          _buildDamageTypesSection(_currentImageIndex),
          const SizedBox(height: 12),
          _buildDetailRow('Status', _getStatusDisplayName(_report.status), _getStatusIcon(_report.status)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Report Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Report ID', '#${_report.id}', Icons.tag),
          const SizedBox(height: 12),
          _buildDamageTypesSection(_currentImageIndex),
          const SizedBox(height: 12),
          _buildDetailRow('Status', _getStatusDisplayName(_report.status), _getStatusIcon(_report.status)),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
            const SizedBox(height: 16),

          Container(
                padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
                child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.my_location, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Coordinates',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                      'Lat: ${_report.getLocationForImage(_currentImageIndex)['latitude']!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                        ),
                      ],
                    ),
                      Row(
                        children: [
                    Text(
                      'Lng: ${_report.getLocationForImage(_currentImageIndex)['longitude']!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openInMaps,
              icon: const Icon(Icons.navigation),
              label: const Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              const Text(
                'AI Analysis Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
            const SizedBox(height: 16),

          ..._report.getDamageResultsForImage(_currentImageIndex).map((result) {
            final confidence = result['damage_description']?.toString().split(':').last.trim() ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.purple, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          result['damage_type'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                    Text(
                          confidence,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReporterCard(ThemeData theme) {
    final userInfo = _report.userInfo!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Reporter Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Name', userInfo['username'] ?? 'Unknown', Icons.person_outline),
          const SizedBox(height: 12),
          _buildDetailRow('Email', userInfo['email'] ?? 'Not provided', Icons.email_outlined),
          const SizedBox(height: 12),
          _buildDetailRow('Phone', userInfo['phone_number'] ?? 'Not provided', Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget _buildTimestampCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTimelineItem(
            'Report Created',
            _formatDateTime(_report.date),
            Icons.add_circle_outline,
            Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          _buildTimelineItem(
            'Last Updated',
            _formatDateTime(_report.date),
            Icons.update,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // NEW: Build damage types section showing all damage types for current image
  Widget _buildDamageTypesSection(int imageIndex) {
    final theme = Theme.of(context);
    final damageTypes = _report.getDamageTypesForImage(imageIndex);
    
    if (damageTypes.isEmpty) {
      return _buildDetailRow('Damage Type', 'No Damage Detected', Icons.warning);
    }
    
    return Column(
      children: [
        // Header row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.warning, size: 16, color: theme.colorScheme.onBackground.withOpacity(0.7)),
            ),
            const SizedBox(width: 12),
            Text(
              'Damage Type${damageTypes.length > 1 ? 's' : ''}:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            if (damageTypes.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${damageTypes.length} types',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Damage types list
        Column(
          children: damageTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final damageType = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${index + 1}.',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      damageType,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.onBackground.withOpacity(0.7)),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// NEW: Image Gallery Dialog for viewing multiple images
class ImageGalleryDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String reportId;

  const ImageGalleryDialog({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    required this.reportId,
  });

  @override
  State<ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<ImageGalleryDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Image PageView
          Center(
            child: Hero(
              tag: 'report-image-${widget.reportId}-$_currentIndex',
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 32,
                  maxHeight: MediaQuery.of(context).size.height - 100,
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white, size: 48),
                                  SizedBox(height: 8),
                                  Text('Failed to load image', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Top controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation arrows (only show if multiple images)
          if (widget.imageUrls.length > 1) ...[
            // Left arrow
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                ),
              ),
            
            // Right arrow  
            if (_currentIndex < widget.imageUrls.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
          
          // Bottom thumbnail strip (only show if multiple images)
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white30,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                widget.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.transparent 
                                          : Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}