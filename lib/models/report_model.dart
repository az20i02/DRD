import '../API/base.dart';

class Report {
  final String id;
  final String status;
  final String description;
  final String? workerNote;
  final DateTime date;
  final Map<String, dynamic>? operation;
  final Map<String, dynamic>? userInfo;

  Report({
    required this.id,
    required this.status,
    required this.description,
    this.workerNote,
    required this.date,
    this.operation,
    this.userInfo,
  });

  // Helper method to get full image URL
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // If it's already a complete URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // If it's a relative path, prepend the base URL
    String fullUrl = '${Config.baseUrl}$imageUrl';
    return fullUrl;
  }

  // Helper getters to extract nested data
  String get damageType {
    try {
      if (operation == null) {
        return 'Unknown';
      }

      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is Map<String, dynamic>) {
          final results = firstImage['results'] as List?;
          if (results != null && results.isNotEmpty) {
            final firstResult = results.first;
            final damageType = firstResult['damage_type'] ?? 'Unknown';
            return damageType;
          }
        }
      }

      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.isNotEmpty) {
        final firstImage = processedResults.first;
        if (firstImage is Map<String, dynamic>) {
          final results = firstImage['results'] as List?;
          if (results != null && results.isNotEmpty) {
            final firstResult = results.first;
            final damageType = firstResult['damage_type'] ?? 'Unknown';
            return damageType;
          }
        }
      }

      // Try direct results array (fallback)
      final results = operation?['results'] as List?;
      if (results != null && results.isNotEmpty) {
        final firstResult = results.first;
        return firstResult['damage_type'] ?? 'Unknown';
      }

      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  double get latitude {
    try {
      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.isNotEmpty) {
        return _parseDouble(images.first['latitude']);
      }
      
      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.isNotEmpty) {
        return _parseDouble(processedResults.first['latitude']);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double get longitude {
    try {
      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.isNotEmpty) {
        return _parseDouble(images.first['longitude']);
      }
      
      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.isNotEmpty) {
        return _parseDouble(processedResults.first['longitude']);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  String get imageUrl {
    try {
      if (operation == null) {
        return '';
      }

      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is Map<String, dynamic>) {
          final operatedImage = firstImage['operated_image'];
          final originalImage = firstImage['original_image'];
          final rawUrl = operatedImage ?? originalImage ?? '';
          if (rawUrl.isNotEmpty) {
            return _getFullImageUrl(rawUrl);
          }
        }
      }

      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.isNotEmpty) {
        final firstImage = processedResults.first;
        if (firstImage is Map<String, dynamic>) {
          final operatedImage = firstImage['operated_image'];
          final originalImage = firstImage['original_image'];
          final imageUrl = firstImage['image_url'];
          final image = firstImage['image'];
          final rawUrl = operatedImage ?? originalImage ?? imageUrl ?? image ?? '';
          if (rawUrl.isNotEmpty) {
            return _getFullImageUrl(rawUrl);
          }
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  // NEW: Get all images from the operation
  List<String> get imageUrls {
    try {
      List<String> urls = [];
      
      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          if (image is Map<String, dynamic>) {
            final operatedImage = image['operated_image'];
            final originalImage = image['original_image'];
            final rawUrl = operatedImage ?? originalImage ?? '';
            if (rawUrl.isNotEmpty) {
              urls.add(_getFullImageUrl(rawUrl));
            }
          }
        }
        return urls;
      }
      
      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.isNotEmpty) {
        for (var image in processedResults) {
          if (image is Map<String, dynamic>) {
            final operatedImage = image['operated_image'];
            final originalImage = image['original_image'];
            final imageUrl = image['image_url'];
            final image_field = image['image'];
            final rawUrl = operatedImage ?? originalImage ?? imageUrl ?? image_field ?? '';
            if (rawUrl.isNotEmpty) {
              urls.add(_getFullImageUrl(rawUrl));
            }
          }
        }
        return urls;
      }
      
      return urls;
    } catch (e) {
      return [];
    }
  }

  // NEW: Check if multiple images exist
  bool get hasMultipleImages {
    return imageUrls.length > 1;
  }

  // NEW: Get count of images
  int get imageCount {
    return imageUrls.length;
  }

  // NEW: Get damage type for specific image index (UPDATED to show multiple damages)
  String getDamageTypeForImage(int index) {
    try {
      final damageResults = getDamageResultsForImage(index);
      if (damageResults.isEmpty) {
        return 'No Damage Detected';
      }
      
      // If multiple damage types, show them all
      final damageTypes = damageResults
          .map((result) => result['damage_type']?.toString() ?? 'Unknown')
          .where((type) => type != 'Unknown')
          .toList();
      
      if (damageTypes.isEmpty) {
        return 'No Damage Detected';
      } else if (damageTypes.length == 1) {
        return damageTypes.first;
      } else {
        return '${damageTypes.length} damages detected';
      }
    } catch (e) {
      return 'Data Error';
    }
  }

  // NEW: Get all unique damage types for specific image index
  List<String> getDamageTypesForImage(int index) {
    try {
      final damageResults = getDamageResultsForImage(index);
      return damageResults
          .map((result) => result['damage_type']?.toString() ?? 'Unknown')
          .where((type) => type != 'Unknown')
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
      return [];
    }
  }

  // NEW: Get damage results for specific image index
  List<Map<String, dynamic>> getDamageResultsForImage(int index) {
    try {
      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.length > index) {
        final imageData = images[index];
        if (imageData is Map<String, dynamic>) {
          final results = imageData['results'] as List?;
          return results?.cast<Map<String, dynamic>>() ?? [];
        }
      }
      
      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.length > index) {
        final imageData = processedResults[index];
        if (imageData is Map<String, dynamic>) {
          final results = imageData['results'] as List?;
          return results?.cast<Map<String, dynamic>>() ?? [];
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // NEW: Get location for specific image index
  Map<String, double> getLocationForImage(int index) {
    try {
      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.length > index) {
        final imageData = images[index];
        if (imageData is Map<String, dynamic>) {
          return {
            'latitude': _parseDouble(imageData['latitude']),
            'longitude': _parseDouble(imageData['longitude']),
          };
        }
      }
      
      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.length > index) {
        final imageData = processedResults[index];
        if (imageData is Map<String, dynamic>) {
          return {
            'latitude': _parseDouble(imageData['latitude']),
            'longitude': _parseDouble(imageData['longitude']),
          };
        }
      }
      
      return {'latitude': 0.0, 'longitude': 0.0};
    } catch (e) {
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  List<Map<String, dynamic>> get damageResults {
    try {
      // Try USER REPORTS structure first (images array)
      final images = operation?['images'] as List?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images.first;
        final results = firstImage['results'] as List?;
        return results?.cast<Map<String, dynamic>>() ?? [];
      }
      
      // Try WORKER REPORTS structure (processed_results)
      final processedResults = operation?['processed_results'] as List?;
      if (processedResults != null && processedResults.isNotEmpty) {
        final firstImage = processedResults.first;
        final results = firstImage['results'] as List?;
        return results?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      status: json['status'] ?? 'RECEIVED',
      description: json['description'] ?? '',
      workerNote: json['worker_note'],
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      operation: json['operation'],
      userInfo: json['user_info'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'description': description,
      'worker_note': workerNote,
      'date': date.toIso8601String(),
      'operation': operation,
      'user_info': userInfo,
    };
  }

  Report copyWith({
    String? id,
    String? status,
    String? description,
    String? workerNote,
    DateTime? date,
    Map<String, dynamic>? operation,
    Map<String, dynamic>? userInfo,
  }) {
    return Report(
      id: id ?? this.id,
      status: status ?? this.status,
      description: description ?? this.description,
      workerNote: workerNote ?? this.workerNote,
      date: date ?? this.date,
      operation: operation ?? this.operation,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  // Legacy compatibility getters
  DateTime get createdAt => date;
  DateTime get updatedAt => date;
} 