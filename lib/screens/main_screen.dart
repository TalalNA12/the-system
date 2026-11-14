import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'fitness_screen.dart';
import 'profile_screen.dart';
import 'quests_screen.dart';




class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToQuests() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateToQuests: _navigateToQuests),
      const QuestsScreen(),
      const FitnessScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: IndexedStack(index: _currentIndex, children: screens),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xE6050F1E), 
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryGlow.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGlow.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                backgroundColor: Colors.transparent,
                selectedItemColor: AppTheme.secondaryGlow,
                unselectedItemColor: AppTheme.secondaryText.withValues(
                  alpha: 0.5,
                ),
                selectedLabelStyle: AppTheme.sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                unselectedLabelStyle: AppTheme.sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shield_outlined, size: 20),
                    activeIcon: Icon(Icons.shield, size: 20),
                    label: 'HOME',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined, size: 20),
                    activeIcon: Icon(Icons.assignment, size: 20),
                    label: 'QUESTS',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.fitness_center_outlined, size: 20),
                    activeIcon: Icon(Icons.fitness_center, size: 20),
                    label: 'FITNESS',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined, size: 20),
                    activeIcon: Icon(Icons.calendar_month, size: 20),
                    label: 'CALENDAR',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline, size: 20),
                    activeIcon: Icon(Icons.person, size: 20),
                    label: 'PROFILE',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
