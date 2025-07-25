import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Background decorative landscape shapes
          Positioned(
            bottom: size.height * 0.6,
            left: -50,
            child: Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.65,
            right: -80,
            child: Container(
              width: 250,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(125),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.7,
            left: size.width * 0.3,
            child: Container(
              width: 150,
              height: 75,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          // Additional landscape shape for better visibility
          Positioned(
            bottom: size.height * 0.75,
            right: size.width * 0.1,
            child: Container(
              width: 180,
              height: 90,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(90),
              ),
            ),
          ),

          // Background decorative dots
          Positioned(
            top: size.height * 0.15,
            left: size.width * 0.1,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.25,
            right: size.width * 0.15,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            left: size.width * 0.2,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: size.width * 0.25,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.1,
            right: size.width * 0.4,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main curved bottom section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Dark curved background
                Container(
                  width: double.infinity,
                  height: size.height * 0.55,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                    boxShadow: theme.brightness == Brightness.light ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ] : null,
                  ),
                ),

                // Decorative plants positioned on the curve
                Positioned(
                  top: -15,
                  left: 30,
                  child: _buildPlant(false, false, theme),
                ),
                Positioned(
                  top: -10,
                  left: 60,
                  child: _buildPlant(false, true, theme),
                ),
                Positioned(
                  top: -20,
                  left: 90,
                  child: _buildPlant(true, false, theme),
                ),
                Positioned(
                  top: -25,
                  left: size.width * 0.4,
                  child: _buildPlant(true, true, theme),
                ),
                Positioned(
                  top: -15,
                  right: 120,
                  child: _buildPlant(false, false, theme),
                ),
                Positioned(
                  top: -30,
                  right: 80,
                  child: _buildPlant(true, true, theme),
                ),
                Positioned(
                  top: -20,
                  right: 50,
                  child: _buildPlant(false, true, theme),
                ),
                Positioned(
                  top: -10,
                  right: 20,
                  child: _buildPlant(true, false, theme),
                ),

                // App Title
                Positioned(
                  top: 60,
                  left: 40,
                  right: 40,
                  child: Column(
                    children: [
                      Text(
                        'Damaged Road Detection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI-powered road monitoring for safer communities',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons
                Positioned(
                  bottom: 60,
                  left: 40,
                  right: 40,
                  child: Column(
                    children: [
                      // Log In button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Up button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlant(bool isBlue, bool isLarge, ThemeData theme) {
    final height = isLarge ? 40.0 : 30.0;
    final stemHeight = isLarge ? 25.0 : 18.0;
    final leafSize = isLarge ? 12.0 : 10.0;

    return SizedBox(
      width: 30,
      height: height,
      child: Stack(
        children: [
          // Stem
          Positioned(
            bottom: 0,
            left: 13,
            child: Container(
              width: 3,
              height: stemHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),

          // Center main leaf
          Positioned(
            top: 0,
            left: 8,
            child: Container(
              width: leafSize,
              height: leafSize + 4,
              decoration: BoxDecoration(
                color: isBlue ? theme.colorScheme.primary : theme.colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),

          // Left leaf
          Positioned(
            top: 5,
            left: 2,
            child: Container(
              width: leafSize - 2,
              height: leafSize,
              decoration: BoxDecoration(
                color: isBlue ? theme.colorScheme.primary.withOpacity(0.8) : theme.colorScheme.secondary.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),

          // Right leaf
          Positioned(
            top: 5,
            right: 2,
            child: Container(
              width: leafSize - 2,
              height: leafSize,
              decoration: BoxDecoration(
                color: isBlue ? theme.colorScheme.primary.withOpacity(0.8) : theme.colorScheme.secondary.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}