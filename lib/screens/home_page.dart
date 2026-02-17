import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import '../providers/theme_provider.dart';
import '../services/weather_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/production_chart_widget.dart';
import '../widgets/task_table_widget.dart';
import '../widgets/field_info_card.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _weatherService = WeatherService();
  WeatherInfo? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoadingWeather = true);

    try {
      // Fetch weather for Colombo, Sri Lanka
      final result = await _weatherService.getWeatherByCity('Colombo');

      if (result['success']) {
        final data = result['data'];
        final weatherCode = data['weatherCode'] as int;
        final now = DateTime.now();

        setState(() {
          _weatherData = WeatherInfo(
            location: 'Colombo, Sri Lanka',
            day: _getDayName(now.weekday),
            date: _formatDate(now),
            temperature: '${data['temperature'].round()}°C',
            highTemp: '${data['highTemp'].round()}',
            lowTemp: '${data['lowTemp'].round()}',
            condition: _weatherService.getWeatherCondition(weatherCode),
          );
          _isLoadingWeather = false;
        });
      } else {
        // Fallback to mock data if API fails
        setState(() {
          _weatherData = mockWeather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      // Fallback to mock data on error
      setState(() {
        _weatherData = mockWeather;
        _isLoadingWeather = false;
      });
    }
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  // Mock Data (fallback)
  static final mockWeather = WeatherInfo(
    location: 'Colombo, Sri Lanka',
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return _buildDashboardContent(context);
  }

  Widget _buildDashboardContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Island Style Top Bar (Pill-shaped)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A2A) // Darker elevated surface in dark mode
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
                    Icon(Icons.eco, color: AppConstants.limeGreen, size: 24),
                  ],
                ),
                // Actions
                Row(
                  children: [
                    // Profile Icon
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_outline, size: 22),
                      tooltip: 'Profile',
                    ),
                    const SizedBox(width: 4),
                    // Theme Toggle
                    IconButton(
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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
                      backgroundColor: AppConstants.limeGreen,
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
          const SizedBox(height: 4),
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
        WeatherWidget(weather: _weatherData ?? mockWeather),
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
                  WeatherWidget(weather: _weatherData ?? mockWeather),
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
              Expanded(flex: 2, child: WeatherWidget(weather: _weatherData ?? mockWeather)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: ProductionChartWidget(production: mockProduction)),
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
                    Icon(Icons.grass, size: 20, color: AppConstants.limeGreen),
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
