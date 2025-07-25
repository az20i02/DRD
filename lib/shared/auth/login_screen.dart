import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../API/api.dart';
import '../../shared/app_theme.dart';
import '../../shared/splash_screen.dart';
import '../widgets/modern_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final result = await apiService.loginUser(
        username: _emailController.text.trim(),
          password: _passwordController.text,
      );

      if (result['success']) {
          if (mounted) {
            final userData = result['data']['data']['user'];
            
            final route = userData['is_worker'] ? '/worker_home' : '/user_home';
            
            Navigator.pushReplacementNamed(
              context,
              route,
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Login failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
      }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
    } finally {
        if (mounted) {
      setState(() {
        _isLoading = false;
      });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
          children: [
          // Orange curved header section
            Container(
            height: 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with back button and info icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
              child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Login text
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                  color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                  ),
                  ],
                ),
              ),
            ),
          ),
          
          // Form section - Updated to match signup screen
          Expanded(
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                        children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                          ),
                          const SizedBox(height: 20),
                    ],
                    
                    // Email or phone number field
                    ModernTextField(
                      controller: _emailController,
                      label: 'Email or phone number',
                      hintText: 'Enter your email or phone',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Password field
                    ModernTextField(
                            controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          size: 22,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                            ),
                    
                    const SizedBox(height: 40),
                    
                    // Login button
                          SizedBox(
                            width: double.infinity,
                      height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                                shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Sign up link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}
