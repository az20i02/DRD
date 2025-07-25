import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'API/api.dart';
import 'Main/welcome_screen.dart';
import 'shared/auth/login_screen.dart';
import 'shared/auth/signup_screen.dart';
import 'shared/splash_screen.dart';
import 'WorkerScreens/worker_bottom_nav.dart';
import 'NormalUserScreens/normal_user_bottom_nav.dart';
import 'shared/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  
  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => AppThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (context, themeNotifier, _) => MaterialApp(
        title: 'DRD - Road Damage Detection',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.currentTheme,
        home: const SplashScreen(),
        // Disable transitions to improve performance
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/welcome':
              page = const WelcomeScreen();
              break;
            case '/login':
              page = const LoginScreen();
              break;
            case '/signup':
              page = const SignupScreen();
              break;
            case '/splash':
              page = const SplashScreen();
              break;
            case '/worker_home':
              page = const WorkerBottomNav();
              break;
            case '/user_home':
              page = const NormalUserBottomNav();
              break;
            default:
              page = const SplashScreen();
          }
          
          // Use instant page transitions to reduce GPU load
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        },
        // Add error handling for navigation
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${errorDetails.exception}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/splash',
                          (route) => false,
                        );
                      },
                      child: const Text('Restart App'),
                    ),
                  ],
                ),
              ),
            );
          };
          return widget!;
        },
      ),
    );
  }
}