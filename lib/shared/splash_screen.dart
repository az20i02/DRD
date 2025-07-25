import 'package:flutter/material.dart';
import '../API/api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // Small delay to show splash screen
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Check if token is valid using the API verification
      final isTokenValid = await _api.verifyToken();
      
      if (isTokenValid) {
        // Token is valid, get fresh user data
        final result = await _api.myData();
        
        if (result['success']) {
          final userData = result['data'];
          final isWorker = userData['is_worker'] == true;
          
          // Navigate to appropriate screen based on user type
          if (mounted) {
            final route = isWorker ? '/worker_home' : '/user_home';
            Navigator.pushReplacementNamed(context, route);
          }
        } else {
          // Failed to get user data, go to welcome
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/welcome');
          }
        }
      } else {
        // Token is invalid or doesn't exist, go to welcome
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    } catch (e) {
      // Any error occurred, go to welcome screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Modern app icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.engineering,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Decorative dots
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          left: 25,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App title with better typography
                  Text(
                    'Road Damage',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Detection',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  Text(
                    'AI-Powered Road Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Modern loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'Powered by AI Technology',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}