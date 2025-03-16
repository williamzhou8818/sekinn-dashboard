class DashboardItem {
  final String title;
  final String value;
  final String icon;

  DashboardItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}

List<DashboardItem> dashboardItems = [
  DashboardItem(title: "Users", value: "1,234", icon: "👤"),
  DashboardItem(title: "Sales", value: "\$12,345", icon: "💰"),
  DashboardItem(title: "Orders", value: "456", icon: "📦"),
  DashboardItem(title: "Visits", value: "7,890", icon: "👣"),
];
