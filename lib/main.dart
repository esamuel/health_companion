// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_companion/config/app_theme.dart';
import 'package:health_companion/screens/home_page.dart';
import 'package:health_companion/screens/splash_screen.dart';
import 'package:health_companion/screens/error_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app settings
  await AppTheme.initialize();
  
  // Request necessary permissions
  await _requestPermissions();

  runApp(const HealthCompanionApp());
}

Future<void> _requestPermissions() async {
  await Permission.notification.request();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.activityRecognition.request();
  await Permission.location.request();
}

class HealthCompanionApp extends StatefulWidget {
  const HealthCompanionApp({super.key});

  @override
  _HealthCompanionAppState createState() => _HealthCompanionAppState();
}

class _HealthCompanionAppState extends State<HealthCompanionApp> {
  bool _isDarkMode = false;
  bool _isHighContrast = false;
  bool _isLoading = true;
  double _currentFontSize = 16.0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadAppSettings();
  }

  Future<void> _loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        _isHighContrast = prefs.getBool('highContrast') ?? false;
        _currentFontSize = prefs.getDouble('fontSize') ?? AppTheme.defaultFontSize;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading app settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void updateFontSize(double newSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', newSize);
    setState(() {
      _currentFontSize = newSize;
    });
  }

  void updateHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', enabled);
    setState(() {
      _isHighContrast = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: SplashScreen(),
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Health Companion',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppTheme.getLightTheme(
        fontSize: _currentFontSize,
        isHighContrast: _isHighContrast,
      ),
      darkTheme: AppTheme.getDarkTheme(
        fontSize: _currentFontSize,
        isHighContrast: _isHighContrast,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Global App Styling
      builder: (context, child) {
        // Apply text scaling to the entire app
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: _currentFontSize / AppTheme.defaultFontSize,
          ),
          child: ScrollConfiguration(
            // Custom scroll behavior with increased scroll bar size
            behavior: CustomScrollBehavior(),
            child: child!,
          ),
        );
      },

      // Error Handler
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _ErrorScreen(error: settings.name ?? 'Unknown route'),
        );
      },

      // Home Screen
      home: HomePage(
        onThemeChanged: updateTheme,
        onFontSizeChanged: updateFontSize,
        onHighContrastChanged: updateHighContrast,
        currentFontSize: _currentFontSize,
        isHighContrast: _isHighContrast,
      ),
    );
  }
}

// Custom scroll behavior for better accessibility
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return RawScrollbar(
      controller: details.controller,
      thickness: 8.0,
      radius: const Radius.circular(20),
      thumbVisibility: true,
      child: child,
    );
  }
}

// Error Screen
class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(
                        onThemeChanged: null,
                        onFontSizeChanged: null,
                        onHighContrastChanged: null,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
