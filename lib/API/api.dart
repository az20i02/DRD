import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/report_model.dart';
import 'base.dart';
// Removed dio import - using http instead

final FlutterSecureStorage storage = FlutterSecureStorage();

class ApiService with ChangeNotifier {
  // =======================================================================
  // SECTION: Storage Helpers
  // =======================================================================

  Future<void> writeToStorage(
      {required String key, required dynamic value}) async {
    if (value == null) {
      await storage.delete(key: key);
    } else if (value is String) {
      await storage.write(key: key, value: value);
    } else {
      await storage.write(key: key, value: jsonEncode(value));
    }
  }

  Future<dynamic> readFromStorage(String key) async {
    final value = await storage.read(key: key);
    if (value == null) return null;
    try {
      return jsonDecode(value);
    } catch (e) {
      return value;
    }
  }

  static Future<void> clearTokens() async {
    const keys = [
      "access_token",
      "refresh_token",
      "user_type",
      "user_data",
      "is_logged_in"
    ];
    for (var key in keys) {
      await storage.delete(key: key);
    }
  }

  // =======================================================================
  // SECTION: Token Management
  // =======================================================================

  Future<bool> verifyToken() async {
    final token = await storage.read(key: 'access_token');
    if (token == null) return false;

    final url = Uri.parse('${Config.baseUrl}/api/token/verify/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      await clearTokens();
      return false;
    }
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Invalid token. Please log in again.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // =======================================================================
  // SECTION: HTTP Request Handler
  // =======================================================================
  Future<http.Response> _sendRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? fields,
    List<XFile>? files,
    String fileFieldName = 'images',
    bool requiresAuth = false,
  }) async {
    // Fix URL construction to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.parse('${Config.baseUrl}/$cleanEndpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);



    if ((method == 'POST' || method == 'PUT') && files != null &&
        files.isNotEmpty) {
      final request = http.MultipartRequest(method, url);
      request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);

      for (var file in files) {
        request.files.add(
            await http.MultipartFile.fromPath(fileFieldName, file.path));
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    // NEW: Send fields as body if no files
    if (fields != null && fields.isNotEmpty) {
      headers['Content-Type'] = 'application/json';
      final encoded = jsonEncode(fields);
      switch (method) {
        case 'POST':
          return await http.post(url, headers: headers, body: encoded);
        case 'PUT':
          return await http.put(url, headers: headers, body: encoded);
        case 'PATCH':
          return await http.patch(url, headers: headers, body: encoded);
        case 'DELETE':
          return await http.delete(url, headers: headers, body: encoded);
      }
    }

    // Fallback to body if provided
    if (body != null) {
      headers['Content-Type'] = 'application/json';
      final encoded = jsonEncode(body);
      switch (method) {
        case 'POST':
          return await http.post(url, headers: headers, body: encoded);
        case 'PUT':
          return await http.put(url, headers: headers, body: encoded);
        case 'PATCH':
          return await http.patch(url, headers: headers, body: encoded);
        case 'DELETE':
          return await http.delete(url, headers: headers, body: encoded);
      }
    }

    // GET and others
    if (method == 'GET') return await http.get(url, headers: headers);

    throw UnsupportedError('Unsupported HTTP method or missing body/fields');
  }

  // =======================================================================
  // SECTION: User Authentication
  // =======================================================================

  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    XFile? profileImage,
  }) async {
    final fields = {
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    };

    final response = await _sendRequest(
        endpoint: 'api/register/',
        method: 'POST',
        fields: fields,
        files: profileImage != null ? [profileImage] : null,
        fileFieldName: 'profile_image'
    );

    return _handleResponse(
        response, "User registered successfully", "Registration failed");
  }

  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final body = {'username': username, 'password': password};

    final response = await _sendRequest(
      endpoint: 'api/login/',
      method: 'POST',
      body: body,
    );

    final result = _handleResponse(response, "Login successful.",
        "Invalid username or password. Please try again.");

    if (result['success']) {
      final tokenData = result['data']['data'];
      final userData = tokenData['user'];
      
      await writeToStorage(
          key: 'access_token', value: tokenData['access']);
      await writeToStorage(
          key: 'refresh_token', value: tokenData['refresh']);
      await writeToStorage(key: 'user_data', value: tokenData['user']);
    }

    return result;
  }

  Future<Map<String, dynamic>> logoutUser() async {
    final refreshToken = await storage.read(key: 'refresh_token');

    if (refreshToken == null) {
      return {'success': false, 'message': 'No refresh token found'};
    }

    final response = await _sendRequest(
      endpoint: 'api/logout/',
      method: 'POST',
      body: {'refresh': refreshToken},
      requiresAuth: true,
    );

    final result = _handleResponse(
        response, "Logout successful", "Logout failed");

    if (result['success']) {
      await clearTokens();
    }

    return result;
  }

  // =======================================================================
  // SECTION: User Profile
  // =======================================================================

  Future<Map<String, dynamic>> myData() async {
    final response = await _sendRequest(
      endpoint: 'api/me/',
      method: 'GET',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Extract just the user data from the API response
      final userData = responseData['data'];
      await writeToStorage(key: 'user_data', value: userData);
      return {'success': true, 'data': userData};
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<Map<String, dynamic>> updateUser({
    String? username,
    String? email,
    String? phoneNumber,
    XFile? profileImage,
  }) async {
    final fields = <String, String>{};

    // Only include changed (non-null) fields
    if (username != null) fields['username'] = username;
    if (email != null) fields['email'] = email;
    if (phoneNumber != null) fields['phone_number'] = phoneNumber;

    final response = await _sendRequest(
      endpoint: 'api/me/update/',
      method: 'PUT',
      fields: fields.isNotEmpty ? fields : null,
      // null if nothing to send
      files: profileImage != null ? [profileImage] : null,
      fileFieldName: 'profile_image',
      requiresAuth: true,
    );

    final result = _handleResponse(
      response,
      "Profile updated successfully",
      "Profile update failed",
    );

    if (result['success']) {
      await myData(); // Await latest user info refresh
    }

    return result;
  }

  // =======================================================================
  // SECTION: Operations
  // =======================================================================

  Future<Map<String, dynamic>> processImages({
    required List<XFile> images,
    required double longitude,
    required double latitude,
  }) async {
    final fields = {
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
    };

    final response = await _sendRequest(
      endpoint: 'api/operations/',
      method: 'POST',
      fields: fields,
      files: images,
      fileFieldName: 'images',
      requiresAuth: true,
    );

    return _handleResponse(
        response, "Images processed successfully", "Image processing failed");
  }

  // =======================================================================
  // SECTION: Report Management
  // =======================================================================

  // Legacy method - now uses pagination
  Future<List<Report>> getUserReports() async {
    return await getReports(page: 1, pageSize: 50, userReportsOnly: true);
  }

  // Get dashboard stats without loading all reports
  Future<Map<String, int>> getDashboardStats() async {
    final response = await _sendRequest(
      endpoint: 'api/reports/stats/',
      method: 'GET',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData['data']; // Access the nested data object
      return {
        'new': data['received'] ?? 0,
        'pending': data['pending'] ?? 0,
        'in_progress': data['in_progress'] ?? 0,
        'completed': data['completed'] ?? 0,
      };
    } else {
      // Fallback: get first page only for counts
      return await _getDashboardStatsFromFirstPage();
    }
  }

  Future<Map<String, int>> _getDashboardStatsFromFirstPage() async {
    final response = await _sendRequest(
      endpoint: 'api/reports/?page_size=100', // Get first 100 only
      method: 'GET',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reportsJson = data['results'] ?? [];
      
      final counts = <String, int>{
        'new': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
      };

      for (final reportJson in reportsJson) {
        final status = (reportJson['status'] as String).toLowerCase();
        switch (status) {
          case 'received':
            counts['new'] = (counts['new'] ?? 0) + 1;
            break;
          case 'pending':
            counts['pending'] = (counts['pending'] ?? 0) + 1;
            break;
          case 'in_progress':
            counts['in_progress'] = (counts['in_progress'] ?? 0) + 1;
            break;
          case 'completed':
            counts['completed'] = (counts['completed'] ?? 0) + 1;
            break;
        }
      }

      return counts;
    } else {
      throw Exception('Failed to fetch dashboard stats');
    }
  }

  // Get paginated reports (lazy loading)
  Future<List<Report>> getReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    bool userReportsOnly = false,
  }) async {
    String endpoint = userReportsOnly ? 'api/me/reports/' : 'api/reports/';
    
    // Build query parameters
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }
    
    // Add query parameters to endpoint
    final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    endpoint = '$endpoint?$query';

    final response = await _sendRequest(
      endpoint: endpoint,
      method: 'GET',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reportsJson = data['data'] ?? data['results'] ?? data['Report'] ?? [];
      
      return reportsJson.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch reports');
    }
  }

  // Legacy method - now uses pagination  
  Future<List<Report>> getAllReports() async {
    return await getReports(page: 1, pageSize: 50); // Only get first 50 reports
  }

  Future<Map<String, dynamic>> createReport({
    required String description,
    required int operationId,
  }) async {
    final body = {
      'description': description,
      'operation_id': operationId,
    };

    final response = await _sendRequest(
      endpoint: 'api/reports/',
      method: 'POST',
      body: body,
      requiresAuth: true,
    );

    return _handleResponse(
        response, "Report created successfully", "Report creation failed");
  }

  Future<Map<String, dynamic>> updateReportStatus({
    required String reportId,
    required String status,
    String? workerNote,
  }) async {
    // Convert status to uppercase to match backend expectations
    final uppercaseStatus = status.toUpperCase();

    final body = {
      'status': uppercaseStatus,
      if (workerNote != null) 'worker_note': workerNote,
    };

    final response = await _sendRequest(
      endpoint: 'api/reports/$reportId/status/',  // Fixed: Use correct backend endpoint
      method: 'PATCH',  // Fixed: Use PATCH method to match backend
      body: body,
      requiresAuth: true,
    );

    return _handleResponse(response, "Report status updated successfully",
        "Failed to update report status");
  }

  Future<Map<String, dynamic>> getReportById(String reportId) async {
    final response = await _sendRequest(
      endpoint: 'api/reports/$reportId/',
      method: 'GET',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': 'Failed to fetch report details'};
    }
  }

  Future<Map<String, dynamic>> myReports(String status, {int page = 1}) async {
    final response = await _sendRequest(
      endpoint: 'api/reports/my/?status=$status&page=$page',
      method: 'GET',
      requiresAuth: true,
    );

    final data = jsonDecode(response.body);
    return _handleResponse(
        response, "Reports fetched successfully", "Failed to fetch reports");
  }


  // =======================================================================
  // SECTION: Response Handling
  // =======================================================================

  Map<String, dynamic> _handleResponse(http.Response response,
      String successMsg, String errorMsg) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': successMsg, 'data': data};
      } catch (e) {
        return {'success': true, 'message': successMsg, 'data': {'raw': response.body}};
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? errorMsg,
          'errors': errorData['errors'] ?? {},
        };
      } catch (e) {
        return {
          'success': false,
          'message': '$errorMsg (Status: ${response.statusCode})',
          'errors': {'raw': response.body},
        };
      }
    }
  }

  // =======================================================================
  // =======================================================================

  // =======================================================================
  // SECTION: FCM Token Management
  // =======================================================================

  Future<Map<String, dynamic>> registerFCMToken(
      {required String fcmToken}) async {
    final body = {'fcm_token': fcmToken};

    final response = await _sendRequest(
      endpoint: 'api/fcm/register-token/',
      method: 'POST',
      body: body,
      requiresAuth: true,
    );

    return _handleResponse(response, "FCM token registered successfully",
        "Failed to register FCM token");
  }

  // Clear FCM Token - Simplified version
  Future<Map<String, dynamic>> clearFCMToken() async {
    try {
      final response = await _sendRequest(
        endpoint: 'api/users/update-fcm-token/',
        method: 'POST',
        body: {
          'action': 'clear',
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Token cleared successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to clear FCM token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }
}

