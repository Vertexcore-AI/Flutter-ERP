class DashboardStats {
  final String totalLandArea;
  final String landAreaChange;
  final String revenue;
  final String revenueChange;

  DashboardStats({
    required this.totalLandArea,
    required this.landAreaChange,
    required this.revenue,
    required this.revenueChange,
  });
}

class WeatherInfo {
  final String location;
  final String day;
  final String date;
  final String temperature;
  final String highTemp;
  final String lowTemp;
  final String condition;

  WeatherInfo({
    required this.location,
    required this.day,
    required this.date,
    required this.temperature,
    required this.highTemp,
    required this.lowTemp,
    required this.condition,
  });
}

class ProductionData {
  final String wheat;
  final String corn;
  final String rice;
  final String totalTons;

  ProductionData({
    required this.wheat,
    required this.corn,
    required this.rice,
    required this.totalTons,
  });
}

class TaskItem {
  final String taskName;
  final String assignedTo;
  final String dueDate;
  final String status; // 'Completed', 'In Progress', 'Cancelled'

  TaskItem({
    required this.taskName,
    required this.assignedTo,
    required this.dueDate,
    required this.status,
  });
}

class FieldInfo {
  final String name;
  final String imagePath;
  final String cropHealth;
  final String plantingDate;
  final String pesticideUse;

  FieldInfo({
    required this.name,
    required this.imagePath,
    required this.cropHealth,
    required this.plantingDate,
    required this.pesticideUse,
  });
}

class HarvestSummary {
  final String vegetable;
  final String amount;

  HarvestSummary({
    required this.vegetable,
    required this.amount,
  });
}
