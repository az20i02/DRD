import 'package:flutter/material.dart';
import 'worker_home_screen.dart';
import '../shared/report_list_screen.dart';
import '../shared/settings_screen.dart';

class WorkerBottomNav extends StatefulWidget {
  const WorkerBottomNav({super.key});

  @override
  State<WorkerBottomNav> createState() => _WorkerBottomNavState();
}

class _WorkerBottomNavState extends State<WorkerBottomNav> {
  int _currentIndex = 0;
  
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const WorkerHomeScreen(),
    const ReportListScreen(isWorker: true),
    const SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}