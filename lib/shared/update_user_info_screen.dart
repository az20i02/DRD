import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../API/api.dart';
import '../API/base.dart';
import '../shared/widgets/modern_text_field.dart';

class UpdateUserInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const UpdateUserInfoScreen({Key? key, this.initialData}) : super(key: key);

  @override
  State<UpdateUserInfoScreen> createState() => _UpdateUserInfoScreenState();
}

class _UpdateUserInfoScreenState extends State<UpdateUserInfoScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialData?['username'] ?? '');
    _emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData?['phone_number'] ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> fields = {};
      if (_usernameController.text.trim().isNotEmpty && _usernameController.text.trim() != (widget.initialData?['username'] ?? '')) {
        fields['username'] = _usernameController.text.trim();
      }
      if (_emailController.text.trim().isNotEmpty && _emailController.text.trim() != (widget.initialData?['email'] ?? '')) {
        fields['email'] = _emailController.text.trim();
      }
      if (_phoneController.text.trim().isNotEmpty && _phoneController.text.trim() != (widget.initialData?['phone_number'] ?? '')) {
        fields['phone_number'] = _phoneController.text.trim();
      }
      final result = await _api.updateUser(
        username: fields['username'],
        email: fields['email'],
        phoneNumber: fields['phone_number'],
        profileImage: _pickedImage,
      );
      if (mounted) {
        if (result['success']) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Update failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Profile image
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path))
                          : (widget.initialData?['profile_image'] != null && widget.initialData!['profile_image'] != ''
                              ? NetworkImage(_getFullImageUrl(widget.initialData!['profile_image'])) as ImageProvider
                              : null),
                      child: _pickedImage == null && (widget.initialData?['profile_image'] == null || widget.initialData?['profile_image'] == '')
                          ? Icon(Icons.person, size: 54, color: theme.colorScheme.onPrimary)
                          : null,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.camera_alt, color: theme.colorScheme.primary, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Text fields
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 48,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _save,
          label: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(
                  'Save Changes',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          icon: _isLoading ? null : Icon(Icons.save_alt, color: theme.colorScheme.onPrimary),
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 