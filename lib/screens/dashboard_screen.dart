import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import '../providers/theme_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/production_chart_widget.dart';
import '../widgets/task_table_widget.dart';
import '../widgets/field_info_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(label: 'Dashboard', icon: Icons.dashboard),
    NavigationItem(label: 'Soil & Water', icon: Icons.water_drop),
    NavigationItem(label: 'Weather', icon: Icons.cloud),
    NavigationItem(label: 'Task Management', icon: Icons.task),
    NavigationItem(label: 'Labor Management', icon: Icons.people),
    NavigationItem(label: 'Report & Analytics', icon: Icons.analytics),
    NavigationItem(label: 'Settings', icon: Icons.settings),
    NavigationItem(label: 'Help & Support', icon: Icons.help),
  ];

  // Mock Data
  static final mockWeather = WeatherInfo(
    location: 'Ngawi, Indonesia',
    day: 'Sunday',
    date: '20 Mar, 2024',
    temperature: '28°C',
    highTemp: '32',
    lowTemp: '18',
    condition: 'Sunny',
  );

  static final mockStats = DashboardStats(
    totalLandArea: '1200 acress',
    landAreaChange: '+6% from last month',
    revenue: '\$500,000',
    revenueChange: '+18.48 from last month',
  );

  static final mockProduction = ProductionData(
    wheat: '30%',
    corn: '20%',
    rice: '50%',
    totalTons: '1,000 Tons',
  );

  static final mockTasks = [
    TaskItem(
      taskName: 'Apply Fertilizer to Corn',
      assignedTo: 'Lissa Muurna',
      dueDate: 'Aug 27, 2024',
      status: 'Cancelled',
    ),
    TaskItem(
      taskName: 'Harvest Wheat Field A',
      assignedTo: 'John Farmer',
      dueDate: 'Aug 25, 2024',
      status: 'Completed',
    ),
    TaskItem(
      taskName: 'Irrigation System Check',
      assignedTo: 'Sarah Green',
      dueDate: 'Aug 30, 2024',
      status: 'In Progress',
    ),
  ];

  static final mockField = FieldInfo(
    name: 'Corn Field',
    imagePath: 'assets/images/greenhouse-background-slide2.jpg',
    cropHealth: 'Good',
    plantingDate: '16 May, 2024',
    pesticideUse: 'Low',
  );

  static final mockHarvest = [
    HarvestSummary(vegetable: 'Carrots', amount: '120 Ton'),
    HarvestSummary(vegetable: 'Corns', amount: '80 Ton'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: _buildDashboardContent(context),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.primaryGreen.withValues(alpha: 0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: isSelected
                            ? AppConstants.primaryGreen
                            : (isDark ? Colors.white70 : Colors.grey[600]),
                        size: 24,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Island Style Top Bar (Pill-shaped)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(
                      0xFF2A2A2A,
                    ) // Darker elevated surface in dark mode
                  : Colors.white, // White in light mode
              borderRadius: BorderRadius.circular(21), // Pill shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    Text(
                      'Greenland',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.eco, color: AppConstants.primaryGreen, size: 24),
                  ],
                ),
                // Actions
                Row(
                  children: [
                    // Theme Toggle
                    IconButton(
                      onPressed: () {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme();
                      },
                      icon: Icon(
                        Provider.of<ThemeProvider>(context).isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // User Profile
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppConstants.primaryGreen,
                      child: Text(
                        'MB',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Greeting Section
          Text(
            'Good Morning! 👋',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Ngawi, Indonesia',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Dashboard Layouts
          if (isMobile) ...[
            _buildMobileLayout(context),
          ] else if (isDesktop) ...[
            _buildDesktopLayout(context),
          ] else ...[
            _buildTabletLayout(context),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        WeatherWidget(weather: mockWeather),
        const SizedBox(height: 16),
        _buildHarvestSummary(context),
        const SizedBox(height: 16),
        StatCard(
          label: 'Total Land Area',
          value: mockStats.totalLandArea,
          change: mockStats.landAreaChange,
          badgeIcon: Icons.landscape,
        ),
        const SizedBox(height: 16),
        StatCard(
          label: 'Revenue',
          value: mockStats.revenue,
          change: mockStats.revenueChange,
          badgeIcon: Icons.attach_money,
          badgeColor: Colors.green,
        ),
        const SizedBox(height: 16),
        ProductionChartWidget(production: mockProduction),
        const SizedBox(height: 16),
        FieldInfoCard(field: mockField),
        const SizedBox(height: 16),
        TaskTableWidget(tasks: mockTasks),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WeatherWidget(weather: mockWeather),
                  const SizedBox(height: 16),
                  _buildHarvestSummary(context),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: ProductionChartWidget(production: mockProduction)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatCard(
                    label: 'Revenue',
                    value: mockStats.revenue,
                    change: mockStats.revenueChange,
                    badgeIcon: Icons.attach_money,
                    badgeColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    label: 'Total Land Area',
                    value: mockStats.totalLandArea,
                    change: mockStats.landAreaChange,
                    badgeIcon: Icons.landscape,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TaskTableWidget(tasks: mockTasks),
        const SizedBox(height: 16),
        FieldInfoCard(field: mockField),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: WeatherWidget(weather: mockWeather)),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ProductionChartWidget(production: mockProduction),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildHarvestSummary(context),
                    const SizedBox(height: 16),
                    StatCard(
                      label: 'Total Land Area',
                      value: mockStats.totalLandArea,
                      change: mockStats.landAreaChange,
                      badgeIcon: Icons.landscape,
                    ),
                    const SizedBox(height: 16),
                    StatCard(
                      label: 'Revenue',
                      value: mockStats.revenue,
                      change: mockStats.revenueChange,
                      badgeIcon: Icons.attach_money,
                      badgeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: TaskTableWidget(tasks: mockTasks)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: FieldInfoCard(field: mockField)),
          ],
        ),
      ],
    );
  }

  Widget _buildHarvestSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vegetable Harvest Summary',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...mockHarvest.map((harvest) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.grass,
                      size: 20,
                      color: AppConstants.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        harvest.vegetable,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                    Text(
                      harvest.amount,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;

  NavigationItem({required this.label, required this.icon});
}
