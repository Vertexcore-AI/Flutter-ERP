import 'package:flutter/material.dart';
import '../widgets/swipeable_nav_bar.dart';
import 'home_page.dart';
import 'profile_screen.dart';
import 'tasks_page.dart';
import 'farms_page.dart';
import 'crops_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2; // Start with Home (center position)
  late PageController _pageController;

  // Home is now in the CENTER (3rd position, index 2)
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      label: 'Tasks',
      iconPath: 'assets/Icons/Menu_icons/tasks_icon.png',
    ),
    NavigationItem(
      label: 'Farms',
      iconPath: 'assets/Icons/Menu_icons/documents_icon.png',
    ),
    NavigationItem(
      label: 'Home',
      iconPath: 'assets/Icons/Menu_icons/home_icon.png',
    ),
    NavigationItem(
      label: 'Profile',
      iconPath: 'assets/Icons/Menu_icons/profile_icon.png',
    ),
    NavigationItem(
      label: 'Crops',
      iconPath: 'assets/Icons/Menu_icons/crops_icon.png',
    ),
  ];

  final List<Widget> _pages = const [
    TasksPage(),
    FarmsPage(),
    HomePage(), // Home page is now at index 2 (center)
    ProfileScreen(),
    CropsPage(), // Replaced AnalyticsPage
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2); // Start with Home (center)
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SwipeableNavBar(
              items: _navigationItems,
              currentIndex: _selectedIndex,
              onItemSelected: _handlePageChange,
            ),
          ),
        ],
      ),
    );
  }
}
