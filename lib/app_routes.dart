import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/property_list_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/', // 根路径
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/properties', // 房源列表页面
      builder: (context, state) => PropertyListScreen(),
    ),
  ],
);
