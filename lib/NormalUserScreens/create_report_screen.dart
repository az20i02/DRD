import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../API/api.dart';
// import '../Notifications/notification_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final ApiService _api = ApiService();
  // final NotificationService _notificationService = NotificationService();
  final _descriptionController = TextEditingController();
  
  List<XFile> _selectedImages = [];
  Map<String, dynamic>? _processResults;
  Position? _currentPosition;
  bool _isProcessing = false;
  bool _isSubmitting = false;
  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });
    } catch (e) {
      setState(() => _isLocationLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
      _processResults = null;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _processResults = null;
      }
    });
  }

  Future<void> _processImages() async {
    if (_selectedImages.isEmpty || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image and ensure location is available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await _api.processImages(
        images: _selectedImages,
        longitude: _currentPosition!.longitude,
        latitude: _currentPosition!.latitude,
      );

      if (result['success']) {
        setState(() {
          _processResults = result['data'];
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedImages.length} image(s) processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing failed: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_processResults == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please process images and add a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final operationId = _processResults!['id'];
      
      final result = await _api.createReport(
        description: _descriptionController.text.trim(),
        operationId: operationId,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form after successful submission
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedImages.clear();
      _processResults = null;
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildImageSection(),
              const SizedBox(height: 24),
              if (_processResults != null) _buildProcessResults(),
              if (_processResults != null) const SizedBox(height: 24),
              _buildDescriptionSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send Report',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Report road damage to help improve community safety',
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Evidence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (_selectedImages.isNotEmpty)
              Text(
                '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Images Grid or Empty State
        if (_selectedImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to add images',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              // Images Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    // Add more images button
                    return GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 32,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add More',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Image tile
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Process Images Button
              if (_processResults == null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isProcessing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onSecondary,
                            ),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(
                      _isProcessing ? 'Processing...' : 'Process Images',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              
              // Clear All Button
              const SizedBox(height: 8),
              TextButton(
                onPressed: _clearAllImages,
                child: Text(
                  'Clear All Images',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProcessResults() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Analysis Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Display processed results
          if (_processResults?['processed_results'] != null) ...[
            for (var imageResult in _processResults!['processed_results']) ...[
              if (imageResult['results']?.isNotEmpty == true) ...[
                for (var result in imageResult['results'])
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result['damage_type'] ?? 'Unknown Damage',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (result['damage_description'] != null)
                                Text(
                                  result['damage_description'],
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'No damage detected in this image',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the road damage in detail...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _currentPosition != null 
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _currentPosition != null ? Icons.location_on : Icons.location_off,
                color: _currentPosition != null 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isLocationLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Getting location...'),
                        ],
                      )
                    : _currentPosition != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location captured',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                                'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Location required',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.error,
                            ),
                          ),
              ),
              if (!_isLocationLoading)
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Refresh location',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    
    final canSubmit = _selectedImages.isNotEmpty && 
                     _processResults != null && 
                     _descriptionController.text.trim().isNotEmpty && 
                     _currentPosition != null && 
                     !_isSubmitting;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canSubmit ? _submitReport : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withOpacity(0.12),
              foregroundColor: canSubmit 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurface.withOpacity(0.38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset Form',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}